import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/desktop_context_menu.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryContextMenu extends StatefulWidget {
  final Offset offset;
  final Function() onCancel;
  final FileData? file;
  final FileTransfer fileTransfer;
  final bool? isDownloaded;
  final HistoryType type;

  const HistoryContextMenu({
    required this.offset,
    required this.onCancel,
    this.file,
    required this.fileTransfer,
    this.isDownloaded,
    required this.type,
  });

  @override
  State<HistoryContextMenu> createState() => _HistoryContextMenuState();
}

class _HistoryContextMenuState extends State<HistoryContextMenu> {
  late bool isDownloaded;
  bool isDownloading = false;

  @override
  void initState() {
    isDownloaded = widget.isDownloaded ??
        widget.fileTransfer.files!.every(
          (element) => File(getFilePath(name: element.name ?? '')).existsSync(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            widget.onCancel.call();
            DesktopContextMenu.hide();
          },
          onSecondaryTap: () {
            widget.onCancel.call();
            DesktopContextMenu.hide();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),
        Positioned(
          top: widget.offset.dy,
          left: widget.offset.dx - 280,
          child: Container(
            width: 132,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.portlandOrange,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildOptionButton(
                  onTap: () async {
                    if (!isDownloaded && !isDownloading) {
                      widget.file != null
                          ? await downloadFiles([widget.file!])
                          : await downloadFiles(widget.fileTransfer.files!);
                    }
                  },
                  borderRadius: isDownloaded
                      ? BorderRadius.vertical(
                          top: Radius.circular(10),
                        )
                      : BorderRadius.circular(10),
                  icon: buildSaveButton(),
                  title: 'Save',
                ),
                if (isDownloaded) ...[
                  Divider(
                    height: 0,
                    color: ColorConstants.dividerContextMenuColor,
                  ),
                  buildOptionButton(
                    onTap: () async {
                      List<PlatformFile> data = widget.file != null
                          ? [
                              PlatformFile(
                                name: widget.file?.name ?? '',
                                size: widget.file?.size ?? 0,
                                path:
                                    getFilePath(name: widget.file?.name ?? ''),
                                bytes: File(getFilePath(
                                        name: widget.file?.name ?? ''))
                                    .readAsBytesSync(),
                              )
                            ]
                          : widget.fileTransfer.files!
                              .map((e) => PlatformFile(
                                    name: e.name ?? '',
                                    size: e.size ?? 0,
                                    path: getFilePath(name: e.name ?? ''),
                                    bytes: File(getFilePath(name: e.name ?? ''))
                                        .readAsBytesSync(),
                                  ))
                              .toList();
                      FileTransferProvider.appClosedSharedFiles.addAll(data);

                      Provider.of<FileTransferProvider>(context, listen: false)
                          .setFiles();
                      DesktopContextMenu.hide();
                      await DesktopSetupRoutes.nested_pop();
                    },
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    icon: SvgPicture.asset(
                      AppVectors.icSendFile,
                      width: 28,
                      height: 28,
                    ),
                    title: 'Transfer',
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOptionButton({
    required Function() onTap,
    required BorderRadiusGeometry borderRadius,
    required Widget icon,
    required String title,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 8),
            Text(
              title,
              style: CustomTextStyles.blackW50014,
            )
          ],
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileTransfer.key];
        return fileTransferProgress != null
            ? Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: SvgPicture.asset(
                        AppVectors.icCloudDownloading,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: (fileTransferProgress.percent ?? 0) / 100,
                        strokeWidth: 1,
                        color: ColorConstants.downloadIndicatorColor,
                      ),
                    ),
                  ),
                ],
              )
            : isDownloaded
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      AppVectors.icCloudDownloaded,
                    ),
                  )
                : isDownloading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : SvgPicture.asset(
                        AppVectors.icDownloadFile,
                        width: 28,
                        height: 28,
                      );
      },
    );
  }

  Future<void> downloadFiles(List<FileData> files) async {
    setState(() {
      isDownloading = true;
    });

    await Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .checkConnectivity();

    var isConnected = Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .isInternetAvailable;

    if (!isConnected) {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings.noInternetMsg,
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

    for (FileData i in files) {
      var result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadSingleFile(
        widget.fileTransfer.key,
        widget.fileTransfer.sender,
        false,
        i.name ?? '',
      );
      if (result is bool && result) {
        await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                listen: false)
            .saveNewDataInMyFiles(widget.fileTransfer);
        print(i.url);
        // send download acknowledgement
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .sendFileDownloadAcknowledgement(widget.fileTransfer);
      } else if (result is bool && !result) {
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          TextStrings().downloadFailed,
          bgColor: ColorConstants.redAlert,
        );
        if (mounted) {
          setState(() {
            isDownloading = false;
            isDownloaded = false;
          });
          return;
        }
      }
    }
    if (mounted) {
      setState(() {
        isDownloading = false;

        isDownloaded = true;
      });
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
    }
  }

  List<FileData> getFilesPresent() {
    List<FileData> result = [];
    for (FileData i in widget.fileTransfer.files ?? []) {
      final bool isExist = File(getFilePath(name: i.name ?? '')).existsSync();
      if (!isExist) {
        result.add(i);
      }
    }
    return result;
  }

  String getFilePath({required String name}) {
    final result = widget.type == HistoryType.received
        ? MixedConstants.getFileDownloadLocationSync(
            sharedBy: widget.fileTransfer.sender)
        : MixedConstants.getFileSentLocationSync();

    return result + Platform.pathSeparator + name;
  }
}
