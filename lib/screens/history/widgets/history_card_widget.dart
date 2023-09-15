import 'dart:io';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_attachment_card.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
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
  final Function()? onDownloaded;

  const HistoryCardWidget({
    Key? key,
    this.fileHistory,
    this.onDownloaded,
  }) : super(key: key);

  @override
  State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
}

class _HistoryCardWidgetState extends State<HistoryCardWidget> {
  bool isExpanded = false,
      isFileSharedToGroup = false,
      isDownloadAvailable = false,
      isFilesAvailableOffline = true,
      isOverwrite = false,
      isDownloading = false,
      isDownloaded = false;

  String nickName = '';
  List<String?> existingFileNamesToOverwrite = [];
  List<String?> contactList = [];
  List<FileData>? filesList = [];
  Map<String?, Future> _futureBuilder = {};
  int numberOfFinished = 0;

  @override
  void initState() {
    filesList = widget.fileHistory!.fileDetails!.files;

    if (widget.fileHistory?.type == HistoryType.send) {
      _loadSent();
    } else {
      _loadReceived();
    }
    if (widget.fileHistory?.type == HistoryType.received) {
      isFilesPresent(widget.fileHistory!.fileDetails!);
    }
    super.initState();
  }

  void _loadSent() async {
    if (widget.fileHistory!.sharedWith != null) {
      contactList =
          widget.fileHistory!.sharedWith!.map((e) => e.atsign).toList();
      await getDisplayDetails();
    }

    if (widget.fileHistory!.groupName != null) {
      isFileSharedToGroup = true;
    }

    if (mounted) setState(() {});
  }

  void _loadReceived() async {
    // checkForDownloadAvailability();
    // await isFilesAlreadyDownloaded();
    // getFutureBuilders();
    await getDisplayDetails();
    if (mounted) setState(() {});
  }

  Future<void> getDisplayDetails() async {
    AtContact? displayDetails;

    if (widget.fileHistory?.type == HistoryType.send) {
      displayDetails = await getAtSignDetails(contactList[0] ?? '');
    } else {
      displayDetails = await getAtSignDetails(
        widget.fileHistory?.fileDetails?.sender ?? '',
      );
    }

    if (contactList.length - 1 > 0) {
      nickName = "${contactList[0]} and ${contactList.length - 1} others";
    } else {
      if (displayDetails.tags != null) {
        nickName = displayDetails.tags!['nickname'] ??
            displayDetails.tags!['name'] ??
            '';
      }
    }
  }

