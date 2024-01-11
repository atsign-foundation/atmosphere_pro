import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopAddGroupProvider extends ChangeNotifier {
  String groupName = '';
  Uint8List? selectedImageByteData;

  void setSelectedImageByteData(Uint8List data) {
    AppUtils.checkGroupImageSize(
      image: data,
      onSatisfy: (value) {
        selectedImageByteData = value;
        notifyListeners();
      },
    );
  }

  void setGroupName(String value) {
    groupName = value;
    notifyListeners();
  }
}
