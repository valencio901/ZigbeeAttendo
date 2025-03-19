import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'student data.dart';
import 'register.dart';
import 'package:lottie/lottie.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController rollnoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedClass;
  String? errorMessage;

  // List of class options for the dropdown
  final List<String> classes = [
    'tybca_a',
    'tybca_b',
    'sybca_a',
    'sybca_b',
    'fybca_a',
    'fybca_b',
  ];



  Future<void> login() async {
    String rollno = rollnoController.text;
    String password = passwordController.text;
    String classValue = selectedClass ?? ''; // Get the selected class value
 
    if (rollno.isEmpty || password.isEmpty || classValue.isEmpty) {
      setState(() {
        errorMessage = "Please enter roll number, password, and select class.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://c6b3-2409-4042-6e9d-d9e2-b899-5a0f-df00-694d.ngrok-free.app/student_login/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rollno': rollno,
          'password': password,
          'db': classValue, // Send class value
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Store session data in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setBool('isStudent', true);          
          await prefs.setString('rollno', rollno);
          await prefs.setString('classValue', classValue);

          // Show Lottie animation before navigating
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent closing the dialog manually
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/login_successful.json', repeat: false),
                    SizedBox(height: 10),
                    Text(
                      "Login Successful!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );

// Wait for the animation to complete, then navigate
          await Future.delayed(Duration(seconds: 2));

// Close the animation dialog
          Navigator.pop(context);

// Navigate to StudentDataPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentDataPage()),
          );
        } else {
          setState(() {
            errorMessage = data['message'] ??
                "Login failed. Please check your credentials.";
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E1F9), Color(0xFFD0E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 375,
            height: 667,
            decoration: BoxDecoration(
              color: Color(0xFFD0E1F9),
              borderRadius: BorderRadius.circular(36),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: rollnoController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: InputDecoration(
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
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2980B9),
                      shadowColor: Colors.black.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Color(0xFF2980B9)),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
