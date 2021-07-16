import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

Widget customPersonVerticalTile(
    String title, String subTitle, Function onCancel) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      InkWell(
        onTap: () {},
        child: Stack(
          children: [
            ContactInitial(
              initials: title ?? ' ',
              size: 30,
              maxSize: (80.0 - 30.0),
              minSize: 50,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                child: Icon(Icons.cancel),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10.toHeight),
      Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: CustomTextStyles.desktopPrimaryRegular14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5.toHeight),
            subTitle != null
                ? Text(
                    subTitle,
                    style: CustomTextStyles.secondaryRegular12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : SizedBox(),
          ],
        ),
      )
    ],
  );
}
