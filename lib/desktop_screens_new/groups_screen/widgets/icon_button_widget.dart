import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconButtonWidget extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Function() onTap;
  final bool isSelected;
  final EdgeInsets? padding;

  const IconButtonWidget({
    Key? key,
    required this.icon,
    this.backgroundColor = Colors.white,
    required this.onTap,
    this.isSelected = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          color: isSelected ? ColorConstants.orange : Colors.black,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
