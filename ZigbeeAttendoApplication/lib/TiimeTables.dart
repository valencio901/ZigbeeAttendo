import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SchedulePage extends StatefulWidget {
  final String databaseName;

  SchedulePage({required this.databaseName});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Map<String, List<dynamic>> schedule = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    fetchSchedule();
  }

  @override
  void dispose() {
    // Reset to normal orientation when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> fetchSchedule() async {
    final url = Uri.parse(
        "https://8837-103-65-197-222.ngrok-free.app/get_schedule.php?dbname=${widget.databaseName}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        schedule = Map<String, List<dynamic>>.from(json.decode(response.body));
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load schedule");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Schedule',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                padding: const EdgeInsets.all(16.0),
                children: schedule.entries.map((entry) {
                  String day = entry.key;
                  List<dynamic> lectures = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(
                        right: 12), // Add horizontal spacing
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        day.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: lectures.isEmpty
                          ? [
                              const ListTile(
                                title: Text("No lectures available",
                                    style: TextStyle(color: Colors.black)),
                              )
                            ]
                          : lectures.map((lecture) {
                              return ListTile(
                                title: Text(
                                  lecture['lecture'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Teacher: ${lecture['teacher']}\nTime: ${lecture['start_time']} - ${lecture['end_time']}",
                                  style: const TextStyle(color: Colors.black),
                                ),
                                trailing: Text("Room: ${lecture['classroom']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
