import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';

/// Custom button widget [isInverted] toggles between black and white button,
/// [isInverted=false] by default, if true bg color and border color goes [white]
/// from [black], text color goes [black] from [white].
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool isInverted;
  final Function() onPressed;
  final String buttonText;
  final double height;
  final double width;

  const CustomButton(
      {Key key, this.isInverted = false, this.onPressed, this.buttonText, this.height, this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? 158.toWidth,
        height: height ?? 50.toHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.toWidth),
            color: (isInverted) ? Colors.white : Colors.black),
        child: Center(
          child: Text(
            buttonText,
            style: (isInverted) ? CustomTextStyles.primaryBold16 : CustomTextStyles.whiteBold16,
          ),
        ),
      ),
    );
  }
}
