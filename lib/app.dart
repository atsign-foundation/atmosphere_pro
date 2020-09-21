import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'routes/routes.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtSign Atmosphere App',
      debugShowCheckedModeBanner: false,
      initialRoute: SetupRoutes.initialRoute,
      routes: SetupRoutes.routes,
    );
  }
}
