import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryFileCard extends StatefulWidget {
  final FileTransfer fileTransfer;
  final FileData singleFile;
  final bool isShowDate;
  final EdgeInsetsGeometry? margin;
  final Function()? onAction;
  final bool fromContact;
  final HistoryType historyType;
  final FileHistory fileHistory;

  const HistoryFileCard({
    Key? key,
    required this.fileTransfer,
    required this.singleFile,
    this.isShowDate = true,
    this.margin,
    this.onAction,
    this.fromContact = false,
    required this.historyType,
    required this.fileHistory,
  }) : super(key: key);

  @override
  State<HistoryFileCard> createState() => _HistoryFileCardState();
}

class _HistoryFileCardState extends State<HistoryFileCard> {
  bool isDownloaded = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<InternetConnectivityChecker>(NavService.navKey.currentContext!,
            listen: false)
        .checkConnectivity();
    if (widget.historyType == HistoryType.received) {
      initDownloads();
    }
  }

  void initDownloads() async {
    isDownloaded = await isFilePresent(widget.singleFile.name ?? "");
    setState(() {
      isDownloaded;
    });
  }

  Future<bool> isFilePresent(String fileName) async {
    String filePath = await MixedConstants.getFileDownloadLocation(
        sharedBy: widget.fileTransfer.sender!);

    File file = File(filePath + Platform.pathSeparator + fileName);
    bool fileExists = await file.exists();
    return fileExists;
  }

  Widget getDownloadStatus(FileTransferProgress? fileTransferProgress) {
    Widget spinner = const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        ColorConstants.orange,
      ),
    );

    if (fileTransferProgress == null) {
      return spinner;
    }

    if (fileTransferProgress.fileState == FileState.download &&
        fileTransferProgress.percent != null) {
      spinner = LabelledCircularProgressIndicator(
          value: (fileTransferProgress.percent! / 100));
    }

    return spinner;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        late String filePath;
        if (widget.historyType == HistoryType.received) {
          filePath = await MixedConstants.getFileDownloadLocation(
              sharedBy: widget.fileTransfer.sender!);
        } else if (widget.historyType == HistoryType.send) {
          filePath = await MixedConstants.getFileSentLocation();
        }

        await openFilePath(
          filePath + Platform.pathSeparator + (widget.singleFile.name ?? ""),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
                child: SvgPicture.asset(
              AppVectors.icFile,
              height: 35,
              width: 35,
            )),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                widget.singleFile.name ?? "",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Text(
              double.parse(widget.singleFile.size.toString()) <= 1024
                  ? '${widget.singleFile.size} ${TextStrings().kb}'
                  : '${(widget.singleFile.size! / (1024 * 1024)).toStringAsFixed(2)} ${TextStrings().mb}',
              style: const TextStyle(
                color: ColorConstants.grey,
                fontSize: 10,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            widget.fileHistory.type == HistoryType.received
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Consumer<FileProgressProvider>(
                        builder: (c, provider, _) {
                          var fileTransferProgress = provider
                              .receivedFileProgress[widget.fileTransfer.key];

                          return CommonUtilityFunctions()
                                  .checkForDownloadAvailability(
                            widget.fileTransfer,
                          )
                              ? fileTransferProgress != null &&
                                      fileTransferProgress.fileName ==
                                          widget.singleFile.name
                                  ? getDownloadStatus(fileTransferProgress)
                                  : isDownloaded
                                      ? SvgPicture.asset(
                                          AppVectors.icCloudDownloaded,
                                        )
                                      : InkWell(
                                          onTap: () async {
                                            await downloadFiles(
                                              widget.fileTransfer,
                                              fileName: widget.singleFile.name,
                                            );
                                          },
                                          child: SvgPicture.asset(
                                            AppVectors.icDownloadFile,
                                          ),
                                        )
                              : const SizedBox();
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      isDownloaded
                          ? GestureDetector(
                              onTap: () async {
                                if (widget.fromContact) {
                                  Navigator.pop(context);
                                }
                                await FileUtils.moveToSendFile(
                                    await MixedConstants
                                            .getFileDownloadLocation(
                                                sharedBy: widget
                                                    .fileTransfer.sender!) +
                                        Platform.pathSeparator +
                                        widget.singleFile.name!);

                                await DesktopSetupRoutes.nested_pop();
                              },
                              child: SvgPicture.asset(
                                AppVectors.icSendNew,
                              ),
                            )
                          : const SizedBox(),
                      isDownloaded
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: GestureDetector(
                                onTap: () async {
                                  String filePath = await MixedConstants
                                          .getFileDownloadLocation(
                                              sharedBy:
                                                  widget.fileTransfer.sender!) +
                                      Platform.pathSeparator +
                                      (widget.singleFile.name ?? "");

                                  File file = File(filePath);
                                  bool fileExists = await file.exists();
                                  if (fileExists == false) {
                                    await SnackbarService().showSnackbar(
                                      context,
                                      "File does not exist on your device",
                                      bgColor: ColorConstants.redAlert,
                                    );
                                  } else {
                                    file.deleteSync();
                                    SnackbarService().showSnackbar(
                                      context,
                                      "Successfully deleted the file",
                                      bgColor: ColorConstants.successColor,
                                    );
                                    widget.onAction?.call();
                                    setState(() {
                                      isDownloaded = false;
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  AppVectors.icDeleteGray,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> downloadFiles(
    FileTransfer? file, {
    String? fileName,
    bool isPreview = false,
  }) async {
    setState(() {
      isDownloading = true;
    });
    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[file!.key];

    if (fileTransferProgress != null) {
      return; //returning because download is still in progress
    }

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

    var result;
    if (fileName != null) {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadSingleFile(
        file.key,
        file.sender,
        false,
        fileName,
      );
    } else {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadFiles(
        file.key,
        file.sender!,
        false,
      );
    }

    if (result is bool && result) {
      if (mounted) {
        setState(() {
          if (!isPreview) isDownloading = false;
          isDownloaded = true;
        });
      }
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(file);
      print(file.url);
      widget.onAction?.call();
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(file);
    } else if (result is bool && !result) {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().downloadFailed,
        bgColor: ColorConstants.redAlert,
      );
      if (mounted) {
        setState(() {
          if (!isPreview) isDownloading = false;
          isDownloaded = false;
        });
      }
    }
  }
}
