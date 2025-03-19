import 'dart:convert'; // Import the 'dart:convert' package to decode JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AttendanceExcelPage extends StatefulWidget {
  const AttendanceExcelPage({super.key});

  @override
  _AttendanceExcelPageState createState() => _AttendanceExcelPageState();
}

class _AttendanceExcelPageState extends State<AttendanceExcelPage> {
  List<String> excelFiles = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchExcelFiles();
  }

  // Function to fetch the list of Excel files from the server
  Future<void> _fetchExcelFiles() async {
    try {
      final response = await http.get(Uri.parse(
          'https://8892-2409-4042-6e98-bbe2-1915-272e-c03e-d5cc.ngrok-free.app/list_files.php'));

      if (response.statusCode == 200) {
        List<dynamic> decodedResponse = json.decode(response.body);
        setState(() {
          excelFiles = List<String>.from(decodedResponse);
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Function to launch the URL for downloading the file
  Future<void> _downloadFile(String fileName) async {
    final fileUrl =
        'https://8892-2409-4042-6e98-bbe2-1915-272e-c03e-d5cc.ngrok-free.app/excels/$fileName';

    final Uri uri = Uri.parse(fileUrl);

    print("Trying to open: $fileUrl"); // Debugging

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Forces external browser
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: $fileName\nURL: $fileUrl'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Excel Files',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9), // Light Blue
                Color(0xFFD0E1F9),
                Color.fromARGB(255, 243, 247, 251), // Lighter shade of blue
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E1F9), // Light Blue
              Color(0xFFD0E1F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text(
                      'Failed to load files. Please check your connection.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  )
                : excelFiles.isEmpty
                    ? const Center(
                        child: Text(
                          'No Excel files available.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.builder(
                        itemCount: excelFiles.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFD0E1F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                excelFiles[index],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.blueAccent),
                                onPressed: () =>
                                    _downloadFile(excelFiles[index]),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
