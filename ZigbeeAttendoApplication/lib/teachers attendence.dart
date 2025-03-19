import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class TeacherAttendance extends StatefulWidget {
  final String teacherName;

  const TeacherAttendance({required this.teacherName, super.key});

  @override
  _TeacherAttendanceState createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  late Future<List<Map<String, dynamic>>> _attendanceFuture;
  int attendedClasses = 0;
  int missedClasses = 0;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAttendance(widget.teacherName);
  }

  // Function to fetch attendance
  Future<List<Map<String, dynamic>>> fetchAttendance(String teacherName) async {
    final response = await http.get(Uri.parse(
        'https://92a0-2409-4042-6e93-1402-30cc-ba0f-32a0-1fda.ngrok-free.app/get_teacher_attendance.php?teacher_name=$teacherName'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'teacher_name': item['teacherName'],
                'attendance': item['Attendance'],
                'lecture_time': item['lecture_time'],
                'classroom': item['classroom'],
                'class': item['class'],
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

  List<PieChartSectionData> showingSections() {
    // Convert attendedClasses and missedClasses to double for percentage calculation
    double totalClasses = attendedClasses.toDouble() + missedClasses.toDouble();
    double attendedPercentage =
        totalClasses > 0 ? (attendedClasses / totalClasses) * 100.0 : 0.0;
    double missedPercentage =
        totalClasses > 0 ? (missedClasses / totalClasses) * 100.0 : 0.0;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: attendedPercentage,
        title:
            '${attendedPercentage.toStringAsFixed(1)}%', // Show percentage with one decimal place
        radius: 80,
        showTitle: true,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: missedPercentage,
        title:
            '${missedPercentage.toStringAsFixed(1)}%', // Show percentage with one decimal place
        radius: 80,
        showTitle: true,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Attendance',
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
          child: SingleChildScrollView(
            // Enable vertical scrolling for the entire body
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
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
                          Container(
                            height: 240,
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
                                    Expanded(
                                      flex: 3,
                                      child: AspectRatio(
                                        aspectRatio: 1.5,
                                        child: PieChart(
                                          PieChartData(
                                            sections: showingSections(),
                                            centerSpaceRadius: 0,
                                            sectionsSpace: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                          // Horizontal scrolling for the DataTable
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
                                  DataCell(Text(data['teacher_name'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                  DataCell(Text(data['lecture_time'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
                                  DataCell(Text(data['attendance'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.black))),
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
      ),
    );
  }

}