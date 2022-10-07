import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final double height;
  final double width;
  final String label;
  const SearchField(
      {required this.height, required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF939393),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: const ImageIcon(
            AssetImage(
              "assets/images/search_icon.png",
            ),
            color: Color(0xFF939393),
            size: 20.0,
          ),
          label: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF939393),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
