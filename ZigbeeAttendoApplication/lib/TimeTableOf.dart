import 'package:flutter/material.dart';
import 'TiimeTables.dart';

class Timetableof extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SELECT CLASS",style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w500),),
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
        iconTheme:
            const IconThemeData(color: Colors.black), // Set icon color to black
      ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SingleChildScrollView for horizontally scrolling buttons
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

  // This method builds a row of 2 buttons with icons before text
  Widget _buildButtonRow(BuildContext context, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the buttons horizontally
        children: labels
            .map((label) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _buildTransparentButton(context, label),
                ))
            .toList(),
      ),
    );
  }

  // This method builds each individual button with the icon before the text
  Widget _buildTransparentButton(BuildContext context, String label) {
    return Container(
      height: 100,
      width: 150,
      child: TextButton(
        onPressed: () {
          // Navigate to the TimetablePage and pass the class name
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchedulePage(databaseName: label),
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.black, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            // Icon before the text
            Icon(
              Icons.calendar_today, // The icon to represent class timetable
              color: const Color.fromARGB(255, 34, 11, 122),
              size: 24,
            ),
            SizedBox(width: 8), // Add space between icon and text
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
