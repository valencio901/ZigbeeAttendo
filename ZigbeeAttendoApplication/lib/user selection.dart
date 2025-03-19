import 'package:ZigbeeAttendo/admin.dart';
import 'package:ZigbeeAttendo/teachers%20data.dart';
import 'package:flutter/material.dart';
import 'student login.dart';
import 'teacher login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student data.dart';
import 'admin login.dart';

class WhoAreYouPage extends StatefulWidget {
  const WhoAreYouPage({super.key});

  @override
  _WhoAreYouPageState createState() => _WhoAreYouPageState();
}

class _WhoAreYouPageState extends State<WhoAreYouPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if user is already logged in
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isStudent = prefs.getBool('isStudent') ?? false;
    bool isTeacher = prefs.getBool('isTeacher') ?? false;
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isLoggedIn && isStudent) {
      // Navigate to StudentDataPage if already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDataPage(),
        ),
      );
    }

    if (isLoggedIn && isTeacher) {
      // Navigate to StudentDataPage if already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherDataPage(),
        ),
      );
    }

    if (isLoggedIn && isAdmin) {
      // Navigate to StudentDataPage if already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AttendancePieChart(),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png', // Change to your image path
              height: 40, // Adjust size as needed
            ),
            const SizedBox(width: 10), // Spacing between logo and text
            const Text(
              'ZigbeeAttendo',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
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
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E1F9),
              Color(0xFFD0E1F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStyledButton(
                  context, 'Teacher', Icons.school, const TeacherLoginPage()),
              const SizedBox(height: 20),
              _buildStyledButton(
                  context, 'Student', Icons.person, const StudentLoginPage()),
              const SizedBox(height: 20),
              _buildStyledButton(context, 'Principal',
                  Icons.admin_panel_settings, AdminLoginPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(
      BuildContext context, String title, IconData icon, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: const Color(0xFF2980B9)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2980B9),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF2980B9)),
          ),
          shadowColor: const Color(0xFF2980B9).withOpacity(0.3),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        label: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WhoAreYouPage(),
  ));
}
