import 'dart:io';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/history_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryCardWidget extends StatefulWidget {
  final FileHistory? fileHistory;
  final List<FileType> tags;
  final Function()? onDownloaded;

  const HistoryCardWidget({
    Key? key,
    this.fileHistory,
    this.onDownloaded,
    required this.tags,
  }) : super(key: key);

  @override
  State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
}

class _HistoryCardWidgetState extends State<HistoryCardWidget> {
  bool isExpanded = false,
      isDownloading = false,
      isDownloaded = false,
      isFileSentSuccess = true;
  List<FileData>? filesList = [];
  int numberOfFinished = 0;
  int numberOfAllFiles = 0;

  @override
  void initState() {
    filesList = widget.fileHistory!.fileDetails!.files;
    if (widget.fileHistory!.sharedWith != null) {
      widget.fileHistory!.sharedWith!.forEach((ShareStatus sharedWith) {
        if (sharedWith.isNotificationSend == false) {
          isFileSentSuccess = false;
        }
      });
    }
    numberOfAllFiles = widget.fileHistory?.fileDetails?.files?.length ?? 0;
    super.initState();
    if (widget.fileHistory?.type == HistoryType.received) {
      isFilesPresent(widget.fileHistory!.fileDetails!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(builder: (context, provider, child) {
      if (provider.isDownloadDone) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isFilesPresent(widget.fileHistory!.fileDetails!);
        });
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isExpanded ? Color(0xFFE9E9E9) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.fileHistory?.type == HistoryType.received
                              ? "${widget.fileHistory?.fileDetails?.sender ?? ''}"
                              : (widget.fileHistory?.sharedWith ?? [])
                                  .map((shareStatus) => shareStatus.atsign)
                                  .join(",")
                                  .toString(),
                          style: TextStyle(
                            fontSize: 12.toFont,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "${filesList!.length}",
                            style: TextStyle(
                              fontSize: 13.toFont,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.textBlack,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            // Container(
                            //   height: 15,
                            //   width: 15,
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(10),
                            //     color: ColorConstants.lightGreen,
                            //   ),
                            //   child: Icon(
                            //     Icons.check,
                            //     size: 10,
                            //     color: ColorConstants.textGreen,
                            //   ),
                            // ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(33),
                                color: isFileSentSuccess
                                    ? ColorConstants.lightGreen
                                    : Colors.red.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  widget.fileHistory?.type ==
                                          HistoryType.received
                                      ? "Received"
                                      : "Sent",
                                  style: TextStyle(
                                    color: isFileSentSuccess
                                        ? ColorConstants.textGreen
                                        : Colors.red,
                                    fontSize: 10.toFont,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.fileHistory?.type == HistoryType.send
                              ? widget.fileHistory?.notes ?? ''
                              : widget.fileHistory?.fileDetails?.notes ?? '',
                          style: TextStyle(
                            fontSize: 12.toFont,
                            color: Color(0xFF747474),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              '${DateFormat("MM/dd/yy").format(widget.fileHistory!.fileDetails!.date!)}',
                              style: TextStyle(
                                fontSize: 11.toFont,
                                color: ColorConstants.oldSliver,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${DateFormat('kk:mm').format(widget.fileHistory!.fileDetails!.date!)}',
                              style: TextStyle(
                                fontSize: 10.toFont,
                                color: ColorConstants.oldSliver,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            ...widget.tags.map((tag) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: ColorConstants.MILD_GREY,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  tag.text,
                                  style: TextStyle(
                                    color: Color(0xFF909090),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            context.watch<HistoryProvider>().typeSelected ==
                                    HistoryType.send
                                ? InkWell(
                                    onTap: () {
                                      openFileReceiptBottomSheet();
                                    },
                                    child: Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: Color(0xFF909090),
                                    ),
                                  )
                                : buildDownloadMultipleFilesButton(),
                          ],
                        ),
                      ),
                      SizedBox(width: 6),
                      isExpanded
                          ? SvgPicture.asset(AppVectors.icArrowUpOutline)
                          : SvgPicture.asset(AppVectors.icArrowDownOutline),
                    ],
                  ),
                ],
              ),
            ),
          ),
          isExpanded
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      widget.fileHistory?.fileDetails?.files?.length ?? 0,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 4),
                  itemBuilder: (context, index) {
                    return HistoryFileCard(
                      key: UniqueKey(),
                      fileTransfer: widget.fileHistory!.fileDetails!,
                      singleFile:
                          widget.fileHistory!.fileDetails!.files![index],
                      isShowDate: false,
                      margin: EdgeInsets.fromLTRB(36, 6, 20, 0),
                      onAction: () async {
                        await isFilesPresent(widget.fileHistory!.fileDetails!);
                      },
                      historyType: widget.fileHistory!.type ?? HistoryType.send,
                      fileHistory: widget.fileHistory!,
                    );
                  },
                )
              : SizedBox(),
        ],
      );
    });
  }

  Widget buildDownloadMultipleFilesButton() {
    return Consumer<FileProgressProvider>(
      builder: (_c, provider, _) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileHistory?.fileDetails?.key];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonUtilityFunctions().checkForDownloadAvailability(
                    widget.fileHistory!.fileDetails!)
                ? fileTransferProgress != null
                    ? getDownloadStatus(fileTransferProgress)
                    : isDownloaded
                        ? SvgPicture.asset(
                            AppVectors.icCloudDownloaded,
                          )
                        : isDownloading
                            ? CircularProgressIndicator(
                                color: ColorConstants.orange)
                            : InkWell(
                                onTap: () async {
                                  await downloadFiles(
                                      widget.fileHistory?.fileDetails);
                                },
                                child: SvgPicture.asset(
                                  AppVectors.icDownloadFile,
                                ),
                              )
                : SizedBox(),
            SizedBox(width: 12),
            Text(
              '$numberOfFinished/$numberOfAllFiles',
              style: TextStyle(
                fontSize: 11.toFont,
                color: ColorConstants.oldSliver,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        );
      },
    );
  }

  openFileReceiptBottomSheet({FileRecipientSection? fileRecipientSection}) {
    Provider.of<FileTransferProvider>(context, listen: false)
        .selectedFileHistory = widget.fileHistory;

    showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (_context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                insetPadding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  width: 400,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12.0),
                      topRight: const Radius.circular(12.0),
                    ),
                  ),
                  child: FileRecipients(
                    widget.fileHistory!.sharedWith,
                    fileRecipientSection: fileRecipientSection,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> isFilesPresent(FileTransfer files) async {
    isDownloaded = true;
    numberOfFinished = 0;
    for (FileData i in files.files ?? []) {
      final bool isExist =
          await checkFileExist(data: i, sender: files.sender ?? '');
      if (!isExist) {
        isDownloaded = false;
      } else {
        numberOfFinished++;
      }
    }
    if (context.read<HistoryProvider>().isDownloadDone) {
      context.read<HistoryProvider>().resetIsDownloadDone();
    }
    setState(() {});
  }

  Future<bool> checkFileExist(
      {required FileData data, required String sender}) async {
    String filePath =
        await MixedConstants.getFileDownloadLocation(sharedBy: sender);

    File file = File(filePath + Platform.pathSeparator + (data.name ?? ''));
    return await file.exists();
  }

  Future<void> downloadFiles(FileTransfer? file) async {
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

    for (FileData i in file.files ?? []) {
      if (!(await checkFileExist(data: i, sender: file.sender ?? ''))) {
        var result = await Provider.of<HistoryProvider>(
                NavService.navKey.currentContext!,
                listen: false)
            .downloadSingleFile(
          file.key,
          file.sender,
          false,
          i.name ?? '',
        );
        if (result is bool && result) {
          setState(() {
            numberOfFinished++;
          });
          await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .saveNewDataInMyFiles(file);
          print(file.url);
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
              isDownloading = false;
              isDownloaded = false;
            });
            await isFilesPresent(widget.fileHistory!.fileDetails!);
            return;
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        isDownloading = false;

        isDownloaded = true;
      });
      await isFilesPresent(widget.fileHistory!.fileDetails!);
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
    }
  }

  Widget getDownloadStatus(FileTransferProgress? fileTransferProgress) {
    Widget spinner = CircularProgressIndicator(
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
}
