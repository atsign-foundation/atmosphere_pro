import 'package:flutter/material.dart';

class ClosePillButton extends StatelessWidget {
  const ClosePillButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 31.0,
        width: 106.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF939393),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'close',
            style: TextStyle(
              color: Color(0xFF939393),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 17.0,
            ),
          ),
        ),
      ),
    );
  }
}
