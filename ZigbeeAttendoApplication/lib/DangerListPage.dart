import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DangerListPage extends StatefulWidget {
  final String className;

  DangerListPage({required this.className});

  @override
  _DangerListPageState createState() => _DangerListPageState();
}

class _DangerListPageState extends State<DangerListPage> {
  List<dynamic> dangerListData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchDangerListData();
  }

  Future<void> fetchDangerListData() async {
    final String url =
        "https://2aef-2409-4042-6e80-9e99-89b1-e60b-d035-6092.ngrok-free.app/below_75.php?className=${widget.className}";

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          dangerListData = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Defaulter List for Class: ${widget.className}',
            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9), // Light Blue
                Color(0xFFD0E1F9), // Same color for consistency
                Color.fromARGB(255, 243, 247, 251), // Lighter shade of blue
                Color(0xFFD0E1F9), // Light Blue
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
              Color(0xFFD0E1F9), // Light Blue for the full body
              Color(0xFFD0E1F9), // Same color for consistency
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : hasError
                  ? Center(child: Text('Failed to load danger list data'))
                  : Column(
                      children: [
                        // Displaying the danger list data in a DataTable
                        dangerListData.isEmpty
                            ? Center(child: Text('No students in danger list'))
                            : Column(
                                children: [
                                  Text(
                                    'Students with Attendance Below 75%',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 20),

                                  // Wrapping the DataTable with a SingleChildScrollView for horizontal scrolling
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      height:
                                          400, // Set the height for vertical scrolling
                                      child: SingleChildScrollView(
                                        scrollDirection:
                                            Axis.vertical, // Vertical scrolling
                                        child: DataTable(
                                          border: TableBorder.all(
                                            color: Colors
                                                .black, // Color for column and row borders
                                            width: 2, // Border width
                                          ),
                                          columns: const [
                                            DataColumn(label: Text('Roll No')),
                                            DataColumn(label: Text('Subject')),
                                            DataColumn(
                                                label: Text('Total Lectures')),
                                            DataColumn(
                                                label:
                                                    Text('Attended Lectures')),
                                            DataColumn(
                                                label: Text('Attendance %')),
                                          ],
                                          rows: dangerListData
                                              .map<DataRow>((entry) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(entry['rollno']
                                                    .toString())),
                                                DataCell(
                                                    Text(entry['subject'])),
                                                DataCell(Text(
                                                    entry['total_lectures']
                                                        .toString())),
                                                DataCell(Text(
                                                    entry['attended_lectures']
                                                        .toString())),
                                                DataCell(Text(
                                                    '${entry['attendance_percentage']}%')),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(height: 20),
                      ],
                    ),
        ),
      ),
    );
  }
}
