import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
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
          await DesktopSetupRoutes.nested_push(DesktopRoutes.DESKTOP_HISTORY,
              arguments: {'historyType': HistoryType.received});
        }
      },
      child: Container(
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
              '${fileHistory.fileDetails?.sender ?? ''}',
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
      ),
    );
  }
}
