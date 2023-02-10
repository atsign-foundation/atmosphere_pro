import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardButton extends StatelessWidget {
  final String icon;
  final String title;
  final TextStyle? style;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const CardButton({
    Key? key,
    required this.icon,
    required this.title,
    this.style,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor ?? ColorConstants.lightGrey,
          border: Border.all(
            color: borderColor ?? ColorConstants.grey,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: style ??
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.grey,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
