import 'package:at_common_flutter/services/size_config.dart';
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
  final bool? isRequired;

  const InputWidget({
    Key? key,
    this.hintText,
    this.controller,
    this.hintTextStyle,
    this.onchange,
    this.onSubmitted,
    this.prefixText,
    this.prefixStyle,
    this.isRequired,
  }) : super(key: key);

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: (value) {
        if (widget.prefixText != null) {
          setState(() {
            isEdit = value;
          });
        }
      },
      child: Container(
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
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            prefix: widget.prefixText != null
                ? Text(
                    widget.prefixText!,
                    style: TextStyle(
                      fontSize: 14.toFont,
                    ),
                  )
                : null,
            prefixStyle: widget.prefixStyle,
            label: widget.isRequired ?? false
                ? RichText(
                    text: TextSpan(
                      text: widget.hintText,
                      style: TextStyle(
                        fontSize: 14.toFont,
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.grey,
                      ),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            fontSize: 14.toFont,
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.orange,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            floatingLabelBehavior: FloatingLabelBehavior.never,
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
      ),
    );
  }
}
