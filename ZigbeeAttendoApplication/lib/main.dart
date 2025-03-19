import 'package:flutter/material.dart';
import 'background_service.dart';
import 'notification_service.dart';
import 'user selection.dart'; // Ensure correct import (remove space in filename)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initialize();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'AATS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WhoAreYouPage(), // Ensure this is correctly imported
    );
  }
}
