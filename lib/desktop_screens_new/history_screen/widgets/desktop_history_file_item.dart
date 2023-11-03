import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/history_context_menu.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/desktop_context_menu.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/context_menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHistoryFileItem extends StatefulWidget {
  final FileData data;
  final FileTransfer fileTransfer;
  final int index;
  final HistoryType type;

  const DesktopHistoryFileItem({
    Key? key,
    required this.data,
    required this.fileTransfer,
    required this.index,
    required this.type,
  });

  @override
  State<DesktopHistoryFileItem> createState() => _DesktopHistoryFileItemState();
}

class _DesktopHistoryFileItemState extends State<DesktopHistoryFileItem> {
  String filePath = '';

  @override
  void initState() {
    super.initState();
    getFilePath();
  }

  void getFilePath() async {
    final result = widget.type == HistoryType.received
        ? await MixedConstants.getFileDownloadLocation(
            sharedBy: widget.fileTransfer.sender)
        : await MixedConstants.getFileSentLocation();
    setState(() {
      filePath = result + Platform.pathSeparator + (widget.data.name ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContextMenuProvider>(
      builder: (context, state, child) {
        return InkWell(
          onTap: () async {
            await openFilePath(filePath);
          },
          onSecondaryTapDown: (details) {
            state.setIsIgnore(true);
            state.setIsItemSelected(
              key: widget.fileTransfer.key,
              state: true,
              index: widget.index,
            );
            DesktopContextMenu.setContextMenu(
              HistoryContextMenu(
                offset: details.globalPosition,
                onCancel: () {
                  state.setIsIgnore(false);
                  state.setIsItemSelected(
                    key: widget.fileTransfer.key,
                    state: false,
                    index: widget.index,
                  );
                },
                file: widget.data,
                fileTransfer: widget.fileTransfer,
                isDownloaded: File(filePath).existsSync(),
                type: widget.type,
              ),
            );
            DesktopContextMenu.show(context);
          },
          child: Stack(
            children: [
              buildFileCard(
                state.listItemState[widget.fileTransfer.key]![widget.index],
              ),
              if (File(filePath).existsSync()) buildMarkRead(),
            ],
          ),
        );
      },
    );
  }

  Widget buildFileCard(bool isSelected) {
    final String fileFormat = '.${widget.data.name?.split('.').last}';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConstants.fileItemColor,
        border: isSelected
            ? Border.all(
                color: ColorConstants.portlandOrange,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 44),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.data.name
                                    ?.replaceAll(fileFormat, ''),
                                style: CustomTextStyles.blackW60010,
                              ),
                              TextSpan(
                                text: fileFormat,
                                style: CustomTextStyles.blackW40010,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${(widget.data.size! / (1024 * 1024)).toStringAsFixed(2)} Mb',
                        style: CustomTextStyles.oldSliverW400S10,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: -2,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(7),
              ),
              child: SizedBox(
                width: 44,
                child: thumbnail(
                  fileFormat,
                  filePath,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMarkRead() {
    return Positioned(
      top: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: ColorConstants.lightGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: ColorConstants.shadowGreen,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      blurStyle: BlurStyle.normal)
                ]),
            child: Icon(
              Icons.done_all,
              size: 16,
              color: ColorConstants.textGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget thumbnail(String? extension, String path) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? File(path).existsSync()
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _context, _, __) {
                  return Container(
                    child: Icon(
                      Icons.image,
                    ),
                  );
                },
              )
            : Icon(
                Icons.image,
              )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => snapshot.data == null
                    ? Image.asset(
                        ImageConstants.videoLogo,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        videoThumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext _context, _, __) {
                          return Icon(
                            Icons.image,
                          );
                        },
                      ),
              )
            : Image.asset(
                FileTypes.PDF_TYPES.contains(extension)
                    ? ImageConstants.pdfLogo
                    : FileTypes.AUDIO_TYPES.contains(extension)
                        ? ImageConstants.musicLogo
                        : FileTypes.WORD_TYPES.contains(extension)
                            ? ImageConstants.wordLogo
                            : FileTypes.EXEL_TYPES.contains(extension)
                                ? ImageConstants.exelLogo
                                : FileTypes.TEXT_TYPES.contains(extension)
                                    ? ImageConstants.txtLogo
                                    : ImageConstants.unknownLogo,
                fit: BoxFit.cover,
              );
  }
}
