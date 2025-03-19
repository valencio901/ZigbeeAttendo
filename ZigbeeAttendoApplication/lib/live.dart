import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class WebSocketMessagePage extends StatefulWidget {
  @override
  _WebSocketMessagePageState createState() => _WebSocketMessagePageState();
}

class _WebSocketMessagePageState extends State<WebSocketMessagePage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(
        'ws://192.168.43.61:8081'), // Update with your new WebSocket server URL and port
  );

  String? selectedClass; // Variable to hold the selected class (db name)
  List<Map<String, dynamic>> receivedMessages =
      []; // List to store received WebSocket messages

  final List<String> classes = [
    'tybca_a',
    'tybca_b',
    'sybca_a',
    'sybca_b',
    'fybca_a',
    'fybca_b',
  ];

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data != null && data['database'] != null && data['logs'] != null) {
        setState(() {
          // Instead of replacing, we append the new messages to the list
          receivedMessages
              .addAll(List<Map<String, dynamic>>.from(data['logs']));
        });
      }
    });
  }

  // Function to format timestamp to time only
  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);

    // If the timestamp is in UTC, you can convert it to local time using toLocal()
    DateTime localDateTime = dateTime.toLocal();

    // Format the time as 'HH:mm:ss' (24-hour format)
    return DateFormat('HH:mm:ss').format(localDateTime);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMessages = selectedClass == null
        ? receivedMessages
        : receivedMessages
            .where((message) => message['class'] == selectedClass)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Messages'),
        backgroundColor: Color(0xFF2980B9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: InputDecoration(
                labelText: 'Select Class',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              items: classes.map((String classItem) {
                return DropdownMenuItem<String>(
                  value: classItem,
                  child: Text(
                    classItem,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Display all the messages inside the ListView
            Expanded(
              child: ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                        message['rollno'].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        message['action'].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        formatTimestamp(
                            message['timestamp']), // Convert timestamp to time
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
