import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class DesktopCustomInputField extends StatelessWidget {
  final String hintText, initialValue;
  final double width, height;
  final IconData? icon;
  final Function? onTap, onIconTap, onSubmitted;
  final Color? iconColor, backgroundColor;
  final ValueChanged<String>? value;
  final bool isReadOnly;

  TextEditingController textController = TextEditingController();

  DesktopCustomInputField(
      {Key? key,
      this.hintText = '',
      this.height = 50,
      this.width = 300,
      this.iconColor,
      this.icon,
      this.onTap,
      this.onIconTap,
      this.value,
      this.initialValue = '',
      this.onSubmitted,
      this.backgroundColor,
      this.isReadOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    textController = TextEditingController.fromValue(TextEditingValue(
        text: initialValue,
        selection: TextSelection.collapsed(
            offset: initialValue.isNotEmpty ? initialValue.length : -1)));
    return Container(
      width: width.toWidth,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor ?? ColorConstants.inputFieldColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: ColorConstants.light_grey)),
      padding: EdgeInsets.fromLTRB(10.toWidth, 0, 10.toWidth, 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextField(
                readOnly: isReadOnly,
                style: TextStyle(
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: ColorConstants.light_grey,
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onTap: onTap as void Function()? ?? () {},
                onChanged: (val) {
                  value!(val);
                },
                controller: textController,
                onSubmitted: (str) {
                  if (onSubmitted != null) {
                    onSubmitted!(str);
                  }
                },
              ),
            ),
            icon != null
                ? InkWell(
                    onTap: onIconTap as void Function()? ??
                        onTap as void Function()?,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Icon(
                        icon,
                        color: iconColor ?? ColorConstants.fadedText,
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
