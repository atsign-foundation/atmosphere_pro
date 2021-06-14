import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'app.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HiveService().initHive();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(Size(1200, 700));
    await DesktopWindow.setMinWindowSize(Size(1200, 700));
  }
  runApp(MyApp());
}
