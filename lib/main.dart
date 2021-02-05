import 'package:atsign_atmosphere_app/services/hive_service.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

  // });
  WidgetsFlutterBinding.ensureInitialized();
  HiveService().initHive();
  runApp(MyApp());
}
