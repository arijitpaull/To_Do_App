import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings =
      InitializationSettings(
          android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
}

class MyApp extends StatelessWidget {
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  MyApp({super.key, required this.flutterLocalNotificationsPlugin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do',
      home: HomeScreen( flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,),
    );
  }
}

