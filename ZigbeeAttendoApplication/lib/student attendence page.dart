import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendancePage extends StatefulWidget {
  final String subjectName;
  final String rollno;
  final String classs;

  const AttendancePage(
      {Key? key,
      required this.subjectName,
      required this.rollno,
      required this.classs})
      : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> attendanceData = [];
  bool isLoading = false;
  DateTime? startDate;
  DateTime? endDate;
  int numLectures = 0;
  int numLecturesAttended = 0;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> fetchAttendanceData() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://92a0-2409-4042-6e93-1402-30cc-ba0f-32a0-1fda.ngrok-free.app/custom_student_attendance.php?rollno=${widget.rollno}&subject=${widget.subjectName}&start_date=${dateFormat.format(startDate!)}&end_date=${dateFormat.format(endDate!)}&class=${widget.classs}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'])),
        );
      } else {
        setState(() {
          attendanceData = data['attendance'];
          numLectures = data['numLectures'] ?? 0;
          numLecturesAttended = attendanceData
              .where((item) => item['attendance'] == 'Present')
              .length;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load attendance data')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    double attendedPercentage =
        numLectures > 0 ? (numLecturesAttended / numLectures) * 100 : 0;
    double missedPercentage = numLectures > 0
        ? ((numLectures - numLecturesAttended) / numLectures) * 100
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} Attendance',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
            const Text('Overall Attendance',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 20),
            if (attendanceData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black,
                        width: 2), // Black border around the pie chart
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Pie chart
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: numLecturesAttended.toDouble(),
                                title:
                                    '${attendedPercentage.toStringAsFixed(1)}%',
                                color: Colors.green,
                                radius: 80,
                                titleStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: (numLectures - numLecturesAttended)
                                    .toDouble(),
                                title:
                                    '${missedPercentage.toStringAsFixed(1)}%',
                                color: Colors.red,
                                radius: 80,
                                titleStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                            borderData: FlBorderData(show: false),
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                      // Legends next to the pie chart
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              CircleAvatar(
                                  radius: 8, backgroundColor: Colors.green),
                              SizedBox(width: 8),
                              Text('Present',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              CircleAvatar(
                                  radius: 8, backgroundColor: Colors.red),
                              SizedBox(width: 8),
                              Text('Absent',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Text('Total Lectures: $numLectures',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 10),
            Text('Lectures Attended: $numLecturesAttended',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD0E1F9),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(startDate == null
                        ? 'Select Start Date'
                        : 'Start: ${dateFormat.format(startDate!)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD0E1F9),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(endDate == null
                        ? 'Select End Date'
                        : 'End: ${dateFormat.format(endDate!)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: fetchAttendanceData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD0E1F9),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text('Get Attendance Data'),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text('Date',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            DataColumn(
                              label: Text('Attendance',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                          rows: attendanceData.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(Text(data['date'] ?? '',
                                    style:
                                        const TextStyle(color: Colors.black))),
                                DataCell(Text(data['attendance'] ?? '',
                                    style:
                                        const TextStyle(color: Colors.black))),
                              ],
                            );
                          }).toList(),
                          headingRowHeight: 56,
                          dataRowHeight: 56,
                          border: TableBorder.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
