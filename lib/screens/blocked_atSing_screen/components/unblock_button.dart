import 'package:flutter/material.dart';
import 'pop_up.dart';

class UnblockButton extends StatelessWidget {
  final String atSign;
  const UnblockButton({required this.atSign});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PopUp(atSign: atSign, title: 'Unblock', tapFunction: () {}),
        );
      },
      child: Container(
        height: 31.0,
        width: 118.0,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          border: Border.all(
            color: const Color(0xFF939393),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Unblock?',
                style: TextStyle(
                  color: Color(0xFF939393),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
              CircleAvatar(
                radius: 8.335,
                backgroundColor: const Color(0xFFFF461F).withOpacity(0.35),
                child: const ImageIcon(
                  AssetImage("assets/images/block_icon.png"),
                  color: Color(0xFFF05E3F),
                  size: 16.67,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
