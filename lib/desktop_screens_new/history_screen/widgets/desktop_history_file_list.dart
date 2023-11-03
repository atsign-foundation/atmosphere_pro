import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/context_menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class DesktopHistoryFileList extends StatelessWidget {
  final FileTransfer fileTransfer;
  final HistoryType type;

  const DesktopHistoryFileList({
    required this.fileTransfer,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final ContextMenuProvider contextMenuProvider =
        Provider.of<ContextMenuProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.culturedColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AlignedGridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 6),
        physics: NeverScrollableScrollPhysics(),
        itemCount: fileTransfer.files?.length,
        crossAxisCount: 3,
        itemBuilder: (context, index) {
          if (contextMenuProvider.listItemState[fileTransfer.key] != null &&
              contextMenuProvider.listItemState[fileTransfer.key]!.isNotEmpty) {
            contextMenuProvider.listItemState[fileTransfer.key]!.add(false);
          } else {
            contextMenuProvider.listItemState.addAll({
              fileTransfer.key: [false]
            });
          }
          return DesktopHistoryFileItem(
            key: UniqueKey(),
            data: fileTransfer.files![index],
            fileTransfer: fileTransfer,
            index: index,
            type: type,
          );
        },
      ),
    );
  }
}
