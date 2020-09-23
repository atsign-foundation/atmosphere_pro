import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class ReceiveFilesAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      titlePadding: EdgeInsets.only(top: 10.toHeight),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 42.toHeight,
            width: 42.toWidth,
            child: Image.asset(ImageConstants.logoIcon),
          ),
          Container(
            margin: EdgeInsets.only(right: 15.toWidth),
            child: Text(
              TextStrings().blockUser,
              style: CustomTextStyles.blueRegular16,
            ),
          )
        ],
      ),
      content: Container(
        height: 230.toHeight,
        child: Column(
          children: [
            SizedBox(
              height: 21.toHeight,
            ),
            Center(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 10.toWidth,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(ImageConstants.drawerIcon),
                    ),
                    RichText(
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        text: '@levinat',
                        style: CustomTextStyles.primaryBold14,
                        children: [
                          TextSpan(
                            text: ' wants to send you\n a file?',
                            style: CustomTextStyles.primaryRegular16,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            Center(
              child: Container(
                height: 100.toHeight,
                width: 100.toWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.toHeight)),
                child: Image.asset(
                  ImageConstants.logoIcon,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            Center(
              child: Container(
                width: 80.toWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 File',
                      style: CustomTextStyles.secondaryRegular14,
                    ),
                    Text(
                      '4 Mb',
                      style: CustomTextStyles.secondaryRegular14,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButton(
          buttonText: TextStrings().accept,
          onPressed: () {},
        ),
        SizedBox(
          height: 10.toHeight,
        ),
        CustomButton(
          isInverted: true,
          buttonText: TextStrings().reject,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
