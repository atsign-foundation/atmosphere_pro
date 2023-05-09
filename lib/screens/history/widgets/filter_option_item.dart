import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterOptionItem extends StatelessWidget {
  final String? icon;
  final String? title;
  final bool isDisable, isCheck;
  final BorderRadiusGeometry? borderRadius;
  final Function()? onTap;

  const FilterOptionItem({
    Key? key,
    this.icon,
    this.isDisable = false,
    this.borderRadius,
    this.title,
    this.isCheck = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = isDisable ? ColorConstants.disableColor : Colors.black;
    Color backgroundColor =
        isDisable ? ColorConstants.disableBackgroundColor : Colors.white;

    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (icon ?? '').isNotEmpty
                    ? SvgPicture.asset(
                        icon!,
                        color: color,
                        height: 16,
                        width: 12,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(width: 12),
                SizedBox(width: 16),
                Text(
                  title ?? '',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              isCheck ? AppVectors.icChecked : AppVectors.icUnchecked,
              width: 16,
              height: 16,
              color: color,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
