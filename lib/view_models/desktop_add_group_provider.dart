import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopAddGroupProvider extends ChangeNotifier {
  String groupName = '';
  Uint8List? selectedImageByteData;

  void setSelectedImageByteData(Uint8List? data) {
    selectedImageByteData = data;
    notifyListeners();
  }

  void setGroupName(String value) {
    groupName = value;
    notifyListeners();
  }
}
