import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LectureStatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int totalTeachers = 10; // Dummy data
    int totalLecturesTaken = 200; // Dummy data
    double overallPercentage = 75.0; // Dummy data

    List<Map<String, String>> dummyData = [
      {'Teacher': 'John Doe', 'Subject': 'Math', 'Lectures': '20'},
      {'Teacher': 'Jane Smith', 'Subject': 'Physics', 'Lectures': '18'},
      {'Teacher': 'Alice Brown', 'Subject': 'Chemistry', 'Lectures': '22'},
      {'Teacher': 'Michael Johnson', 'Subject': 'Biology', 'Lectures': '19'},
      {'Teacher': 'Emily Davis', 'Subject': 'English', 'Lectures': '25'},
      {'Teacher': 'Daniel Wilson', 'Subject': 'History', 'Lectures': '15'},
      {'Teacher': 'Olivia Martinez', 'Subject': 'Geography', 'Lectures': '17'},
      {
        'Teacher': 'Sophia Anderson',
        'Subject': 'Computer Science',
        'Lectures': '30'
      },
      {'Teacher': 'James Thomas', 'Subject': 'Economics', 'Lectures': '20'},
      {
        'Teacher': 'William Harris',
        'Subject': 'Political Science',
        'Lectures': '16'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecture Statistics',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransparentInfoButton('Total Teachers: $totalTeachers'),
              SizedBox(height: 10),
              _buildTransparentInfoButton(
                  'Total Lectures Taken: $totalLecturesTaken'),
              SizedBox(height: 10),
              _buildTransparentInfoButton(
                  'Overall Percentage: $overallPercentage%'),
              SizedBox(height: 15),

              // Pie Chart with Legends
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 360, // Adjusted to fit both pie chart and legend
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
                    child: Row(
                      children: [
                        // PieChart
                        Container(
                          width: 220, // Ensuring the pie chart has enough space
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections:
                                  _generatePieChartSections(overallPercentage),
                              centerSpaceRadius: 0,
                            ),
                          ),
                        ),

                        // Legends inside the same box, placed after the pie chart
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(Colors.green, 'Present'),
                              SizedBox(height: 10),
                              _buildLegendItem(Colors.red, 'Absent'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Data Table with Vertical Scrolling
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.black, width: 2),
                      columns: const [
                        DataColumn(label: Text('Teacher')),
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Lectures Taken')),
                      ],
                      rows: dummyData.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(Text(entry['Teacher']!)),
                            DataCell(Text(entry['Subject']!)),
                            DataCell(Text(entry['Lectures']!)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(double percentage) {
    return [
      PieChartSectionData(
        color: Colors.green,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 100 - percentage,
        title: '${(100 - percentage).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}

Widget _buildLegendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
      SizedBox(width: 8),
      Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget _buildTransparentInfoButton(String text) {
  return InkWell(
    onTap: () {},
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}
