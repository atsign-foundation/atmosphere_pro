import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/notification/notification_card_btn.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class SuccessCard extends StatelessWidget {
  final FileHistory fileHistory;

  const SuccessCard({Key? key, required this.fileHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (Platform.isAndroid || Platform.isIOS) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(indexBottomBarSelected: 3),
            ),
          );
        } else {
          await DesktopSetupRoutes.nested_push(DesktopRoutes.DESKTOP_HISTORY,
              arguments: {'historyType': HistoryType.send});
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFECF8FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Successfully sent ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF18A2EF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${fileHistory.fileDetails?.files?.length} files',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF18A2EF),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: (Platform.isAndroid || Platform.isIOS) ? 200 : 230,
                  child: Text(
                    getAtsignCount(fileHistory),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF18A2EF),
                    ),
                  ),
                ),
              ],
            ),
            NotificationCardButton(
              backgroundColor: const Color(0xFF18A2EF).withOpacity(0.2),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Delivered',
                    style: TextStyle(color: Color(0xFF18A2EF), fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getAtsignCount(FileHistory fileHistory) {
    String msg = fileHistory.sharedWith?[0].atsign ?? '';

    if (fileHistory.sharedWith != null && fileHistory.sharedWith!.length > 1) {
      msg +=
          ' and ${fileHistory.sharedWith!.length - 1} ${fileHistory.sharedWith!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
  }
}
