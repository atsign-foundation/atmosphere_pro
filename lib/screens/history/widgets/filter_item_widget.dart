import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterItemWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String prefixIcon;
  final String title;

  const FilterItemWidget({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.prefixIcon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(12, 7, 8, 8),
      margin: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(prefixIcon),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
