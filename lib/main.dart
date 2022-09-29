import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AtSignLogger.root_level = 'finer';
  if (Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(Size(1200, 700));
    await DesktopWindow.setMinWindowSize(Size(1200, 700));
  } else if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(Size(1200, 700));
  }
  runApp(MyApp());
}
