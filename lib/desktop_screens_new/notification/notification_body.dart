import 'dart:io';

import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/fail_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/receive_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/sending_file_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/success_card.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart' as color;
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart'
    as notification_service;

class NotificationBody extends StatefulWidget {
  const NotificationBody({Key? key}) : super(key: key);

  @override
  State<NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody> {
  @override
  Widget build(BuildContext context) {
    return Consumer<notification_service.NotificationService>(
      builder: (_context, provider, _) {
        return ClipRRect(
          child: Container(
            margin: EdgeInsets.only(top: 80),
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.topRight,
              elevation: 5.0,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                ),
                clipBehavior: Clip.hardEdge,
                width: getNotificationDialogWidth(),
                // height: getNotificationDialogHeight(),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Notifications',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 155,
                            child: Divider(
                                color: ColorConstants.buttonHighLightColor),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                provider.currentFileShareStatus[
                                            notification_service
                                                .NotificationService
                                                .fileObjectKey] !=
                                        null
                                    ? Text(
                                        'Sending Queue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: ColorConstants
                                              .buttonHighLightColor,
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(height: 5),
                                sendingFileCard(provider),
                                provider.recentNotification.isEmpty &&
                                        provider.currentFileShareStatus[
                                                notification_service
                                                    .NotificationService
                                                    .flushbarStatuskey] ==
                                            null
                                    ? Center(
                                        child: Text('No notifications'),
                                      )
                                    : getNotificationList(provider),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset(
                          AppVectors.icCancel,
                          height: 20,
                          width: 20,
                          color: color.ColorConstants.closeButtonColor,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sendingFileCard(
      notification_service.NotificationService notificationServiceprovider) {
    FileTransfer? fileTransfer =
        notificationServiceprovider.currentFileShareStatus[
            notification_service.NotificationService.fileObjectKey];
    FlushBarStatus? flushbarStatus =
        notificationServiceprovider.currentFileShareStatus[
            notification_service.NotificationService.flushBarStatusKey];

    return SendingFileCard(
      flushbarStatus: flushbarStatus,
      fileTransfer: fileTransfer,
    );
  }

  Widget getNotificationList(
      notification_service.NotificationService provider) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: provider.recentNotification.length,
        itemBuilder: (_, i) {
          return provider.recentNotification[i].type == HistoryType.send
              ? Container(
                  margin: EdgeInsets.only(top: 15),
                  child: isSuccess(provider.recentNotification[i])
                      ? SuccessCard(fileHistory: provider.recentNotification[i])
                      : FailCard(fileHistory: provider.recentNotification[i]),
                )
              : Container(
                  margin: EdgeInsets.only(top: 15),
                  child: ReceivedFileCard(
                    fileHistory: provider.recentNotification[i],
                  ),
                );
        },
      ),
    );
  }

  bool isSuccess(FileHistory fileHistory) {
    bool isSuccess = true;
    fileHistory.sharedWith!.forEach((ShareStatus element) {
      if (element.isNotificationSend == false) {
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  double getNotificationDialogWidth() {
    if (Platform.isAndroid || Platform.isIOS) {
      return double.infinity;
    } else {
      return 400;
    }
  }
}
