import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_card_header.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_list.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class DesktopHistoryCardItem extends StatefulWidget {
  final FileHistory fileHistory;

  const DesktopHistoryCardItem({
    Key? key,
    required this.fileHistory,
  });

  @override
  State<DesktopHistoryCardItem> createState() => _DesktopHistoryCardItemState();
}

class _DesktopHistoryCardItemState extends State<DesktopHistoryCardItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
          DesktopHistoryCardHeader(
            fileHistory: widget.fileHistory,
          ),
          SizedBox(height: 12),
          DesktopHistoryFileList(
            fileTransfer: widget.fileHistory.fileDetails!,
            type: widget.fileHistory.type ?? HistoryType.received,
          ),
        ],
      ),
    );
  }
}
