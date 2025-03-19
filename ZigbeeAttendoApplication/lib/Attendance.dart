import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'DangerListPage.dart';

class AttendancePage extends StatefulWidget {
  final String className;

  AttendancePage({required this.className});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> attendanceData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;
  bool hasError = false;
  String? selectedRollNo;
  String? selectedSubject;
  String? selectedDate;
  List<String> rollNos = [];
  List<String> subjects = [];
  List<String> dates = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }
  
  int getStudentsAttendedAllLecturesToday(List<dynamic> attendanceData) {
    // Get today's date in YYYY-MM-DD format
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());


    // Step 1: Filter attendance data for today's date
    List<dynamic> todayAttendance = attendanceData.where((entry) {
      // Ensure the date is today's date and the weekday is today's weekday
      return entry['attendance'] == 'Present' && entry['date'] == today;
    }).toList();

    // Step 2: Identify unique roll numbers (students)
    Set<String> uniqueRollNos = Set<String>.from(
        todayAttendance.map((entry) => entry['rollno'].toString()));

    // Step 3: Check each student if they attended all lectures today
    Set<String> studentsAttendedAllLectures = Set<String>();

    uniqueRollNos.forEach((rollno) {
      // Filter all attendance entries for this student on today's date
      var studentAttendance = attendanceData.where((entry) =>
          entry['rollno'].toString() == rollno && entry['date'] == today);

      // Check if the student was marked as "Present" for every lecture today
      bool attendedAllLectures =
          studentAttendance.every((entry) => entry['attendance'] == 'Present');

      // If the student attended all lectures, add them to the set
      if (attendedAllLectures) {
        studentsAttendedAllLectures.add(rollno);
      }
    });

    // Step 4: Return the total number of students who attended all lectures
    return studentsAttendedAllLectures.length;
  }

  Future<void> fetchAttendanceData() async {
    final String url =
        "https://2aef-2409-4042-6e80-9e99-89b1-e60b-d035-6092.ngrok-free.app/attendance_for.php?className=${widget.className}";

    try {
      final response = await http.get(Uri.parse(url));

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          attendanceData = data;
          filteredData = data; // Initially, show all data

          // Removing duplicates using a Set for roll numbers, subjects, and dates
          final uniqueRollNos =
              Set<String>.from(data.map((entry) => entry['rollno'].toString()));
          final uniqueSubjects =
              Set<String>.from(data.map((entry) => entry['subject']));
          final uniqueDates =
              Set<String>.from(data.map((entry) => entry['date'] ?? ''));

          rollNos = uniqueRollNos.toList();
          subjects = uniqueSubjects.toList();
          dates = uniqueDates.toList();

          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Filter function for roll number
  void filterByRollNo(String? rollNo) {
    setState(() {
      selectedRollNo = rollNo;
      filterData();
    });
  }

  // Filter function for subject
  void filterBySubject(String? subject) {
    setState(() {
      selectedSubject = subject;
      filterData();
    });
  }

  // Filter function for date
  void filterByDate(String? date) {
    setState(() {
      selectedDate = date;
      filterData();
    });
  }

  // Function to filter the data based on selected Roll No, Subject, and Date
  void filterData() {
    setState(() {
      filteredData = attendanceData.where((entry) {
        bool matchesRollNo = selectedRollNo == null ||
            entry['rollno'].toString() == selectedRollNo;
        bool matchesSubject =
            selectedSubject == null || entry['subject'] == selectedSubject;
        bool matchesDate =
            selectedDate == null || entry['date'] == selectedDate;
        return matchesRollNo && matchesSubject && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String today = DateTime.now()
        .toString()
        .split(' ')[0]; // Get today's date in YYYY-MM-DD format

    // Calculate the total number of students (distinct roll numbers in attendanceData)
    Set<String> uniqueRollNos = Set<String>.from(
        attendanceData.map((entry) => entry['rollno'].toString()));
    int totalStudents = uniqueRollNos.length;

    // Calculate the total number of students present for today (distinct roll numbers with attendance 'Present' and today's date)
    Set<String> presentRollNos = Set<String>.from(attendanceData
        .where((entry) =>
            entry['attendance'] == 'Present' && entry['date'] == today)
        .map((entry) => entry['rollno'].toString()));
    int totalPresentToday = presentRollNos.length;

    int totalStudentsAttendedAllLectures = getStudentsAttendedAllLecturesToday(attendanceData);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.className}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9),
                Color(0xFFD0E1F9),
                Color.fromARGB(255, 243, 247, 251),
                Color(0xFFD0E1F9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E1F9),
              Color(0xFFD0E1F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Enable vertical scrolling
            physics: BouncingScrollPhysics(), // Smooth scrolling effect
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transparent Buttons
                _buildTransparentInfoButton(
                    'Total Students of class: $totalStudents'),
                SizedBox(height: 10),
                _buildTransparentInfoButton(
                    'Total Students attended today: $totalPresentToday'),
                SizedBox(height: 10),
                _buildTransparentInfoButton(
                    'Total Students attended all lectures: $totalStudentsAttendedAllLectures'),
                SizedBox(height: 15),

                // Pie Chart
                Center(
                  child: Container(
                    width: 400,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Color(0xFFD0E1F9),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: _generatePieChartSections(),
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                
                
                // Dropdown Filters
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFD0E1F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedRollNo,
                          hint: Text('RollNo'),
                          onChanged: (String? newValue) {
                            filterByRollNo(newValue);
                          },
                          items: rollNos
                              .map<DropdownMenuItem<String>>((String rollNo) {
                            return DropdownMenuItem<String>(
                              value: rollNo,
                              child: Text(rollNo),
                            );
                          }).toList(),
                          underline: SizedBox(),
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedSubject,
                          hint: Text('Subject'),
                          onChanged: (String? newValue) {
                            filterBySubject(newValue);
                          },
                          items: subjects
                              .map<DropdownMenuItem<String>>((String subject) {
                            return DropdownMenuItem<String>(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList(),
                          underline: SizedBox(),
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedDate,
                          hint: Text('Date'),
                          onChanged: (String? newValue) {
                            filterByDate(newValue);
                          },
                          items: dates
                              .map<DropdownMenuItem<String>>((String date) {
                            return DropdownMenuItem<String>(
                              value: date,
                              child: Text(date),
                            );
                          }).toList(),
                          underline: SizedBox(),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: double.maxFinite, // Set the width of the button
                    height: 50, // Set the height of the button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DangerListPage(
                              className: widget.className,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 231, 25, 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black,
                      ),
                      child: Text(
                        'Defaulter List',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                // Scrollable Data Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    columns: const [
                      DataColumn(label: Text('Roll No')),
                      DataColumn(label: Text('Attendance')),
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Classroom'))
                    ],
                    rows: filteredData.map((entry) {
                      return DataRow(
                        cells: [
                          DataCell(Text(entry['rollno'].toString())),
                          DataCell(Text(entry['attendance'])),
                          DataCell(Text(entry['time'])),
                          DataCell(Text(entry['date'] ?? 'no')),
                          DataCell(Text(entry['subject'])),
                          DataCell(Text(entry['classroom'])),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),

                // Danger List Button
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    int presentCount =
        filteredData.where((entry) => entry['attendance'] == 'Present').length;
    int absentCount =
        filteredData.where((entry) => entry['attendance'] == 'Absent').length;
    int total = presentCount + absentCount;

    if (total == 0) {
      return [];
    }

    return [
      PieChartSectionData(
        color: Colors.green,
        value: (presentCount / total) * 100,
        title: '${((presentCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: (absentCount / total) * 100,
        title: '${((absentCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle, // Circular legend dot
            border: Border.all(color: Colors.black, width: 1), // Border for visibility
          ),
        ),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

Widget _buildTransparentInfoButton(String text) {
  return InkWell(
    onTap: () {
      // Optional: Add navigation or action if needed
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent background
        border: Border.all(color: Colors.black, width: 2), // Black border
        borderRadius: BorderRadius.circular(10), // Curved edges
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black text color
          ),
        ),
      ),
    ),
  );
}