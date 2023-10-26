import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/notification_body.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart'
    as notification_service;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  late bool isNotificationSelected;

  @override
  void initState() {
    isNotificationSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: showNotificationDialog,
          child: Container(
            padding: EdgeInsets.all(4),
            color: Colors.transparent,
            child: Icon(
              Icons.circle_notifications,
              color: isNotificationSelected
                  ? ColorConstants.buttonHighLightColor
                  : null,
              size: 45,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Consumer<notification_service.NotificationService>(
            builder: (_, provider, __) {
              return provider.recentNotification.isEmpty
                  ? SizedBox.shrink()
                  : Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: isNotificationSelected
                            ? Color(0xFFF6DED5)
                            : Color(0xFFDBDBDB),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          /// for notifications more than 10 -> 10+
                          getNotificationCount(provider),
                          style: TextStyle(
                            color: isNotificationSelected
                                ? ColorConstants.buttonHighLightColor
                                : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }

  showNotificationDialog() async {
    setState(() {
      isNotificationSelected = !isNotificationSelected;
    });

    await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) {
          return Consumer<notification_service.NotificationService>(
            builder: (_context, provider, _) {
              return NotificationBody();
            },
          );
        });

    setState(() {
      isNotificationSelected = !isNotificationSelected;
    });
  }

  String getNotificationCount(
      notification_service.NotificationService provider) {
    if (provider.recentNotification.length > 10) {
      return '10+';
    } else {
      return '${provider.recentNotification.length}';
    }
  }

  String getAtsignCountFromFileTransfer(FileTransfer fileTransfer) {
    String msg = fileTransfer.atSigns?[0] ?? '';

    if (fileTransfer.atSigns != null && fileTransfer.atSigns!.length > 1) {
      msg +=
          ' and ${fileTransfer.atSigns!.length - 1} ${fileTransfer.atSigns!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
  }
}
