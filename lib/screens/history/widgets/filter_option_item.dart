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
  final Function()? allOptionOnTap;
  final bool isAllOption;

  const FilterOptionItem({
    Key? key,
    this.icon,
    this.isDisable = false,
    this.borderRadius,
    this.title,
    this.isCheck = false,
    this.onTap,
    this.isAllOption = false,
    this.allOptionOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = isCheck
        ? isDisable
            ? Colors.black
            : Colors.white
        : isDisable
            ? ColorConstants.lightSliver
            : Colors.black;

    Color backgroundColor =
        isDisable ? ColorConstants.disableBackgroundColor : Colors.white;

    Color checkedBackgroundColor = isDisable
        ? ColorConstants.optionalFilterBackgroundColor
        : ColorConstants.orange;

    return InkWell(
      onTap: () {
        isAllOption ? allOptionOnTap?.call() : onTap?.call();
      },
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isCheck ? checkedBackgroundColor : backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.zero,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAllOption)
                  SvgPicture.asset(
                    //TODO: Use another boolean variable to check isAllType or not
                    isCheck
                        ? AppVectors.icArrowUpOutline
                        : AppVectors.icArrowDownOutline,
                    width: 20,
                    height: 20,
                    color: color,
                    fit: BoxFit.cover,
                  ),
                if (isAllOption) SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    isAllOption ? onTap?.call() : null;
                  },
                  child: SvgPicture.asset(
                    isCheck ? AppVectors.icChecked : AppVectors.icUnchecked,
                    width: 16,
                    height: 16,
                    color: color,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
