import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Permission.notification.status.then((value) async {
      if (value != PermissionStatus.granted) {
        await Permission.notification.request();
      }
    });
  }
  // AtSignLogger.root_level = 'finer';
  if (Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(1200, 700));
    await DesktopWindow.setMinWindowSize(const Size(1200, 700));
  } else if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(const Size(1200, 700));
  }
  runApp(const MyApp());
}
