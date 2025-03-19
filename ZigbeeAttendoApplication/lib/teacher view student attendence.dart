import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherViewAttendancePage extends StatefulWidget {
  final String teacherName;

  const TeacherViewAttendancePage({required this.teacherName, super.key});

  @override
  _TeacherViewAttendancePageState createState() =>
      _TeacherViewAttendancePageState();
}

class _TeacherViewAttendancePageState extends State<TeacherViewAttendancePage> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> updateAttendance(String databaseName, int rollNo,
      String newStatus, String date, String subject) async {
    final String apiUrl =
        "https://92a0-2409-4042-6e93-1402-30cc-ba0f-32a0-1fda.ngrok-free.app/teacher_update_attendance.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "class": databaseName, // Now correctly passing as database name
          "rollno": rollNo.toString(),
          "attendance": newStatus,
          "date": date, // Pass selected date
          "subject": subject, // Pass selected subject
        },
      );

      final data = json.decode(response.body);
      if (data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance updated successfully")),
        );
        fetchAttendanceData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update attendance")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating attendance: $e")),
      );
    }
  }

  Future<void> fetchAttendanceData() async {
    final String apiUrl =
        "https://92a0-2409-4042-6e93-1402-30cc-ba0f-32a0-1fda.ngrok-free.app/teacher_view_student.php?teacherName=${widget.teacherName}";
    

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body); // Decode as a map
        final List<dynamic> attendanceList =
            data['attendanceRecords']; // Access the list inside the map

        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(
              attendanceList); // Convert list to desired type
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
  height: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  padding: const EdgeInsets.all(16.0),
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : attendanceData.isEmpty
          ? const Center(
              child: Text(
                "No attendance records found.",
                style: TextStyle(color: Colors.black),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Enable vertical scrolling
                child: DataTable(
                  border: TableBorder.all(
                    color: Colors.black, // Apply border to rows and columns
                    width: 2,
                  ),
                  columns: const [
                    DataColumn(
                        label: Text('Roll No',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Subject',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Time',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Classroom',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Attendance',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Class',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                  ],
                  rows: attendanceData.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(record['rollno'].toString(),
                            style: const TextStyle(color: Colors.black))),
                        DataCell(Text(record['date'],
                            style: const TextStyle(color: Colors.black))),
                        DataCell(Text(record['subject'],
                            style: const TextStyle(color: Colors.black))),
                        DataCell(Text(record['time'],
                            style: const TextStyle(color: Colors.black))),
                        DataCell(Text(record['classroom'],
                            style: const TextStyle(color: Colors.black))),
                        DataCell(Row(
                          children: [
                            Text(record['attendance'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String newAttendance =
                                              record['attendance'];
                                          return AlertDialog(
                                            title:
                                                const Text("Edit Attendance"),
                                            content: StatefulBuilder(
                                              builder: (context, setState) {
                                                // StatefulBuilder is used to update the dropdown selection
                                                return DropdownButton<String>(
                                                  value:
                                                      newAttendance, // Bind this to newAttendance variable
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        newAttendance =
                                                            newValue; // Update the value
                                                      });
                                                    }
                                                  },
                                                  items: ["Present", "Absent"]
                                                      .map((status) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: status,
                                                            child: Text(status),
                                                          ))
                                                      .toList(),
                                                );
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Update"),
                                                onPressed: () {
                                                  updateAttendance(
                                                    record[
                                                        'database'], // Database name
                                                    int.parse(record['rollno']
                                                        .toString()), // Roll number
                                                    newAttendance, // New attendance status
                                                    record['date'], // Date
                                                    record[
                                                        'subject'], // Subject
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ],
                        )),
                        DataCell(Text(record['database'],
                            style: const TextStyle(color: Colors.black))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
),
    );
  }
}
