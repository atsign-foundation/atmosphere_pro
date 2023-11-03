import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_card_header.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_retry_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/history_context_menu.dart';
import 'package:atsign_atmosphere_pro/services/desktop_context_menu.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/context_menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool isOpenRetryCard = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ContextMenuProvider>(
      builder: (context, state, child) {
        return InkWell(
          onSecondaryTapUp: state.isIgnore
              ? null
              : (details) {
                  state.setIsCardSelected(
                      key: widget.fileHistory.fileDetails!.key, state: true);
                  DesktopContextMenu.setContextMenu(
                    HistoryContextMenu(
                      offset: details.globalPosition,
                      onCancel: () {
                        state.setIsCardSelected(
                            key: widget.fileHistory.fileDetails!.key,
                            state: false);
                      },
                      fileTransfer: widget.fileHistory.fileDetails!,
                      type: widget.fileHistory.type ?? HistoryType.received,
                    ),
                  );
                  DesktopContextMenu.show(context);
                },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    state.listCardState[widget.fileHistory.fileDetails!.key] ??
                            false
                        ? ColorConstants.portlandOrange
                        : ColorConstants.sidebarTileSelected,
                width:
                    state.listCardState[widget.fileHistory.fileDetails!.key] ??
                            false
                        ? 2
                        : 1,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                DesktopHistoryCardHeader(
                  type: widget.fileHistory.type,
                  date: widget.fileHistory.fileDetails!.date!,
                  groupName: widget.fileHistory.groupName,
                  note: widget.fileHistory.fileDetails?.notes ?? '',
                  sender: widget.fileHistory.fileDetails?.sender,
                  sharedWith: widget.fileHistory.sharedWith ?? [],
                  fileNameList: widget.fileHistory.fileDetails!.files!
                      .map((e) => e.name ?? '')
                      .toList(),
                  isHideBadges: isOpenRetryCard,
                  onOpenRetryCard: () {
                    setState(() {
                      isOpenRetryCard = true;
                    });
                  },
                ),
                SizedBox(height: 12),
                if (isOpenRetryCard)
                  DesktopHistoryRetryCard(
                    sharedWith: widget.fileHistory.sharedWith ?? [],
                    onCancel: () {
                      setState(() {
                        isOpenRetryCard = false;
                      });
                    },
                  ),
                SizedBox(height: 12),
                DesktopHistoryFileList(
                  fileTransfer: widget.fileHistory.fileDetails!,
                  type: widget.fileHistory.type ?? HistoryType.received,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
