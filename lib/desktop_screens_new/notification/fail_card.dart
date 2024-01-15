import 'dart:io';

import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class FailCard extends StatelessWidget {
  final FileHistory fileHistory;

  const FailCard({Key? key, required this.fileHistory}) : super(key: key);

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
              builder: (_) => WelcomeScreen(indexBottomBarSelected: 3),
            ),
          );
        } else {
          await DesktopSetupRoutes.nested_push(
            DesktopRoutes.DESKTOP_HISTORY,
            arguments: {'historyType': HistoryType.send},
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFFFF5F5),
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
                      TextSpan(
                        text: 'Failed to send ',
                        style: TextStyle(
                          fontSize: 15,
                          color: ColorConstants.buttonHighLightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${fileHistory.fileDetails?.files?.length} files',
                        style: TextStyle(
                          fontSize: 15,
                          color: ColorConstants.buttonHighLightColor,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: Text(
                    getAtsignCount(fileHistory),
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.buttonHighLightColor,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              width: 25,
              height: 25,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color(0xFFFCDFD9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorConstants.buttonHighLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Color(0xFFFCDFD9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: 10,
                  color: ColorConstants.buttonHighLightColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // NotificationCardButton(
            //     backgroundColor: Color(0xFFE1E1E1),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           'Retry',
            //           style: TextStyle(color: Colors.black, fontSize: 8),
            //         ),
            //         Icon(
            //           Icons.refresh,
            //           color: Colors.black,
            //           size: 8,
            //         )
            //       ],
            //     ))
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
