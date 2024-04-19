import 'dart:io';

import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_item.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_image_preview.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class HistoryFileList extends StatefulWidget {
  final HistoryType? type;
  final FileTransfer? fileTransfer;
  final bool isSent;

  const HistoryFileList({
    required this.type,
    required this.fileTransfer, required this.isSent,
  });

  @override
  State<HistoryFileList> createState() => _HistoryFileListState();
}

class _HistoryFileListState extends State<HistoryFileList> {
  // bool isExpanded = false;

  String getFilePath(String name) {
    return BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        name;
  }

  String getSentFilePath(String name) {
    return MixedConstants.getFileSentLocationSync() +
        Platform.pathSeparator +
        name;
  }

  @override
  Widget build(BuildContext context) {
    final int fileListLength = (widget.fileTransfer?.files ?? []).length;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorConstants.culturedColor,
      ),
      child: Row(
        children: [
          if (widget.type == HistoryType.received)
            Expanded(
              flex: 23,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                itemBuilder: (context, index) {
                  return buildIndicatorDot(
                    /*fileListLength >= 2 && !isExpanded && index >= 2
                      ? ColorConstants.inActiveIndicatorColor
                      : */
                    ColorConstants.orangeColor,
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 4);
                },
                itemCount: fileListLength,
              ),
            ),
          Expanded(
            flex: 301,
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: widget.type == HistoryType.received
                  ? const EdgeInsets.fromLTRB(4, 12, 12, 12)
                  : EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final FileData file = widget.fileTransfer!.files![index];
                return HistoryFileItem(
                  key: UniqueKey(),
                  type: widget.type,
                  fileTransfer: widget.fileTransfer,
                  data: widget.fileTransfer!.files![index],
                  openFile: () async {
                    await openPreview(
                      name: file.name ?? '',
                      size: file.size ?? 0,
                    );
                  }, isSent: widget.isSent,
                );
              },
              itemCount:
                  /* fileListLength > 2 && !isExpanded ? 2 : */ fileListLength,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 8);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildIndicatorDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // Widget buildMoreFilesButton(int fileListLength) {
  //   return Positioned(
  //     bottom: 4,
  //     left: 0,
  //     right: 0,
  //     child: Center(
  //       child: InkWell(
  //         onTap: () {
  //           setState(() {
  //             isExpanded = !isExpanded;
  //           });
  //         },
  //         child: Container(
  //           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(47),
  //             color: ColorConstants.moreFilesBackgroundColor,
  //           ),
  //           child: Text(
  //             isExpanded ? 'Show Less' : '${fileListLength - 2} More File(s)',
  //             style: TextStyle(
  //               color: ColorConstants.orangeColor,
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> openPreview({
    required String name,
    required int size,
  }) async {
    if (FileTypes.IMAGE_TYPES.contains(name.split(".").last)) {
      String nickname = "";
      final date = (widget.fileTransfer?.date ?? DateTime.now()).toLocal();
      final List<FileData> dataList = (widget.fileTransfer?.files ?? [])
          .where((e) =>
              FileTypes.IMAGE_TYPES.contains(e.name?.split(".").last) &&
              (File(getFilePath(e.name ?? '')).existsSync() ||
                  File(getSentFilePath(e.name ?? '')).existsSync()))
          .map((e) {
        final path = getFilePath(e.name ?? '');
        final sentPath = getSentFilePath(e.name ?? '');
        return FileData(
          size: e.size,
          path: File(path).existsSync() ? path : sentPath,
          name: e.name,
          isDownloading: e.isDownloading,
          isUploaded: e.isUploaded,
          isUploading: e.isUploading,
          url: e.url,
        );
      }).toList();
      for (var contact in GroupService().allContacts) {
        if (contact?.contact?.atSign == widget.fileTransfer?.sender) {
          nickname = contact?.contact?.tags?["nickname"] ?? "";
          break;
        }
      }
      final newIndex = dataList.indexWhere((element) => element.name == name);
      await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (_) => Material(
          color: Colors.transparent,
          child: HistoryImagePreview(
            data: dataList,
            index: newIndex,
            fileTransferId: widget.fileTransfer?.key,
            nickname: nickname,
            sender: widget.fileTransfer?.sender ?? '',
            notes: widget.fileTransfer?.notes ?? '',
            date: date,
            type: widget.type,
            onDelete: () {
              Provider.of<HistoryProvider>(context, listen: false).notify();
            },
          ),
        ),
      );
    } else {
      await OpenFile.open(File(getFilePath(name)).existsSync()
          ? getFilePath(name)
          : getSentFilePath(name));
    }
  }
}
