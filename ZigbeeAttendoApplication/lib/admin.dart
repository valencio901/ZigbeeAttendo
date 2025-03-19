import 'dart:convert';
import 'package:ZigbeeAttendo/live.dart';
import 'package:ZigbeeAttendo/user%20selection.dart';

import 'ComputerScienceDepartmentPage.dart';
import 'TimeTableOf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'reports.dart';
import 'attendance_excel.dart';
import 'admin_view_teacher_attendance.dart';
import 'upload timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePieChart extends StatefulWidget {
  @override
  _AttendancePieChartState createState() => _AttendancePieChartState();
}

class _AttendancePieChartState extends State<AttendancePieChart> {
  double totalStudents = 100.0;
  double presentStudents = 80.0;
  double totalFaculty = 50.0; // Default value
  double presentFaculty = 40.0; // Default value

  List<String> highestAttendance = [];
  List<String> lowestAttendance = [];

  List<int> _attendanceDates = [];
  List<double> _attendanceValues = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove the isLoggedIn session variable
    await prefs.remove('isAdmin');
    // Navigate to login screen and clear backstack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WhoAreYouPage()),
      (route) => false,
    );
  }


  Future<void> fetchAttendanceData() async {
    final response = await http.get(Uri.parse(
        "https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/attendance_api.php"));

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        highestAttendance = (data['highest'] as List)
            .map((e) => e['database'].toString())
            .toList();
        lowestAttendance = (data['lowest'] as List)
            .map((e) => e['database'].toString())
            .toList();
      });
    } else {
      print("Failed to load attendance data");
    }

    final response2 = await http.get(Uri.parse(
        "https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/count_students.php"));

    print(response2.statusCode);
    print(response2.body);

    if (response2.statusCode == 200) {
      final data2 = json.decode(response2.body);

      setState(() {
        totalStudents = data2['totalCount'].toDouble();
        presentStudents = data2['totalPresent'].toDouble();
      });
    } else {
      print("Failed to load attendance data");
    }

    // Fetch faculty count data
    final response3 = await http.get(
      Uri.parse(
          "https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/count_teachers.php"),
    );

    print(response3.statusCode);
    print(response3.body);

    if (response3.statusCode == 200) {
      final data3 = json.decode(response3.body);

      setState(() {
        totalFaculty = double.parse(data3['totalTeachers'].toString());
        presentFaculty = double.parse(data3['presentTeachers'].toString());
      });
    } else {
      print("Failed to load faculty count data");
    }

    final response4 = await http.get(Uri.parse(
        "https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/get_highest_attendance.php"));

    print(response4.statusCode);
    print(response4.body);

    if (response4.statusCode == 200) {
      final data4 = json.decode(response4.body);

      // Prepare lists for the attendance data
      List<int> dates = [];
      List<double> attendancePercentages = [];

      // Generate all dates for the current month
      DateTime now = DateTime.now();
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      List<int> allDates = List.generate(daysInMonth, (index) => index + 1);

      // Initialize attendance data with 0% for all days
      Map<int, double> attendanceMap = {for (var day in allDates) day: 0.0};

      // Parse the response and update attendance data
      for (var record in data4) {
        String date = record['date'];
        double attendancePercentage = record['attendance_percentage'];

        // Extract the day from the date (assuming date is in "YYYY-MM-DD" format)
        int day = int.parse(date.split('-')[2]);

        // Update the attendance map for the specific day
        attendanceMap[day] = attendancePercentage;
      }

      // Prepare the lists for plotting (dates and their attendance percentages)
      dates = allDates;
      attendancePercentages = dates.map((day) => attendanceMap[day]!).toList();

      setState(() {
        // Update the chart data
        _attendanceDates = dates;
        _attendanceValues = attendancePercentages;
      });
    } else {
      print("Failed to load attendance data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // Light text color (contrasts well with dark background)
            fontSize: 22, // Font size of the title
            fontWeight: FontWeight.w600, // Semi-bold font weight
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9),
                Color(0xFFD0E1F9), // Darker shade of blue (darker than body)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E1F9), // Light Blue
              Color(0xFFD0E1F9), // Same color for consistency
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPieChartSection(),
              _buildSection(
                  "Classes with Highest Attendance", highestAttendance),
              _buildSection("Classes with Lowest Attendance", lowestAttendance),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Faculty Attendance',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50))),
              ),
              _buildFacultyAttendanceSection(),
              _buildLineChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyAttendanceSection() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1C24), // Darker shade of blue
            Color(0xFF263747), // Lighter shade of blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Color(0xFF2980B9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 60,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: presentFaculty,
                    title: '',
                    radius: 40,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: totalFaculty - presentFaculty,
                    title: '',
                    radius: 40,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Faculty: $totalFaculty',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                Text('Present: $presentFaculty',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1C24), // Darker shade for the top part of the gradient
            Color(
                0xFF263747), // Darker shade for the bottom part of the gradient
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: Color(0xFF2980B9), width: 2), // Optional border color
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 60,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: presentStudents,
                    title: '',
                    radius: 40,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: totalStudents - presentStudents,
                    title: '',
                    radius: 40,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Students: $totalStudents',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white)), // Title color change
                Text('Present: $presentStudents',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white)), // Text color change
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildSection(String title, List<String> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 2, 1, 1))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.isNotEmpty
                ? items
                    .map((dbName) => _buildTransparentButton(dbName))
                    .toList()
                : [
                    Text("No data available",
                        style: TextStyle(color: Colors.white))
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransparentButton(String label) {
    return Container(
      width: 100,
      height: 85,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(color: Color(0xFF2980B9), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: TextStyle(color: Color(0xFF2C3E50))),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 400, // Ensure a fixed height for the chart
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1C24), // Darker shade of blue
            Color(0xFF263747), // Lighter shade of blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2980B9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: SizedBox(
          width: (_attendanceDates.length * 40).toDouble(),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true, // Show vertical grid lines
                drawHorizontalLine: true, // Show horizontal grid lines
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors
                        .white, // Set the vertical grid line color to white
                    strokeWidth: 1, // Line thickness
                  );
                },
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors
                        .white, // Set the horizontal grid line color to white
                    strokeWidth: 1, // Line thickness
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            color: Colors.white), // Make Y-axis text white
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      int day = value.toInt();
                      return Text(
                        '$day',
                        style: TextStyle(
                            color: Colors.white), // Make X-axis text white
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                    color: Colors.white, width: 2), // Make axis lines white
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blue, // Line color blue
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  spots: List.generate(
                    _attendanceDates.length,
                    (index) {
                      double attendance = _attendanceValues[index];
                      double day = _attendanceDates[index].toDouble();
                      return FlSpot(day, attendance); // Use actual data here
                    },
                  ),
                ),
              ],
              minY: 0, // Set minimum Y-axis value to 0
              maxY: 100, // Set maximum Y-axis value to 100 (for percentage)
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
                          Color(0xFFD0E1F9), // Light Blue
              Color(0xFFD0E1F9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD0E1F9), // Light Blue
                  Color(0xFFD0E1F9), // Darker shade of blue
                  Color.fromARGB(255, 243, 247, 251), // Lighter shade
                  Color(0xFFD0E1F9), // Same light blue
                  Color(0xFFD0E1F9), // Light Blue
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Your other ListTile items go here...
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Reports'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()),
              );
            },
          ),
          ListTile(
              leading: Icon(Icons.report),
              title: Text('View Teachers Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherAttendance()),
                );
              },
            ),
                      ListTile(
              leading: Icon(Icons.report),
              title: Text('Upload Time Table'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileUploadPage()),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Time Table'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Timetableof()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Alerts'),
            onTap: () {
              // Add appropriate functionality here
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Add appropriate functionality here
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.fileExcel),
            title: Text('View Attendance Excel Files'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendanceExcelPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.class_outlined),
            title: Text('Class Wise Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComputerScienceDepartmentPage()),
              );
            },
          ),
          ListTile(
              leading: Icon(Icons.class_outlined),
              title: Text('View Teachers Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherAttendance()),
                );
              },
            ),
          ListTile(
              leading: Icon(Icons.report),
              title: Text('View Live'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebSocketMessagePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
        ],
      ),
    ),
  );
}

}
