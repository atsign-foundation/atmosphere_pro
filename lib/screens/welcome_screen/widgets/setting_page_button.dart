import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class SettingPageButton extends StatelessWidget {
  final String title;
  final String iconPath;
  const SettingPageButton({required this.iconPath, required this.title});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
        height: 62.toHeight,
        width: 344.toWidth,
        decoration: BoxDecoration(
          color: ColorConstants.buttonBackgroundColor,
          border: Border.all(
            color: ColorConstants.buttonBorderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 30.0.toWidth,
                right: 25.toWidth,
              ),
              child: Image.asset(
                iconPath,
                height: 28.33.toHeight,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.toFont,
                color: ColorConstants.buttonBorderColor,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ));
  }
}
