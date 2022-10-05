import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  final String atSign;
  const PopUp({required this.atSign});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: 207.0,
          width: 244.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 32),
              const Text(
                'Are you sure that you want to',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                atSign,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // function to remove here
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 28.0,
                  width: 115.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFF939393),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Color(0xFF939393),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 11),
                      CircleAvatar(
                        radius: 9.0,
                        backgroundColor: Colors.green.withOpacity(0.25),
                        child: const ImageIcon(
                          AssetImage("assets/images/confirm_icon.png"),
                          color: Color(0xFF939393),
                          size: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFA4A4A5),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 10.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