  void checkForDownloadAvailability() {
    var expiryDate =
        widget.fileHistory!.fileDetails!.date!.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    // if fileList is not having any file then download icon will not be shown
    var isFileUploaded = false;
    widget.fileHistory!.fileDetails!.files!.forEach((FileData fileData) {
      if (fileData.isUploaded!) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      isDownloadAvailable = false;
    }
  }

  Future<void> isFilesAlreadyDownloaded() async {
    widget.fileHistory!.fileDetails!.files!.forEach((element) async {
      String path = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          (element.name ?? '');
      File test = File(path);
      bool fileExists = await test.exists();
      if (fileExists == false) {
        if (mounted) {
          setState(() {
            isFilesAvailableOffline = false;
          });
        }
      } else {
        var fileLatsModified = await test.lastModified();
        if (fileLatsModified.isBefore(widget.fileHistory!.fileDetails!.date!)) {
          existingFileNamesToOverwrite.add(element.name);
          if (mounted) {
            setState(() {
              isOverwrite = true;
            });
          }
        }
      }
    });
  }

  void getFutureBuilders() {
    widget.fileHistory!.fileDetails!.files!.forEach((element) {
      String filePath = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          element.name!;
      _futureBuilder[element.name] =
          CommonUtilityFunctions().isFilePresent(filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("nickname: $nickName");
    // print(
    //     "atSign: ${widget.fileHistory?.type == HistoryType.received ? "${widget.fileHistory?.fileDetails?.sender ?? ''}" : isFileSharedToGroup || contactList.isEmpty ? '' : "${contactList[0] ?? ''}"}");
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isDownloadDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            isFilesPresent(widget.fileHistory!.fileDetails!);
          });
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(left: 36, right: 18),
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
                          child: Text(
                            isFileSharedToGroup
                                ? "${widget.fileHistory?.groupName ?? ''}"
                                    "${contactList.isNotEmpty ? " and ${contactList.length} others" : ""}"
                                : nickName,
                            style: TextStyle(
                              fontSize: 10.toFont,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${DateFormat("MM/dd/yy").format(widget.fileHistory!.fileDetails!.date!)}',
                          style: TextStyle(
                            fontSize: 10.toFont,
                            color: ColorConstants.oldSliver,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 8,
                          color: Color(0xFFD7D7D7),
                          margin: EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                        ),
                        Text(
                          '${DateFormat('kk:mm').format(widget.fileHistory!.fileDetails!.date!)}',
                          style: TextStyle(
                            fontSize: 10.toFont,
                            color: ColorConstants.oldSliver,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstants.lightGreen,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 8,
                            color: ColorConstants.textGreen,
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          height: 16,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                widget.fileHistory?.type == HistoryType.received
                                    ? 8
                                    : 16,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(33),
                            color: ColorConstants.lightGreen,
                          ),
                          child: Center(
                            child: Text(
                              widget.fileHistory?.type == HistoryType.received
                                  ? "Received"
                                  : "Sent",
                              style: TextStyle(
                                color: ColorConstants.textGreen,
                                fontSize: 8.toFont,
                              ),
                            ),
                          ),
                        ),
                        widget.fileHistory?.type == HistoryType.send
                            ? InkWell(
                                onTap: () {
                                  openFileReceiptBottomSheet();
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.done_all,
                                    size: 20,
                                    color: Color(0xFF909090),
                                  ),
                                ),
                              )
                            : Consumer<FileProgressProvider>(
                                builder: (_c, provider, _) {
                                  var fileTransferProgress =
                                      provider.receivedFileProgress[
                                          widget.fileHistory?.fileDetails?.key];
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 8),
                                      CommonUtilityFunctions()
                                              .checkForDownloadAvailability(
                                                  widget.fileHistory!
                                                      .fileDetails!)
                                          ? fileTransferProgress != null
                                              ? Stack(
                                                  children: [
                                                    SvgPicture.asset(
                                                      AppVectors
                                                          .icCloudDownloading,
                                                    ),
                                                    Center(
                                                      child: SizedBox(
                                                        width: 28,
                                                        height: 28,
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: (fileTransferProgress
                                                                      .percent ??
                                                                  0) /
                                                              100,
                                                          strokeWidth: 1,
                                                          color: ColorConstants
                                                              .downloadIndicatorColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : isDownloaded
                                                  ? SvgPicture.asset(
                                                      AppVectors
                                                          .icCloudDownloaded,
                                                    )
                                                  : isDownloading
                                                      ? SizedBox(
                                                          width: 28,
                                                          height: 28,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 1,
                                                            color: ColorConstants
                                                                .downloadIndicatorColor,
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () async {
                                                            await downloadFiles(
                                                                widget
                                                                    .fileHistory
                                                                    ?.fileDetails);
                                                          },
                                                          child:
                                                              SvgPicture.asset(
                                                            AppVectors
                                                                .icDownloadFile,
                                                          ),
                                                        )
                                          : SizedBox(),
                                    ],
                                  );
                                },
                              )
                      ],
                    ),
                    Text(
                      widget.fileHistory?.type == HistoryType.received
                          ? "${widget.fileHistory?.fileDetails?.sender ?? ''}"
                          : isFileSharedToGroup || contactList.isEmpty
                              ? ''
                              : "${contactList[0] ?? ''}",
                      style: TextStyle(
                        fontSize: 8.toFont,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.fileHistory?.type == HistoryType.send
                                ? widget.fileHistory?.notes ?? ''
                                : widget.fileHistory?.fileDetails?.notes ?? '',
                            style: TextStyle(
                              fontSize: 8.toFont,
                              color: Color(0xFF747474),
                            ),
                          ),
                        ),
                        Text(
                          widget.fileHistory?.type == HistoryType.send
                              ? "${filesList!.length} Files"
                              : "${numberOfFinished}/${filesList!.length} Files",
                          style: TextStyle(
                            fontSize: 8.toFont,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.textBlack,
                          ),
                        ),
                        SizedBox(width: 6),
                        isExpanded
                            ? SvgPicture.asset(AppVectors.icArrowUpOutline)
                            : SvgPicture.asset(AppVectors.icArrowDownOutline),
                      ],
                    )
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
                      return ContactAttachmentCard(
                        key: UniqueKey(),
                        fileTransfer: widget.fileHistory!.fileDetails!,
                        singleFile:
                            widget.fileHistory!.fileDetails!.files![index],
                        isShowDate: false,
                        margin: EdgeInsets.fromLTRB(36, 6, 20, 0),
                        onAction: () async {
                          await isFilesPresent(
                              widget.fileHistory!.fileDetails!);
                        },
                      );
                    },
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }

  openFileReceiptBottomSheet({FileRecipientSection? fileRecipientSection}) {
    Provider.of<FileTransferProvider>(context, listen: false)
        .selectedFileHistory = widget.fileHistory;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (_context) {
          return Container(
            height: SizeConfig().screenHeight * 0.8,
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
          );
        });
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
    String filePath = BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        (data.name ?? '');

    File file = File(filePath);
    return await file.exists();
  }
}
