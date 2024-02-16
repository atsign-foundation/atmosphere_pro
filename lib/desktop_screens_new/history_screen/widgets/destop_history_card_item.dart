import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_card_header.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_received_card_body.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:flutter/material.dart';

class DesktopHistoryCardItem extends StatelessWidget {
  final FileHistory fileHistory;

  const DesktopHistoryCardItem({
    Key? key,
    required this.fileHistory,
  });

  String getFilePath(String name) {
    return MixedConstants.getFileDownloadLocationSync(
            sharedBy: fileHistory.fileDetails?.sender ?? '') +
        Platform.pathSeparator +
        name;
  }

  @override
  Widget build(BuildContext context) {
    fileHistory.fileDetails?.files
        ?.forEach((e) => e.path = getFilePath(e.name ?? ''));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorConstants.sidebarTileSelected,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          DesktopHistoryCardHeader(fileHistory: fileHistory),
          SizedBox(
            height: fileHistory.type == HistoryType.received ? 12 : 8,
          ),
          fileHistory.type == HistoryType.received
              ? DesktopHistoryReceivedCardBody(
                  fileTransfer: fileHistory.fileDetails!,
                  type: fileHistory.type ?? HistoryType.received,
                )
              : DesktopHistoryFileList(
                  fileTransfer: fileHistory.fileDetails!,
                  type: fileHistory.type ?? HistoryType.received,
                ),
          if (fileHistory.type == HistoryType.received) SizedBox(height: 16),
        ],
      ),
    );
  }
}
