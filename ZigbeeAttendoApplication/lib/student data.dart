import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student attendence page.dart'; // Update with correct file name
import 'about us.dart';
import 'lost tag.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user selection.dart';
import 'notification_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class StudentDataPage extends StatefulWidget {
  const StudentDataPage({super.key});

  @override
  _StudentDataPageState createState() => _StudentDataPageState();
}

class _StudentDataPageState extends State<StudentDataPage> {
  List<String> subjectNames = [];
  String? rollno;
  String? classValue;

  Map<String, double> dataMap = {
    "Present": 0, // Initially set to 0, updated dynamically
    "Absent": 0,
  };

  late String name = 'Loading...',
      className = 'Loading...',
      classroom = 'Loading...',
      college = 'Loading...';
  bool isLoading = true;
  List<Map<String, dynamic>> timetableData = [];

  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.43.61:8080'));

  void startListening() {
    channel.stream.listen((message) {
      print("Database change detected: $message");
      handleDatabaseChange(message);
    });
  }

  void handleDatabaseChange(String message) {
    final Map<String, dynamic> data = jsonDecode(message);
    String database = data['database_name'];
    String table = data['table_name'];
    String action = data['action'];

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

    if(database==classValue && table==today && (action=="update" || action=="delete")){
      fetchTimetableData();
      NotificationService.showNotification(
        title: "Todays Schedule Updated",
        body: "please check the new scedule",
      );
    }
  }


  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove the isLoggedIn session variable
    await prefs.remove('rollno'); // Remove roll number
    await prefs.remove('classValue'); // Remove classValue if stored
    await prefs.remove('isStudent');

    // Navigate to login screen and clear backstack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WhoAreYouPage()),
      (route) => false,
    );
  }


  @override
  void initState() {
    super.initState();
    _loadSessionData();
    startListening();
  }

  Future<void> _loadSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rollno = prefs.getString('rollno');
      classValue = prefs.getString('classValue');
    });

    // Once we load rollno and classValue, fetch other data
    if (rollno != null && classValue != null) {
      fetchStudentData();
      fetchTimetableData();
      fetchSubjects();
    }
  }

  Future<void> fetchSubjects() async {
    final response = await http.get(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/get_students_subjects.php?rollno=${rollno}&class=${classValue}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          subjectNames = List<String>.from(data['subjects']);
        });
      }
    }
  }

  Future<void> fetchStudentData() async {
    final response = await http.post(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/get_student_data.php'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rollno': rollno, 'class': classValue}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          name = data['student']['name'];
          classroom = data['student']['classroom'];
          college = data['student']['college'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTimetableData() async {
    final response = await http.get(
      Uri.parse(
          'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/fetch_students_attendance.php?rollno=${rollno}&class=${classValue}'),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(data['timetable']);

        int totalLectures = fetchedData.length;
        int presentCount =
            fetchedData.where((item) => item['attendance'] == 'Present').length;
        int absentCount = totalLectures - presentCount;

        double presentPercentage =
            totalLectures > 0 ? (presentCount / totalLectures) * 100 : 0;
        double absentPercentage =
            totalLectures > 0 ? (absentCount / totalLectures) * 100 : 0;

        setState(() {
          timetableData = fetchedData;

          // Update PieChart Data with real percentages
          dataMap = {
            "Present": presentPercentage,
            "Absent": absentPercentage,
          };
        });
      } else {
        setState(() {
          timetableData = [];
        });
      }
    } else {
      setState(() {
        timetableData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Student Dashboard', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD0E1F9),Color(0xFFD0E1F9), Color.fromARGB(255, 248, 251, 255),Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
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
              colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
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
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.tag, color: Colors.black),
                title: const Text(
                  'Lost Tag',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LostTagPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.black),
                title: const Text(
                  'About Us',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutUsPage()));
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
        width: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 20, bottom: 10, top: 10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                        'hhttps://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/images/$classValue/$rollno.jpg'),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Roll No: ${rollno}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Class: ${classValue}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Classroom: $classroom',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'College: $college',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Lecture Schedule',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            border: TableBorder.all(
                              color: Colors.black, // Border color
                              width: 2, // Border width
                            ),
                            columns: const [
                              DataColumn(
                                  label: Text('Lecture',
                                      style: TextStyle(color: Colors.black))),
                              DataColumn(
                                  label: Text('Classroom',
                                      style: TextStyle(color: Colors.black))),
                              DataColumn(
                                  label: Text('Time',
                                      style: TextStyle(color: Colors.black))),
                              DataColumn(
                                  label: Text('Attendance',
                                      style: TextStyle(color: Colors.black))),
                            ],
                            rows: timetableData.isEmpty
                                ? const [
                                    DataRow(cells: [
                                      DataCell(Text('Loading...',
                                          style:
                                              TextStyle(color: Colors.black))),
                                      DataCell(Text('Loading...',
                                          style:
                                              TextStyle(color: Colors.black))),
                                      DataCell(Text('Loading...',
                                          style:
                                              TextStyle(color: Colors.black))),
                                      DataCell(Text('Loading...',
                                          style:
                                              TextStyle(color: Colors.black))),
                                    ]),
                                  ]
                                : timetableData.map((timetable) {
                                    return DataRow(cells: [
                                      DataCell(Text(timetable['lecture'],
                                          style: const TextStyle(
                                              color: Colors.black))),
                                      DataCell(Text(timetable['classroom'],
                                          style: const TextStyle(
                                              color: Colors.black))),
                                      DataCell(Text(timetable['time'],
                                          style: const TextStyle(
                                              color: Colors.black))),
                                      DataCell(Text(timetable['attendance'],
                                          style: const TextStyle(
                                              color: Colors.black))),
                                    ]);
                                  }).toList(),
                          )
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: dataMap["Present"]!,
                                      title: '',
                                      radius: 70,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: dataMap["Absent"]!,
                                      title: '',
                                      radius: 70,
                                    ),
                                  ],
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Present',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Absent',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        children: subjectNames.isEmpty
                            ? const [
                                ButtonWithEffect(
                                  label: 'Loading...',
                                  subject: 'Loading...',
                                ),
                              ]
                            : subjectNames.map((subject) {
                                return ButtonWithEffect(
                                  label: subject,
                                  subject: subject,
                                );
                              }).toList(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class ButtonWithEffect extends StatefulWidget {
  final String label;
  final String subject;

  const ButtonWithEffect({
    Key? key,
    required this.label,
    required this.subject,
  }) : super(key: key);

  @override
  _ButtonWithEffectState createState() => _ButtonWithEffectState();
}

class _ButtonWithEffectState extends State<ButtonWithEffect> {
  String? rollno;
  String? classValue;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rollno = prefs.getString('rollno');
      classValue = prefs.getString('classValue');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (rollno != null && classValue != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(
                subjectName: widget.subject,
                rollno: rollno!,
                classs: classValue!,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: Center(
          child: Text(widget.label,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        ),
      ),
    );
  }
}
