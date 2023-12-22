import 'package:flutter/material.dart';

class SnackBarService {
  static final SnackBarService _singleton = SnackBarService._internal();
  SnackBarService._internal();
  factory SnackBarService() {
    return _singleton;
  }
  showSnackBar(BuildContext context, String title, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Text(title),
      ),
    );
  }
}
