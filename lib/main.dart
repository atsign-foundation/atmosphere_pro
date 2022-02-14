import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AtSignLogger.root_level = 'finer';
  runApp(MyApp());
}
