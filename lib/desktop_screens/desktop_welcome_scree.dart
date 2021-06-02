import 'package:flutter/material.dart';

class DesktopWelcomeScreen extends StatefulWidget {
  @override
  _DesktopWelcomeScreenState createState() => _DesktopWelcomeScreenState();
}

class _DesktopWelcomeScreenState extends State<DesktopWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        child: Text('Click me'),
      )),
    );
  }
}
