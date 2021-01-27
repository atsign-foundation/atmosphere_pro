import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  HiveService().initHive();
  runApp(MyApp());
}
