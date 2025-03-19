import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
      ),
    );
  }

  static void onStart(ServiceInstance service) {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });

      service.on('stopService').listen((event) {
        service.stopSelf();
      });
    }

    final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.43.61:8080'),
    );

    channel.stream.listen((message) async {
      print("Database change detected: $message");
      await handleDatabaseChange(message); // ✅ Fix: Use await
    });
  }

  static Future<void> handleDatabaseChange(String message) async {
    final Map<String, dynamic> data = jsonDecode(message);
    String database = data['database_name'];
    String table = data['table_name'];
    String action = data['action'];
    String teacher_name = data['new_teacher'];
    String old_teacher_name = data['old_teacher'];

    final prefs = await SharedPreferences.getInstance();
    String? classs = prefs.getString('classValue');
    bool? isStudent = prefs.getBool('isStudent');
    bool? isTeacher = prefs.getBool('isTeacher');
    String? teacher = prefs.getString('teacher');
    bool? isPrincipal = prefs.getBool('isPrincipal');

    String getCurrentWeekday() {
      List<String> days = [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday"
      ];
      return days[
          DateTime.now().weekday - 1]; // Subtract 1 since list is 0-based
    }

    String today = getCurrentWeekday();

    if (classs != null && // 
        database == classs &&
        old_teacher_name != teacher_name &&
        table == today && isStudent == true &&
        (action == "update")) {
      NotificationService.showNotification(
        title: "Today's Schedule Updated",
        body: "Please check the new schedule",
      );
    }

    String cancelled_lecture = data['cancelled_lecture'];

    if (classs != null && //
        database == classs &&
        old_teacher_name != teacher_name &&
        table == today &&
        isStudent == true &&
        (action == "delete")) {
      NotificationService.showNotification(
        title: "Lecture Cancelled",
        body: "$cancelled_lecture cancelled",
      );
    }

    if (table == today &&
        isTeacher == true &&
        teacher_name == teacher &&
        teacher != old_teacher_name &&
        (action == "update" || action == "delete")) {
      NotificationService.showNotification(
        title: "You Have Been Given A Lecture",
        body: "$old_teacher_name gave you their lecture",
      );
    }

    Future<List<String>> getClassesOfTeacher() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList("teacher_classes") ?? [];
  }

  List<String> classes = await getClassesOfTeacher();
  print("Classes retrieved: $classes");
  print(table);
  print(isTeacher);
  print(database);
  print(action);

    if (table == today &&
        isTeacher == true &&
        classes.contains(database) &&
        (action == "insert")) {
          print("principal changed");
      NotificationService.showNotification(
        title: "Lectures Schedule Has Been Changed By Principal",
        body: "please check the new schedule",
      );
    }

    String student = data['student_name'];

    if(table == "student_report" && isPrincipal == true){
        NotificationService.showNotification(
        title: "New Student Report",
        body: "$student reported",
      );
    }

  }
}
