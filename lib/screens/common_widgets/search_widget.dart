import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final Color? backgroundColor, borderColor;
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? margin;
  final Function(String value)? onChange;
  final bool? readOnly;
  final Function()? onTap;
  final bool? autoFocus;

  const SearchWidget({
    Key? key,
    this.backgroundColor,
    this.borderColor,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.margin,
    this.onChange,
    this.readOnly,
    this.onTap,
    this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.toHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
      ),
      margin: margin ??
          EdgeInsets.symmetric(
            horizontal: 32.toWidth,
            vertical: 18.toHeight,
          ),
      child: TextFormField(
        controller: controller,
        autofocus: autoFocus ?? false,
        readOnly: readOnly ?? false,
        onTap: onTap,
        onChanged: (value) {
          onChange?.call(value);
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: borderColor ?? ColorConstants.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: borderColor ?? ColorConstants.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.only(top: 12, left: 14),
          hintStyle: hintStyle ??
              TextStyle(
                fontSize: 14.toFont,
                color: ColorConstants.grey,
                fontWeight: FontWeight.normal,
              ),
          suffixIcon: controller.text.isEmpty
              ? const Icon(
                  Icons.search,
                  color: ColorConstants.darkSliver,
                )
              : InkWell(
                  onTap: () {
                    controller.clear();
                    onChange?.call('');
                  },
                  child: const Icon(
                    Icons.close,
                    color: ColorConstants.darkSliver,
                  ),
                ),
          hintText: hintText ?? 'Search by atSign or nickname',
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
