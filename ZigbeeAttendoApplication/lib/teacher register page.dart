import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherRegisterPage extends StatefulWidget {
  const TeacherRegisterPage({super.key});

  @override
  _TeacherRegisterPageState createState() => _TeacherRegisterPageState();
}

class _TeacherRegisterPageState extends State<TeacherRegisterPage> {
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerTeacher() async {
    final url = Uri.parse(
        'https://8892-2409-4042-6e98-bbe2-1915-272e-c03e-d5cc.ngrok-free.app/register_teacher.php'); // Your PHP backend URL

    final response = await http.post(url, body: {
      'teacher_name': teacherNameController.text,
      'phone_number': phoneNumberController.text,
      'address': addressController.text,
      'password': passwordController.text,
    });

    if (response.statusCode == 200) {
      // Handle successful registration
      print('Teacher registration successful');
    } else {
      // Handle error
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                    'Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  _buildTextField(teacherNameController, 'Name'),
                  _buildTextField(phoneNumberController, 'Phone Number'),
                  _buildTextField(addressController, 'Address'),
                  _buildTextField(passwordController, 'Password',
                      obscureText: false),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: registerTeacher,
                    child: const Text(
                      'Register',
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
                        borderRadius: BorderRadius.circular(
                            30), // Adjust this value for more rounded edges
                        side: BorderSide(color: Color(0xFF2980B9)),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        obscureText: obscureText,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
