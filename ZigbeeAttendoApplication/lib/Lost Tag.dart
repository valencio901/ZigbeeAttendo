import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LostTagPage extends StatefulWidget {
  @override
  _LostTagPageState createState() => _LostTagPageState();
}

class _LostTagPageState extends State<LostTagPage> {
  final TextEditingController rollnoController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  final TextEditingController reportController = TextEditingController();

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Report Status',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Reported to the office',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitReport() async {
    const String url =
        'https://4ead-2409-4042-6e93-1402-fc49-6139-be16-c6c9.ngrok-free.app/insert_report.php';

    final response = await http.post(Uri.parse(url), body: {
      'rollno': rollnoController.text,
      'class': classController.text,
      'classroom': classroomController.text,
      'report': reportController.text,
    });

    if (response.statusCode == 200) {
      _showAlertDialog();
    } else {
      print('Failed to submit report');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Lost Tag', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9), // Light Blue
                Color.fromARGB(255, 248, 251, 255), // Lighter Blue
                Color(0xFFD0E1F9) // Light Blue again
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 800,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9), // Light Blue
                Color(0xFFD0E1F9), // Light Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Lost Tag Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: rollnoController,
                decoration: const InputDecoration(
                  labelText: 'Roll No',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: classroomController,
                decoration: const InputDecoration(
                  labelText: 'Classroom',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reportController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Report',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0E1F9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: Colors.black,
                          width: 2), // Add black border here
                    ),
                  ),
                  onPressed: () {
                    submitReport();
                  },
                  child: const Text('Report to Office'),
                ),
              ),
              // This is the extra space you want to avoid, so we avoid leaving extra space.
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LostTagPage(),
  ));
}
