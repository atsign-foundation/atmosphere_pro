import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class SideBarBackupItem extends StatelessWidget {
  final String title;
  final Widget leadingIcon;
  final VoidCallback onPressed;

  SideBarBackupItem({
    Key key,
    this.title,
    this.leadingIcon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50.toHeight,
        child: Row(
          children: [
            if (leadingIcon != null) leadingIcon,
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                softWrap: true,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  letterSpacing: 0.1,
                  fontSize: 14.toFont,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
