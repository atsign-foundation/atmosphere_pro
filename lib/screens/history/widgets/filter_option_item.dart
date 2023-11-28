import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterOptionItem extends StatelessWidget {
  final String? icon;
  final String? title;
  final bool isCheck;
  final BorderRadiusGeometry? borderRadius;
  final Function()? onTap;
  final bool isAllOption;
  final bool? isShowOptional;

  const FilterOptionItem({
    Key? key,
    this.icon,
    this.borderRadius,
    this.title,
    this.isCheck = true,
    this.onTap,
    this.isAllOption = false,
    this.isShowOptional,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(28, 8, 20, 8),
        decoration: BoxDecoration(
          color: isAllOption
              ? ColorConstants.orange
              : ColorConstants.optionalFilterBackgroundColor,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if ((icon ?? '').isNotEmpty) ...[
                  SvgPicture.asset(
                    icon!,
                    color: Colors.black,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  title ?? '',
                  style: TextStyle(
                    color: isAllOption ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  isCheck
                      ? AppVectors.icChecked
                      : isAllOption
                          ? AppVectors.icUncheckedAll
                          :  AppVectors.icUnchecked,
                  width: 16,
                  height: 16,
                  color: isAllOption ? Colors.white : Colors.black,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
