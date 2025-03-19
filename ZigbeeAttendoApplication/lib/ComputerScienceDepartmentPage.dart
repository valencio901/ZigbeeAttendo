import 'package:flutter/material.dart';
import 'Attendance.dart'; // Import the attendance page

class ComputerScienceDepartmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildButtonRow(context, ['FYBCA A', 'FYBCA B']),
                  _buildButtonRow(context, ['SYBCA A', 'SYBCA B']),
                  _buildButtonRow(context, ['TYBCA A', 'TYBCA B']),
                  _buildButtonRow(context, ['FYBVOC A', 'FYBVOC B']),
                  _buildButtonRow(context, ['SYBVOC A', 'SYBVOC B']),
                  _buildButtonRow(context, ['TYBVOC A', 'TYBVOC B']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: labels
            .map((label) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _buildTransparentButton(context, label),
                ))
            .toList(),
      ),
    );
  }

  // Button with `Icons.fact_check` before text
  Widget _buildTransparentButton(BuildContext context, String label) {
    return SizedBox(
      height: 100,
      width: 150, // Adjust width slightly for better spacing
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(className: label),
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Make row as small as possible
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            const Icon(Icons.bar_chart, color: Color.fromARGB(255, 71, 31, 214), size: 20), // Icon// Space between icon and text
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
