import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:desktop_window/desktop_window.dart';
import 'app.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AtSignLogger.root_level = 'finer';
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    await DesktopWindow.setWindowSize(Size(1200, 700));
    await DesktopWindow.setMinWindowSize(Size(1200, 700));
  } else if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(Size(1200, 700));
  }
  runApp(MyApp());
}
