import 'dart:convert';
import 'dart:typed_data';
import 'package:atsign_atmosphere_app/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ReceiveFilesAlert extends StatefulWidget {
  final Function() onAccept;
  final String payload;
  final Function(bool) sharingStatus;
  const ReceiveFilesAlert(
      {Key key, this.onAccept, this.payload, this.sharingStatus})
      : super(key: key);

  @override
  _ReceiveFilesAlertState createState() => _ReceiveFilesAlertState();
}

class _ReceiveFilesAlertState extends State<ReceiveFilesAlert> {
  NotificationPayload payload;
  bool status = false;
  @override
  void initState() {
    Map<String, dynamic> test =
        jsonDecode(widget.payload) as Map<String, dynamic>;
    payload = NotificationPayload.fromJson(test);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.toWidth)),
      titlePadding: EdgeInsets.only(top: 10.toHeight, left: 10.toWidth),
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
              style: CustomTextStyles.blueMedium16,
            ),
          )
        ],
      ),
      content: Container(
        height: 180.toHeight,
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
                    CustomCircleAvatar(
                      image: ImageConstants.test,
                    ),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          // text: '@levinat',
                          text: payload.name,
                          style: CustomTextStyles.primaryBold14,
                          children: [
                            TextSpan(
                              text: ' wants to send you a file?',
                              style: CustomTextStyles.primaryRegular16,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            Text(payload.file),
            Container(
              width: 100.toWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            double.parse(payload.size.toString()) <= 1024
                                ? '${payload.size} Kb'
                                : '${(payload.size / 1024).toStringAsFixed(2)} Mb',
                            style: CustomTextStyles.secondaryRegular14,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButton(
          buttonText: TextStrings().accept,
          onPressed: () {
            status = true;
            widget.onAccept;
            NotificationService().cancelNotifications();
            Navigator.pop(context);
            widget.sharingStatus(status);
          },
        ),
        SizedBox(
          height: 10.toHeight,
        ),
        CustomButton(
          isInverted: true,
          buttonText: TextStrings().reject,
          onPressed: () {
            status = false;
            NotificationService().cancelNotifications();
            Navigator.pop(context);
            widget.sharingStatus(status);
          },
        ),
      ],
    );
  }
}
