import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class GroupsCustomButton extends StatelessWidget {
  final Function() onTap;
  final bool isLoading;
  final String title;
  final double spaceSize;
  final Widget? suffix;
  final double borderRadius;

  const GroupsCustomButton({
    required this.onTap,
    this.isLoading = false,
    required this.title,
    this.spaceSize = 28,
    this.suffix,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorConstants.raisinBlack,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.symmetric(horizontal: 28),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: CustomTextStyles.whiteBold(size: 14),
                    ),
                    if (suffix != null) ...[
                      SizedBox(width: spaceSize),
                      suffix!,
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}
