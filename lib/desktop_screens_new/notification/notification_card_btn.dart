import 'package:flutter/material.dart';

class NotificationCardButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  const NotificationCardButton({
    Key? key,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: backgroundColor),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: child);
  }
}
