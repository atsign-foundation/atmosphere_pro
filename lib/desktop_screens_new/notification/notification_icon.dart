import 'dart:io';

import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart'
    as notificationService;
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
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
              color: ColorConstants.buttonHighLightColor,
              size: 45,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Consumer<notificationService.NotificationService>(
            builder: (_, provider, __) {
              return provider.recentNotification.isEmpty
                  ? SizedBox()
                  : Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: Color(0xFFF6DED5),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          /// for notifications more than 10 -> 10+
                          getNotificationCount(provider),
                          style: TextStyle(
                            color: ColorConstants.buttonHighLightColor,
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
    await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) {
          return Consumer<notificationService.NotificationService>(
            builder: (_context, provider, _) {
              return Container(
                margin: EdgeInsets.only(top: 80, right: 20),
                child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.hardEdge,
                    width: getNotificationDialogWidth(),
                    // height: getNotificationDialogHeight(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Divider(color: ColorConstants.buttonHighLightColor),
                          provider.currentFileShareStatus[notificationService
                                      .NotificationService.fileObjectKey] !=
                                  null
                              ? Text(
                                  'Sending Queue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ColorConstants.buttonHighLightColor,
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(height: 5),
                          sendingFileCard(provider),
                          provider.recentNotification.isEmpty
                              ? Center(
                                  child: Text('No notifications'),
                                )
                              : getNotificationList(provider)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget getNotificationList(notificationService.NotificationService provider) {
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: provider.recentNotification.length,
        itemBuilder: (_, i) {
          return provider.recentNotification[i].type == HistoryType.send
              ? Container(
                  margin: EdgeInsets.only(top: 15),
                  child: isSuccess(provider.recentNotification[i])
                      ? successCard(provider.recentNotification[i])
                      : failFileCard(provider.recentNotification[i]),
                )
              : Container(
                  margin: EdgeInsets.only(top: 15),
                  child: receivedFileCard(provider.recentNotification[i]),
                );
        },
      ),
    );
  }

  Widget sendingFileCard(
      notificationService.NotificationService notificationServiceprovider) {
    FileTransfer? fileTransfer =
        notificationServiceprovider.currentFileShareStatus[
            notificationService.NotificationService.fileObjectKey];
    FLUSHBAR_STATUS? flushbarStatus =
        notificationServiceprovider.currentFileShareStatus[
            notificationService.NotificationService.flushbarStatuskey];
    AtClient atClient = AtClientManager.getInstance().atClient;

    return flushbarStatus == FLUSHBAR_STATUS.SENDING && fileTransfer != null
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sending ${fileTransfer.files?.length ?? 0} files',
                  style: TextStyle(fontSize: 11),
                ),
                Text(
                  getAtsignCountFromFileTransfer(fileTransfer),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                LinearProgressIndicator()
              ],
            ),
          )
        : SizedBox();
  }

  Widget failFileCard(FileHistory fileHistory) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Failed to send  ${fileHistory.fileDetails?.files?.length} files',
            style: TextStyle(
              fontSize: 11,
              color: ColorConstants.buttonHighLightColor,
            ),
          ),
          Text(
            getAtsignCount(fileHistory),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorConstants.buttonHighLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget successCard(FileHistory fileHistory) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFECF8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Successfully sent ${fileHistory.fileDetails?.files?.length} files',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF18A2EF),
            ),
          ),
          Text(
            getAtsignCount(fileHistory),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18A2EF),
            ),
          ),
        ],
      ),
    );
  }

  Widget receivedFileCard(FileHistory fileHistory) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fileHistory.fileDetails?.sender ?? '@kim'}',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Text(
            'Sent ${fileHistory.fileDetails?.files?.length} files',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          fileHistory.fileTransferObject?.notes != ""
              ? Text(
                  '"${fileHistory.fileTransferObject?.notes}"',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  String getNotificationCount(
      notificationService.NotificationService provider) {
    if (provider.recentNotification.length > 10) {
      return '10+';
    } else {
      return '${provider.recentNotification.length}';
    }
  }

  // double? getNotificationDialogHeight() {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     // return SizeConfig().screenHeight * 0.8;
  //     return null;
  //   } else {
  //     return null;
  //   }
  // }

  double getNotificationDialogWidth() {
    if (Platform.isAndroid || Platform.isIOS) {
      return double.infinity;
    } else {
      return 285;
    }
  }

  String getAtsignCount(FileHistory fileHistory) {
    String msg = fileHistory.sharedWith?[0].atsign ?? '';

    if (fileHistory.sharedWith != null && fileHistory.sharedWith!.length > 1) {
      msg +=
          ' and ${fileHistory.sharedWith!.length - 1} ${fileHistory.sharedWith!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
  }

  String getAtsignCountFromFileTransfer(FileTransfer fileTransfer) {
    String msg = fileTransfer.atSigns?[0] ?? '';

    if (fileTransfer.atSigns != null && fileTransfer.atSigns!.length > 1) {
      msg +=
          ' and ${fileTransfer.atSigns!.length - 1} ${fileTransfer.atSigns!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
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
}
