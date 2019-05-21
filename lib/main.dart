import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_login.dart';

void main() => runApp(MyApp());

const Map<int, Color> orangeGradients = {
  50: Color(0xFFFF9844),
  100: Color(0xFFFE8853),
  200: Color(0xFFFD7267),
  300: Color(0xFFFD7267),
  400: Color(0xFFFD7267),
  500: Color(0xFFFD7267),
  600: Color(0xFFFD7267),
  700: Color(0xFFFD7267),
  800: Color(0xFFFD7267),
  900: Color(0xFFFD7267),
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFFF9844, orangeGradients),
      ),
      home: LoginScreen(),
    );
  }
}
