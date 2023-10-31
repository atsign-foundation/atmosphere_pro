import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/notification_card_btn.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:flutter/material.dart';

class ReceivedFileCard extends StatelessWidget {
  final FileHistory fileHistory;

  const ReceivedFileCard({
    Key? key,
    required this.fileHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cardNavigator,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: (Platform.isAndroid || Platform.isIOS) ? 200 : 230,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '${fileHistory.fileDetails?.sender ?? ''}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: 'Sent ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${fileHistory.fileDetails?.files?.length} files',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ])),
                (fileHistory.fileTransferObject?.notes ?? '').isNotEmpty &&
                        fileHistory.fileTransferObject?.notes != null
                    ? Row(
                        children: [
                          SizedBox(
                            width: (Platform.isAndroid || Platform.isIOS)
                                ? 200
                                : 230,
                            child: Text(
                              '"${fileHistory.fileTransferObject?.notes} "',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
            NotificationCardButton(
                backgroundColor: Color(0xFFF07C50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Icon(
                      Icons.arrow_outward,
                      color: Colors.white,
                      size: 12,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  cardNavigator() async {
    if (Navigator.of(NavService.navKey.currentContext!).canPop()) {
      Navigator.of(NavService.navKey.currentContext!).pop();
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await Navigator.push(
        NavService.navKey.currentContext!,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(indexBottomBarSelected: 3),
        ),
      );
    } else {
      await DesktopSetupRoutes.nested_push(DesktopRoutes.DESKTOP_HISTORY,
          arguments: {'historyType': HistoryType.received});
    }
  }
}
