import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.email, color: Colors.white),
                title: Text('Email', style: TextStyle(color: Colors.white)),
                subtitle: Text('info@company.com',
                    style: TextStyle(color: Colors.white70)),
              ),
              const ListTile(
                leading: Icon(Icons.phone, color: Colors.white),
                title:
                    Text('Phone Number', style: TextStyle(color: Colors.white)),
                subtitle: Text('+1 234 567 890',
                    style: TextStyle(color: Colors.white70)),
              ),
              const ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text('Founder', style: TextStyle(color: Colors.white)),
                subtitle:
                    Text('John Doe', style: TextStyle(color: Colors.white70)),
              ),
              const ListTile(
                leading: Icon(Icons.location_on, color: Colors.white),
                title: Text('Office Address',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text('123, Main Street, City, Country',
                    style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'We strive to provide the best services to our customers. '
                  'Feel free to reach out to us with any queries!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutUsPage(),
  ));
}
