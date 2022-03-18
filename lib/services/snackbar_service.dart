import 'package:flutter/material.dart';

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
}
