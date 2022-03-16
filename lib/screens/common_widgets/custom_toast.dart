import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  CustomToast._();
  static final CustomToast _instance = CustomToast._();
  factory CustomToast() => _instance;

  show(String text, BuildContext context,
      {Color? bgColor, Color? textColor, int duration = 3, int gravity = 0}) {
    // ignore: always_declare_return_types
    show(String text, BuildContext context,
        {Color? bgColor, Color? textColor, int duration = 3, int gravity = 0}) {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        FlutterToastr.show(text, context,
            duration: FlutterToastr.lengthLong,
            backgroundColor: bgColor ?? ColorConstants.orangeColor,
            textStyle: TextStyle(color: Colors.white));
      } else {
        Fluttertoast.showToast(
            msg: text,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: bgColor ?? ColorConstants.orangeColor,
            textColor: textColor ?? Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
