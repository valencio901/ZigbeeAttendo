import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teachers attendence.dart';
import 'teacher view student attendence.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user selection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification_service.dart';
import 'package:lottie/lottie.dart';

class TeacherDataPage extends StatefulWidget {
  @override
  _TeacherDataPageState createState() => _TeacherDataPageState();
}

class _TeacherDataPageState extends State<TeacherDataPage> {
  late Future<Map<String, String>> teacherData;
  late Future<List<ClassData>> classData;
  Map<String, TextEditingController> _controllers = {};
  String? teacher;
  
Future<void> fetchTeacherClass(String teacherName) async {
    final response = await http.post(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/get_class.php'),
      body: {'teacherName': teacherName},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('classes')) {
        List<String> classList = List<String>.from(data['classes']);

        // Save the classes in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('teacher_classes', classList);

        print("Databases where $teacherName is found: $classList");
      } else {
        print("Error: ${data['error']}");
      }
    } else {
      print("Failed to fetch data.");
    }
  }
  

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove the isLoggedIn session variable
    await prefs.remove('isTeacher'); // Remove roll number
    await prefs.remove('teacher');

    // Navigate to login screen and clear backstack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WhoAreYouPage()),
      (route) => false,
    );
  }

  

  Future<Map<String, String>> fetchTeacherData() async {
    print(teacher);
    final response = await http.get(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/fetch_teacher_details.php?teacherName=${teacher}'),
    );

    print('Response Status Code: ${response.statusCode}'); // Log status code
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'teacherName': data['teacher_name'],
        'phoneNumber': data['phone_number'],
        'address': data['address'],
      };
    } else {
      throw Exception('Failed to load teacher data');
    }
  }

  Future<List<ClassData>> fetchClasses() async {
    final response = await http.get(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/fetch_classes.php?teacherName=${teacher}'),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        List<dynamic> subjectData = data['data'];

        return subjectData.map((json) => ClassData.fromJson(json)).toList();
      } else {
        throw Exception('No subjects found or request failed');
      }
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<void> updateClass(
    String classroom,
    String lecture,
    String combinedTime,
    String substituteTeacherName,
    String type,
    String batch,
  ) async {
    // Split the combined time string into start_time and end_time
    List<String> timeParts = combinedTime.split(' - ');
    String startTime = timeParts[0];
    String endTime = timeParts[1];

    final response = await http.post(
      Uri.parse('https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/update_class.php'),
      body: {
        'teacherName':teacher,  
        'classroom': classroom,
        'lecture': lecture,
        'start_time': startTime, // Pass start_time
        'end_time': endTime, // Pass end_time
        'substituteTeacherName':
            substituteTeacherName, // Pass substitute teacher name
        'type': type, // Pass type
        'batch': batch, // Pass batch
      },
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        classData = fetchClasses();
      });
    } else {
      throw Exception('Failed to update class');
    }
  }


  Future<void> deleteClass(
      String classroom, String lecture, String start_time,String end_time) async {
    final response = await http.post(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/delete_class.php'),
      body: {
        'teacherName': teacher, // Pass the logged-in teacher's name
        'classroom': classroom,
        'lecture': lecture,
        'start_time':start_time,
        'end_time':end_time
      },
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        classData = fetchClasses();
      });
    } else {
      throw Exception('Failed to delete class');
    }
  }

  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('ws://192.168.43.61:8080'));

  void startListening() {
    channel.stream.listen((message) {
      print("Database change detected: $message");
      handleDatabaseChange(message);
    });
  }

  Future<void> handleDatabaseChange(String message) async {
    final Map<String, dynamic> data = jsonDecode(message);
    String table = data['table_name'];
    String action = data['action'];
    final prefs = await SharedPreferences.getInstance();
    String new_teacher_name = data['new_teacher'];
    String old_teacher_name = data['old_teacher'];
    bool? isTeacher = prefs.getBool('isTeacher');
    String? teacher = prefs.getString('teacher');

    String getCurrentWeekday() {
      List<String> days = [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday"
      ];
      return days[
          DateTime.now().weekday - 1]; // Subtract 1 since list is 0-based
    }

    String today = getCurrentWeekday();

        if (table == today &&
        isTeacher == true &&
        new_teacher_name == teacher &&
        teacher != old_teacher_name &&
        (action == "update" || action == "delete")) {
      NotificationService.showNotification(
        title: "You Have Been Given A Lecture",
        body: "principal changed your schedule",
      );
    }

    if(table == today && isTeacher == true && new_teacher_name == old_teacher_name){
      setState(() {
        classData = fetchClasses();
      });
    }

  }


  @override
  void initState() {
    super.initState();
    teacherData = Future.value({});
    classData = Future.value([]);
    _loadSessionData();
    startListening();
  }

  Future<void> _loadSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      teacher = prefs.getString('teacher');
    });

    // Once we load rollno and classValue, fetch other data
    if (teacher != '') {
      setState(() {
        teacherData = fetchTeacherData();
        classData = fetchClasses();    
        fetchTeacherClass(teacher.toString());    
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Teachers Dashboard",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9),
                Color.fromARGB(255, 248, 251, 255),
                Color(0xFFD0E1F9)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9),
                Color(0xFFD0E1F9)
              ], // Apply same gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD0E1F9),
                      Color.fromARGB(255, 255, 255, 255),
                      Color(0xFFD0E1F9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black, // Text color for header
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle,
                    color: Colors.black), // Black icon color
                title: const Text(
                  'View Your Attendance',
                  style: TextStyle(color: Colors.black), // Black text color
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherAttendance(
                        teacherName: teacher.toString(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person,
                    color: Colors.black), // Black icon color
                title: const Text(
                  'View Students Attendance',
                  style: TextStyle(color: Colors.black), // Black text color
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherViewAttendancePage(
                        teacherName: teacher.toString(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: _logout, // Call the logout function
              ),
            ],
          ),
        ),
      ),
      body: Container(
        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>>(
              future: teacherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: Lottie.asset(
    'assets/loading.json',  // Path to your animation file
    width: 100, 
    height: 100, 
    fit: BoxFit.cover,
  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(
                      child: Text('No teacher data available.'));
                } else {
                  var data = snapshot.data!;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage('https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/images/teachers/$teacher.webp'),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              data['teacherName'] ?? 'Teacher Name',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Phone No: ${data['phoneNumber']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Address: ${data['address']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<ClassData>>(
              future: classData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Lottie.asset(
    'assets/loading.json',  // Path to your animation file
    width: 100, 
    height: 100, 
    fit: BoxFit.cover,
  ),);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No classes available.'));
                } else {
                  List<ClassData> classes = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Horizontal scroll
                    child: DataTable(
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Class Room',
                                style: TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text('Lecture',
                                style: TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text('Time',
                                style: TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text('Batch',
                                style: TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text('Type',
                                style: TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text('Actions',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                        rows: classes
                            .map((classData) => DataRow(cells: [
                                  DataCell(Text(classData.classroom,
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(Text(classData.lecture,
                                      style: TextStyle(color: Colors.black))),
                                  // Concatenate start_time and end_time
                                  DataCell(Text(
                                      '${classData.startTime} - ${classData.endTime}',
                                      style: TextStyle(color: Colors.black))),
                                  DataCell(
                                    Text(
                                      (classData.batch == "null" ||
                                              classData.batch == '0')
                                          ? 'No Batch'
                                          : classData.batch!,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),// Add batch field
                                  DataCell(Text(classData.type,
                                      style: TextStyle(
                                          color:
                                              Colors.black))), // Add type field
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _controllers['classroom'] =
                                              TextEditingController(
                                                  text: classData.classroom);
                                          _controllers['lecture'] =
                                              TextEditingController(
                                                  text: classData.lecture);
                                          _controllers['start_time'] =
                                              TextEditingController(
                                                  text: classData.startTime);
                                          _controllers['end_time'] =
                                              TextEditingController(
                                                  text: classData.endTime);
                                          _controllers[
                                                  'substitute_teacher_name'] =
                                              TextEditingController(
                                                  text:
                                                      ''); // Add this for substitute teacher name
                                          _controllers['type'] =
                                              TextEditingController(
                                                  text: classData
                                                      .type); // Add controller for type
                                          _controllers['batch'] =
                                              TextEditingController(
                                                  text: classData
                                                      .batch); // Add controller for batch

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Edit Class'),
                                                content: SingleChildScrollView(
                                                  // Add this scroll view
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'classroom'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Classroom'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'lecture'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Lecture'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'start_time'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Start Time'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'end_time'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'End Time'),
                                                      ),
                                                      TextField(
                                                        controller: _controllers[
                                                            'substitute_teacher_name'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Substitute Teacher Name'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'type'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Type'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _controllers[
                                                                'batch'],
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Batch'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      String combinedTime =
                                                          _controllers[
                                                                      'start_time']!
                                                                  .text +
                                                              " - " +
                                                              _controllers[
                                                                      'end_time']!
                                                                  .text;
                                                      updateClass(
                                                        _controllers[
                                                                'classroom']!
                                                            .text,
                                                        _controllers['lecture']!
                                                            .text,
                                                        combinedTime,
                                                        _controllers[
                                                                'substitute_teacher_name']!
                                                            .text,
                                                        _controllers['type']!
                                                            .text,
                                                        _controllers['batch']!
                                                            .text,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Save'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteClass(
                                                        classData.classroom,
                                                        classData.lecture,
                                                        classData.startTime,
                                                            classData.endTime,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  )),
                                ]))
                            .toList(),
                      )
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ClassData {
  final String classroom;
  final String lecture;
  final String startTime;
  final String endTime;
  final String type;
  final String? batch;
  final int teacherId;

  ClassData({
    required this.classroom,
    required this.lecture,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.batch,
    required this.teacherId,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      classroom: json['classroom'],
      lecture: json['lecture'],
      startTime: json['start_time'], // Map start_time directly
      endTime: json['end_time'], // Map end_time directly
      type: json['type'], // Map the type field
      batch: json['batch'].toString(), // Map the batch field
      teacherId: json['id']
    );
  }
}
