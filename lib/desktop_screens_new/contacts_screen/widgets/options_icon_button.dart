import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionsIconButton extends StatelessWidget {
  final Function() onTap;
  final bool isSelected;
  final String icon;

  const OptionsIconButton({
    required this.onTap,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? ColorConstants.orange
              : ColorConstants.iconButtonColor,
        ),
        child: SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          color: isSelected ? Colors.white : Colors.black,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
