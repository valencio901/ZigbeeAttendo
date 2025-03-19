import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class TeacherAttendance extends StatefulWidget {
  const TeacherAttendance({super.key});

  @override
  _TeacherAttendanceState createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  late Future<List<Map<String, dynamic>>> _teachersFuture;
  late Future<List<Map<String, dynamic>>> _attendanceFuture;
  String? selectedTeacher;
  int attendedClasses = 0;
  int missedClasses = 0;

  @override
  void initState() {
    super.initState();
    _teachersFuture = fetchTeachers();
  }

  // Fetch list of teachers from the backend
  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final response = await http.get(Uri.parse(
        'https://2aef-2409-4042-6e80-9e99-89b1-e60b-d035-6092.ngrok-free.app/get_teachers.php'));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'teacher_id': item['teacher_id'],
                'teacher_name': item['teacher_name'],
              })
          .toList();
    } else {
      throw Exception('Failed to load teachers data');
    }
  }

  // Function to fetch attendance based on selected teacher
  Future<List<Map<String, dynamic>>> fetchAttendance(String teacherName) async {
    final response = await http.get(Uri.parse(
        'https://2aef-2409-4042-6e80-9e99-89b1-e60b-d035-6092.ngrok-free.app/get_teacher_attendance.php?teacher_name=$teacherName'));

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'teacher_name': item['teacherName'],
                'attendance': item['Attendance'],
                'lecture_time': item['lecture_time'],
                'classroom': item['classroom'],
                'class': item['class'],
                'lecture': item['Lecture'],
              })
          .toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  // Calculate total attended and missed classes from fetched data
  void calculateAttendance(List<Map<String, dynamic>> attendanceData) {
    int total = attendanceData.length;
    int attended = 0;

    // Loop through the data and count attended vs missed classes
    for (var data in attendanceData) {
      if (data['attendance'] == 'Present') {
        attended++;
      }
    }

    // Post-frame callback to call setState after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        attendedClasses = attended;
        missedClasses = total - attended;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teachers Attendance',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                // Fetch teachers
                future: _teachersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.black)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No teachers found.',
                            style: TextStyle(color: Colors.black)));
                  } else {
                    // Dropdown for selecting a teacher
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Teacher:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedTeacher,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTeacher = newValue;
                              if (selectedTeacher != null) {
                                _attendanceFuture =
                                    fetchAttendance(selectedTeacher!);
                              }
                            });
                          },
                          hint: const Text('Choose a teacher'),
                          items: snapshot.data!.map((teacher) {
                            return DropdownMenuItem<String>(
                              value: teacher['teacher_name'],
                              child: Text(teacher['teacher_name']),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              if (selectedTeacher != null)
                FutureBuilder<List<Map<String, dynamic>>>(
                  // Fetch attendance
                  future: _attendanceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.black)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No attendance data found.',
                              style: TextStyle(color: Colors.black)));
                    } else {
                      // Calculate attendance after data is fetched
                      calculateAttendance(snapshot.data!);

                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          // Display overall attendance
                          Container(
                            height:
                                240, // Increased height for the container to allow more space
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Overall Attendance',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Pie Chart (on the left side)
                                    Expanded(
                                      flex:
                                          3, // Increased flex to 3 to give more space to the pie chart
                                      child: AspectRatio(
                                        aspectRatio:
                                            1.5, // Increased aspect ratio to make the pie chart larger
                                        child: PieChart(
                                          PieChartData(
                                            sections: showingSections(),
                                            centerSpaceRadius: 0,
                                            sectionsSpace: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Spacing between chart and legend

                                    // Legend on the right
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  color: Colors.green,
                                                  size: 12),
                                              SizedBox(width: 5),
                                              Text("Present",
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  color: Colors.red, size: 12),
                                              SizedBox(width: 5),
                                              Text("Absent",
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Displaying attendance data in a table
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              border: TableBorder.all(
                                color: Colors.black,
                                width: 2,
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
                                  label: Text('Attendance',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DataColumn(
                                  label: Text('Class',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                              rows: snapshot.data!.map((data) {
                                return DataRow(cells: [
                                  DataCell(Text(data['classroom'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                  DataCell(Text(data['lecture'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                  DataCell(Text(data['lecture_time'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                  // Adding Edit button next to Attendance
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(
                                          data['attendance'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            _showEditDialog(data);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(data['class'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show dynamic sections in the pie chart
  List<PieChartSectionData> showingSections() {
    int totalClasses = attendedClasses + missedClasses;

    // Avoid division by zero
    double presentPercentage =
        totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;
    double absentPercentage =
        totalClasses > 0 ? (missedClasses / totalClasses) * 100 : 0;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: presentPercentage,
        title:
            '${presentPercentage.toStringAsFixed(1)}%', // Format to 1 decimal place
        radius: 80,
        showTitle: true,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: absentPercentage,
        title: '${absentPercentage.toStringAsFixed(1)}%',
        radius: 80,
        showTitle: true,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    ];
  }

  // Method to show the edit dialog
  void _showEditDialog(Map<String, dynamic> data) {
    String selectedAttendance = data['attendance'] ?? 'Present';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Using setDialogState to update dialog UI
            return AlertDialog(
              title: const Text('Edit Attendance'),
              content: DropdownButton<String>(
                value: selectedAttendance,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setDialogState(() {
                      // Update the state inside the dialog
                      selectedAttendance = newValue;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Present',
                    child: Text('Present'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Absent',
                    child: Text('Absent'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _updateAttendance(
                      data['teacher_name'] ?? '',
                      data['classroom'] ?? '',
                      data['class'] ?? '',
                      data['lecture'] ?? '',
                      data['lecture_time']?.split(' - ')?.first ?? '',
                      data['lecture_time']?.split(' - ')?.last ?? '',
                      selectedAttendance,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }


// Function to send data to PHP backend
  Future<void> _updateAttendance(
      String teacherName,
      String classroom,
      String className,
      String lecture,
      String startTime,
      String endTime,
      String attendance) async {
    const String apiUrl =
        "https://2aef-2409-4042-6e80-9e99-89b1-e60b-d035-6092.ngrok-free.app/update_teacher_attendance.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacher_name": teacherName,
          "classroom": classroom,
          "class": className,
          "lecture": lecture,
          "start_time": startTime,
          "end_time": endTime,
          "attendance": attendance,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Server Response: ${responseData['message']}");

        // Fetch updated attendance data and refresh UI
        setState(() {
          _attendanceFuture = fetchAttendance(selectedTeacher!);
        });
      } else {
        print(
            "Failed to update attendance. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }
}
