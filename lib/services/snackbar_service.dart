import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class SnackbarService {
  static final SnackbarService _singleton = SnackbarService._internal();

  SnackbarService._internal();

  factory SnackbarService() {
    return _singleton;
  }

  showSnackbar(BuildContext context, String title, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Text(title),
      ),
    );
  }

  void showNotification(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    Flushbar(
      backgroundColor: ColorConstants.orangeColor,
      titleText: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(10),
      margin: EdgeInsets.symmetric(horizontal: 8),
    ).show(context);
  }
}
