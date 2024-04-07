import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GIOW/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:GIOW/splash_screen.dart';

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
  await Future.delayed(const Duration(seconds: 2));
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
      title: 'GIOW',
      home: const SplashScreen(),
      routes: {'/home':(BuildContext context)=>HomeScreen(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin)}
    );
  }
}

