import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'app.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HiveService().initHive();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1200, 700));
    setWindowMaxSize(Size.infinite);
  }
  runApp(MyApp());
}
