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
    await DesktopWindow.setWindowSize(Size(1280, 832));
    await DesktopWindow.setMinWindowSize(Size(1280, 832));
  } else if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(Size(1280, 832));
  }
  runApp(MyApp());
}
