import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final Function()? onPressed;
  final String? buttonText;
  final double? height;
  final double? width;
  final double? thickness;
  final Widget? child;
  final Color? borderColor;
  final double? radius;

  const CustomOutlinedButton({
    Key? key,
    this.onPressed,
    this.buttonText,
    this.height,
    this.width,
    this.thickness,
    this.borderColor,
    this.radius,
    this.child,
  }) : super(key: key);
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
          border: Border.all(
            color: borderColor ?? ColorConstants.outlineGrey,
            width: thickness ?? 1.toWidth,
          ),
          borderRadius: BorderRadius.circular(radius ?? 30.toWidth),
        ),
        child: Center(
          child: child ??
              Text(
                buttonText ?? 'Add text',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorConstants.outlineGrey,
                  fontSize: 17.toFont,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }
}
