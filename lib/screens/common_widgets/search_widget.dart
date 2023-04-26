import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class SearchWidget extends StatefulWidget {
  final Color? backgroundColor, borderColor;
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? margin;

  const SearchWidget({
    Key? key,
    this.backgroundColor,
    this.borderColor,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.margin,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.toHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.backgroundColor,
      ),
      margin: widget.margin ??
          EdgeInsets.symmetric(
            horizontal: 32.toWidth,
            vertical: 18.toHeight,
          ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: widget.borderColor ?? ColorConstants.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: widget.borderColor ?? ColorConstants.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.only(top: 12, left: 14),
          hintStyle: widget.hintStyle ??
              TextStyle(
                fontSize: 14.toFont,
                color: ColorConstants.grey,
                fontWeight: FontWeight.normal,
              ),
          suffixIcon: const Icon(
            Icons.search,
            color: ColorConstants.darkSliver,
          ),
          hintText: widget.hintText ?? 'Search by atSign or nickname',
        ),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 14.toFont,
          color: ColorConstants.fontPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
