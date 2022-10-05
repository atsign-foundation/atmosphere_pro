import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.0,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF939393),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: const ImageIcon(
            AssetImage(
                "assets/images/search_icon.png"),
            color: Color(0xFF939393),
            size: 20.0,
          ),
          label: const Text(
            'Search by atSign or nickname',
            style: TextStyle(
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
