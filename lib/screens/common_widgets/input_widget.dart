import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/gradient_outline_input_border.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextEditingController? controller;
  final Function(String value)? onchange;
  final Function(String value)? onSubmitted;
  final String? prefixText;
  final TextStyle? prefixStyle;

  const InputWidget({
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
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59.toHeight,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Colors.white,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintTextStyle ??
              TextStyle(
                fontSize: 14.toFont,
                fontWeight: FontWeight.w400,
                color: ColorConstants.grey,
              ),
        ),
      ),
    );
  }
}
