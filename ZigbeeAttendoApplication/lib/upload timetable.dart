import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  String? _filePath;
  String _message = "";

  // Function to pick file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  // Function to upload file to the server
  Future<void> _uploadFile() async {
    if (_filePath == null) {
      setState(() {
        _message = "Please pick a file first!";
      });
      return;
    }

    File file = File(_filePath!);

    var uri = Uri.parse(
        'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/upload_timetable.php'); // Replace with your server's URL
    var request = http.MultipartRequest('POST', uri);

    // Add file to the request
    var fileBytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
        filename: basename(file.path)));

    // Send the request
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _message = "File uploaded successfully!";
        });
      } else {
        setState(() {
          _message = "Failed to upload the file!";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Time Table',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD0E1F9),
                Color(0xFFD0E1F9),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTransparentButton(context, "Pick an Excel file", _pickFile),
            const SizedBox(height: 20),
            if (_filePath != null) Text("Selected File: $_filePath"),
            const SizedBox(height: 20),
            _buildTransparentButton(context, "Upload File", _uploadFile),
            const SizedBox(height: 20),
            Text(_message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Transparent button with consistent styling
  Widget _buildTransparentButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      width: 250,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file,
                color: Color.fromARGB(255, 71, 31, 214), size: 20), // Icon
            const SizedBox(width: 8), // Space between icon and text
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
