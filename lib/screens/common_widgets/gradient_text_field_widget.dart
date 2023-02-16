import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/gradient_outline_input_border.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class GradientTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextEditingController? controller;
  final Function(String value)? onchange;
  final Function(String value)? onSubmitted;
  final String? prefixText;
  final TextStyle? prefixStyle;

  const GradientTextFieldWidget({
    Key? key,
    this.hintText,
    this.controller,
    this.hintTextStyle,
    this.onchange,
    this.onSubmitted,
    this.prefixText,
    this.prefixStyle,
  }) : super(key: key);

  @override
  State<GradientTextFieldWidget> createState() =>
      _GradientTextFieldWidgetState();
}

class _GradientTextFieldWidgetState extends State<GradientTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: widget.controller,
        onChanged: (value) {
          widget.onchange?.call(value);
        },
        onFieldSubmitted: (value) {
          widget.onSubmitted?.call(value);
        },
        style: TextStyle(
          fontSize: 14.toFont,
        ),
        decoration: InputDecoration(
          prefixText: widget.prefixText,
          prefixStyle: widget.prefixStyle,
          border: GradientOutlineInputBorder(
            gradient: LinearGradient(
              colors: [
                ColorConstants.orangeColor,
                ColorConstants.yellow.withOpacity(0.65),
              ],
            ),
            width: 2,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: GradientOutlineInputBorder(
            gradient: LinearGradient(
              colors: [
                ColorConstants.orangeColor,
                ColorConstants.yellow.withOpacity(0.65),
              ],
            ),
            width: 2,
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintTextStyle ??
              TextStyle(
                fontSize: 12.toFont,
                fontWeight: FontWeight.w400,
                color: ColorConstants.grey,
              ),
        ),
      ),
    );
  }
}
