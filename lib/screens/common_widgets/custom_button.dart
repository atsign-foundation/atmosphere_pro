import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';

/// Custom button widget [isInverted] toggles between black and white button,
/// [isInverted=false] by default, if true bg color and border color goes [white]
/// from [black], text color goes [black] from [white].
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool isInverted;
  final Function()? onPressed;
  final String? buttonText;
  final double? height;
  final double? width;
  final bool isOrange;

  const CustomButton(
      {Key? key,
      this.isInverted = false,
      this.onPressed,
      this.buttonText,
      this.height,
      this.width,
      this.isOrange = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: width ?? 158.toWidth,
        height: height ?? (50.toHeight),
        padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.toWidth),
            color: (isOrange)
                ? Color(0xffF05E3E)
                : (isInverted)
                    ? Colors.white
                    : Colors.black),
        child: Center(
          child: Text(
            buttonText!,
            textAlign: TextAlign.center,
            style: (isInverted)
                ? CustomTextStyles.primaryBold16
                : TextStyle(
                    color: Colors.white,
                    fontSize: 16.toFont,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w700,
                  ),
          ),
        ),
      ),
    );
  }
}
