import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_login.dart';

void main() => runApp(Main());

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

class Main extends StatelessWidget {
  static void toScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  static void popScreens(BuildContext context, int count) {
    for (var i = 0; i < count; i++) {
      Navigator.pop(context);
    }
  }

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
