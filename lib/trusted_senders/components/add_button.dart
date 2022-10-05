import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // function to add here
      },
      child: Container(
        height: 59,
        width: 320,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],

          gradient: LinearGradient(
            colors: [
              const Color(0xFFF05E37),
              const Color(0xFFEAA743).withOpacity(0.65),
            ],
            stops: const [
              0.18,
              0.90,
            ],
            transform: const GradientRotation(1.16)
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            ImageIcon(
              AssetImage("assets/images/add_icon.png"),
              color: Colors.white,
              size: 16.0,
            ),
            SizedBox(width: 10),
            Text(
              'Add atSign',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
