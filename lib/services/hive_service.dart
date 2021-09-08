import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveService {
  initHive() async {
    Directory downloadDirectory;
    if (Platform.isIOS || Platform.isMacOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    await Hive.init(downloadDirectory.path);
  }

  writeData(String boxName, key, value) async {
    var box = await Hive.openBox(boxName);
    await box.put(key, value);
    await box.close();
  }

  readData(String boxName, key) async {
    var box = await Hive.openBox(boxName);
    var result = box.get(key);
    await box.close();
    return result;
  }
}
