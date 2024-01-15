import 'dart:io';
import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/add_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../view_models/internet_connectivity_checker.dart';

class ReceivedFilesListTile extends StatefulWidget {
  final FileTransfer? receivedHistory;
  final bool? isWidgetOpen;

  const ReceivedFilesListTile({
    Key? key,
    this.receivedHistory,
    this.isWidgetOpen = false,
  }) : super(key: key);
  @override
  _ReceivedFilesListTileState createState() => _ReceivedFilesListTileState();
}

class _ReceivedFilesListTileState extends State<ReceivedFilesListTile> {
  bool isOpen = false,
      isDownloading = false,
      isDownloaded = false,
      isDownloadAvailable = false,
      isFilesAvailableOfline = true,
      isOverwrite = false;

  DateTime? sendTime;
  Uint8List? videoThumbnail, image;
  int fileSize = 0;
  List<String?> existingFileNamesToOverwrite = [];
  String nickName = '';
  Map<String?, Future> _futureBuilder = {};
  bool isTextExpanded = false;

  Future<Uint8List?> videoThumbnailBuilder(String path) async {
    videoThumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return videoThumbnail;
  }

  @override
  void initState() {
    isOpen = widget.isWidgetOpen ?? false;
    widget.receivedHistory!.files!.forEach((element) {
      fileSize += element.size!;
    });

    checkForDownloadAvailability();
    getAtSignDetail();
    getDisplayDetails();
    isFilesAlreadyDownloaded();
    getFutureBuilders();
    super.initState();
  }

  checkForDownloadAvailability() {
    var expiryDate = widget.receivedHistory!.date!.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    // if fileList is not having any file then download icon will not be shown
    var isFileUploaded = false;
    widget.receivedHistory!.files!.forEach((FileData fileData) {
      if (fileData.isUploaded!) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      isDownloadAvailable = false;
    }
  }

  getAtSignDetail() {
    AtContact? contact;
    if (widget.receivedHistory!.sender != null) {
      contact = checkForCachedContactDetail(widget.receivedHistory!.sender!);
    }
    if (contact != null) {
      if (mounted) {
        setState(() {
          image = CommonUtilityFunctions().getContactImage(contact!);
        });
      }
    }
  }

  getDisplayDetails() async {
    var displayDetails =
        await getAtSignDetails(widget.receivedHistory!.sender!);
    if (displayDetails.tags != null) {
      nickName = displayDetails.tags!['nickname'] ??
          displayDetails.tags!['name'] ??
          '';
      if (mounted) {
        setState(() {});
      }
    }
  }

  isFilesAlreadyDownloaded() async {
    widget.receivedHistory!.files!.forEach((element) async {
      String path = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          (element.name ?? '');
      File test = File(path);
      bool fileExists = await test.exists();
      if (fileExists == false) {
        if (mounted) {
          setState(() {
            isFilesAvailableOfline = false;
          });
        }
      } else {
        var fileLatsModified = await test.lastModified();
        if (fileLatsModified.isBefore(widget.receivedHistory!.date!)) {
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

  getFutureBuilders() {
    widget.receivedHistory!.files!.forEach((element) {
      String filePath = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          element.name!;
      _futureBuilder[element.name] =
          CommonUtilityFunctions().isFilePresent(filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    sendTime = DateTime.now();
    return Column(
      children: [
        Container(
          color: isOpen ? Color(0xffEFEFEF) : null,
          child: ListTile(
            enableFeedback: true,
            onLongPress: deleteReceivedFile,
            leading:
                // CustomCircleAvatar(image: ImageConstants.imagePlaceholder),
                widget.receivedHistory!.sender != null
                    ? GestureDetector(
                        onTap: ((widget.receivedHistory!.sender != null) &&
                                (ContactService().contactList.indexWhere(
                                        (element) =>
                                            element.atSign ==
                                            widget.receivedHistory!.sender) ==
                                    -1))
                            ? () async {
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AddContact(
                                      atSignName:
                                          widget.receivedHistory!.sender,
                                      image: image,
                                    );
                                  },
                                );
                                if (mounted) {
                                  setState(() {});
                                }
                              }
                            : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            image != null
                                ? CustomCircleAvatar(
                                    byteImage: image, nonAsset: true)
                                : Container(
                                    height: 45.toHeight,
                                    width: 45.toHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ContactInitial(
                                      initials: widget.receivedHistory!.sender,
                                      size: 45,
                                    ),
                                  ),
                            ((widget.receivedHistory!.sender != null) &&
                                    (ContactService().contactList.indexWhere(
                                            (element) =>
                                                element.atSign ==
                                                widget
                                                    .receivedHistory!.sender) ==
                                        -1))
                                ? Positioned(
                                    right: -5,
                                    top: -10,
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.person_add,
                                        size: 15.toFont,
                                      ),
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                      )
                    : SizedBox(),
            title: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: nickName.isNotEmpty
                            ? Text(
                                nickName,
                                style: CustomTextStyles.primaryRegular16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                widget.receivedHistory!.sender!.substring(1),
                                style: CustomTextStyles.primaryRegular16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                          onTap: () async {
                            if (isOverwrite) {
                              overwriteDialog();
                              return;
                            }
                            await downloadFiles(widget.receivedHistory);
                          },
                          child: Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Consumer<FileProgressProvider>(
                                  builder: (_c, provider, _) {
                                var fileTransferProgress =
                                    provider.receivedFileProgress[
                                        widget.receivedHistory!.key];
                                return isDownloadAvailable
                                    ? fileTransferProgress != null
                                        ? getDownloadStatus(
                                            fileTransferProgress)
                                        : ((isDownloaded ||
                                                    isFilesAvailableOfline) &&
                                                !isOverwrite)
                                            ? Icon(
                                                Icons.done,
                                                color: Color(0xFF08CB21),
                                                size: 25.toFont,
                                              )
                                            : Icon(
                                                Icons.download_sharp,
                                                size: 25.toFont,
                                              )
                                    : SizedBox();
                              })))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: widget.receivedHistory!.sender != null
                            ? Text(
                                widget.receivedHistory!.sender!,
                                style: CustomTextStyles.primaryMedium14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.toHeight),
                  SizedBox(
                    height: 8.toHeight,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.receivedHistory!.files!.length} ${TextStrings().file_s}',
                          style: CustomTextStyles.secondaryRegular12,
                        ),
                        SizedBox(width: 10.toHeight),
                        Text(
                          '.',
                          style: CustomTextStyles.secondaryRegular12,
                        ),
                        SizedBox(width: 10.toHeight),
                        Text(
                          double.parse(fileSize.toString()) <= 1024
                              ? '${fileSize} ' + TextStrings().kb
                              : '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} ' +
                                  TextStrings().mb,
                          style: CustomTextStyles.secondaryRegular12,
                        ),
                        SizedBox(width: 10.toHeight),
                        Expanded(
                          child: Consumer<FileProgressProvider>(
                            builder: (_context, provider, _widget) {
                              var fileTransferProgress =
                                  provider.receivedFileProgress[
                                      widget.receivedHistory!.key];
                              return fileTransferProgress != null
                                  ? Row(
                                      children: [
                                        Container(
                                          color: ColorConstants.fontSecondary,
                                          height: 14.toHeight,
                                          width: 1.toWidth,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Expanded(
                                          child: Text(
                                              getFileStateMessage(
                                                  fileTransferProgress),
                                              style: TextStyle(
                                                fontSize: 12.toFont,
                                                color: ColorConstants.blueText,
                                                fontWeight: FontWeight.normal,
                                              )),
                                        ),
                                      ],
                                    )
                                  : SizedBox();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.toHeight,
                  ),
                  widget.receivedHistory!.notes != null &&
                          widget.receivedHistory!.notes!.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              isTextExpanded = !isTextExpanded;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Note: ',
                              style: CustomTextStyles.primaryMedium14,
                              children: [
                                TextSpan(
                                  text: '${widget.receivedHistory!.notes}',
                                  style: CustomTextStyles.redSmall12,
                                )
                              ],
                            ),
                            maxLines: isTextExpanded ? null : 1,
                            overflow: isTextExpanded
                                ? TextOverflow.clip
                                : TextOverflow.ellipsis,
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height:
                        widget.receivedHistory!.notes != null ? 5.toHeight : 0,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.receivedHistory!.date != null
                            ? Text(
                                '${DateFormat('MM-dd-yyyy').format(widget.receivedHistory!.date!)}',
                                style: CustomTextStyles.secondaryRegular12,
                              )
                            : SizedBox(),
                        SizedBox(width: 10.toHeight),
                        Container(
                          color: ColorConstants.fontSecondary,
                          height: 14.toHeight,
                          width: 1.toWidth,
                        ),
                        SizedBox(width: 10.toHeight),
                        widget.receivedHistory!.date != null
                            ? Text(
                                '${DateFormat('kk:mm').format(widget.receivedHistory!.date!)}',
                                style: CustomTextStyles.secondaryRegular12,
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.toHeight,
                  ),
                  (!isOpen)
                      ? TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                isOpen = !isOpen;
                              });
                            }
                            updateIsWidgetOpen();
                          },
                          child: Container(
                            child: Row(
                              children: [
                                Text(
                                  TextStrings().seeFiles,
                                  style: CustomTextStyles.primaryBlueBold14,
                                ),
                                Container(
                                  width: 22.toWidth,
                                  height: 22.toWidth,
                                  child: Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        isOpen
            ? Container(
                color: isOpen ? Color(0xffEFEFEF) : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 70.0 *
                          (widget.receivedHistory!.files!.length -
                                  widget.receivedHistory!.files!
                                      .where((element) =>
                                          element.isUploaded == false)
                                      .length)
                              .toHeight,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                                indent: 80.toWidth,
                              ),
                          itemCount: int.parse(
                              widget.receivedHistory!.files!.length.toString()),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (!widget
                                .receivedHistory!.files![index].isUploaded!) {
                              return SizedBox();
                            }
                            if (FileTypes.VIDEO_TYPES.contains(widget
                                .receivedHistory!.files![index].name
                                ?.split('.')
                                .last)) {
                              // videoThumbnailBuilder(
                              //     widget.receivedHistory.files[index].filePath);

                              Text(TextStrings().video);
                            }
                            return ListTile(
                              key: Key(
                                  widget.receivedHistory!.files![index].name!),
                              onTap: () async {
                                String path =
                                    MixedConstants.RECEIVED_FILE_DIRECTORY +
                                        Platform.pathSeparator +
                                        (widget.receivedHistory!.files![index]
                                                .name ??
                                            '');

                                File test = File(path);
                                bool fileExists = await test.exists();
                                print('fileExists: ${fileExists}');
                                if (fileExists) {
                                  await OpenFile.open(path);
                                } else {
                                  if (!isDownloadAvailable) {
                                    return;
                                  }
                                  await downloadFiles(widget.receivedHistory,
                                      fileName: widget
                                          .receivedHistory!.files![index].name);
                                  await OpenFile.open(path);
                                }
                              },
                              leading: Container(
                                height: 50.toHeight,
                                width: 50.toHeight,
                                child: FutureBuilder(
                                    key: Key(widget
                                        .receivedHistory!.files![index].name!),
                                    future: _futureBuilder[widget
                                        .receivedHistory!.files![index].name],
                                    builder: (context, snapshot) {
                                      return snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.data != null
                                          ? CommonUtilityFunctions().thumbnail(
                                              widget.receivedHistory!
                                                  .files![index].name
                                                  ?.split('.')
                                                  .last,
                                              BackendService.getInstance()
                                                      .downloadDirectory!
                                                      .path +
                                                  Platform.pathSeparator +
                                                  (widget.receivedHistory!
                                                          .files![index].name ??
                                                      ''),
                                              isFilePresent:
                                                  snapshot.data as bool)
                                          : SizedBox();
                                    }),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: widget.receivedHistory!
                                                .files![index].name
                                                .toString(),
                                            style: CustomTextStyles
                                                .primaryRegular16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10.toHeight),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          double.parse(widget.receivedHistory!
                                                      .files![index].size
                                                      .toString()) <=
                                                  1024
                                              ? '${widget.receivedHistory!.files![index].size} Kb '
                                              : '${(widget.receivedHistory!.files![index].size! / (1024 * 1024)).toStringAsFixed(2)} Mb',
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Text(
                                          '.',
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Text(
                                          widget.receivedHistory!.files![index]
                                              .name!
                                              .split('.')
                                              .last
                                              .toString(),
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Consumer<FileProgressProvider>(builder:
                                            (_context, _provider, _widget) {
                                          var fileTransferProgress =
                                              _provider.receivedFileProgress[
                                                  widget.receivedHistory!.key];
                                          return Text(
                                            (widget
                                                        .receivedHistory!
                                                        .files![index]
                                                        .isDownloading ??
                                                    false)
                                                ? getSingleFileDownloadMessage(
                                                    fileTransferProgress,
                                                    widget.receivedHistory!
                                                        .files![index].name!)
                                                : '',
                                            style: CustomTextStyles.redSmall12,
                                          );
                                        }),
                                        (CommonUtilityFunctions()
                                                    .isFileDownloadAvailable(
                                                        widget.receivedHistory!
                                                            .date!) ||
                                                isFilesAvailableOfline)
                                            ? SizedBox()
                                            : Row(
                                                children: [
                                                  SizedBox(width: 10),
                                                  Container(
                                                    color: ColorConstants
                                                        .fontSecondary,
                                                    height: 14.toHeight,
                                                    width: 1.toWidth,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(TextStrings().expired,
                                                      style: CustomTextStyles
                                                          .secondaryRegular12),
                                                ],
                                              )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            isOpen = !isOpen;
                          });
                        }
                        updateIsWidgetOpen();
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 85.toHeight),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TextStrings().hideFiles,
                              style: CustomTextStyles.primaryBlueBold14,
                            ),
                            Container(
                              width: 22.toWidth,
                              height: 22.toWidth,
                              child: Center(
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox()
      ],
    );
  }

  /// provide [fileName] to download that file
  downloadFiles(FileTransfer? receivedHistory, {String? fileName}) async {
    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[widget.receivedHistory!.key];

    if (fileTransferProgress != null) {
      return; //returning because download is still in progress
    }
    var isConnected = Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .isInternetAvailable;

    if (!isConnected) {
      SnackBarService().showSnackBar(
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
        widget.receivedHistory!.key,
        widget.receivedHistory!.sender,
        isOpen,
        fileName,
      );
    } else {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadFiles(
        widget.receivedHistory!.key,
        widget.receivedHistory!.sender!,
        isOpen,
      );
    }

    if (result is bool && result) {
      if (mounted) {
        getFutureBuilders();
        setState(() {
          isDownloaded = true;
          isFilesAvailableOfline = true;
          isOverwrite = false;
        });
      }
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(widget.receivedHistory!);

      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownload,
        bgColor: ColorConstants.successGreen,
      );
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(receivedHistory!);
    } else if (result is bool && !result) {
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings().downloadFailed,
        bgColor: ColorConstants.redAlert,
      );
      if (mounted) {
        setState(() {
          isDownloaded = false;
        });
      }
    }
  }

  overwriteDialog() {
    showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            content: Container(
              width: 300.toWidth,
              padding: EdgeInsets.all(15.toFont),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: getOverwriteMessage(),
                      ),
                    ),
                    SizedBox(
                      height: 10.toHeight,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await downloadFiles(widget.receivedHistory);
                            },
                            child: Text(TextStrings().yes,
                                style: TextStyle(
                                  fontSize: 16.toFont,
                                  fontWeight: FontWeight.normal,
                                ))),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(TextStrings().buttonCancel,
                                style: TextStyle(
                                  fontSize: 16.toFont,
                                  fontWeight: FontWeight.normal,
                                )))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  List<TextSpan> getOverwriteMessage() {
    List<TextSpan> textSpansMessage = [];
    if (existingFileNamesToOverwrite.length == 1) {
      textSpansMessage.add(
        TextSpan(
          children: [
            TextSpan(
                text: TextStrings().fileNamed,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                )),
            TextSpan(
                text: '${existingFileNamesToOverwrite[0]}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.bold,
                )),
            TextSpan(
                text: TextStrings().alreadyExistsMsg,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                )),
          ],
        ),
      );
    } else if (existingFileNamesToOverwrite.length > 1) {
      textSpansMessage.add(TextSpan(
        text: TextStrings().fileExists,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.toFont,
          fontWeight: FontWeight.normal,
        ),
      ));

      existingFileNamesToOverwrite.forEach((element) {
        textSpansMessage.add(
          TextSpan(
            text: '\n$element',
            style: TextStyle(
                color: Colors.black,
                fontSize: 13.toFont,
                fontWeight: FontWeight.bold,
                height: 1.5),
          ),
        );
      });

      textSpansMessage.add(
        TextSpan(
            text: TextStrings().overWriteMsg,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.toFont,
              height: 2,
              fontWeight: FontWeight.normal,
            )),
      );
    }
    return textSpansMessage;
  }

  String getFileStateMessage(FileTransferProgress? fileTransferProgress) {
    if (fileTransferProgress == null) {
      return '';
    }

    var index = widget.receivedHistory!.files!
        .indexWhere((element) => element.name == fileTransferProgress.fileName);
    String fileState = '';
    if (fileTransferProgress.fileState == FileState.download) {
      fileState = 'Downloading';
    } else if (fileTransferProgress.fileState == FileState.decrypt) {
      fileState = 'Decrypting';
    }

    if (index != -1) {
      fileState =
          '${fileState} ${index + 1} of ${widget.receivedHistory!.files!.length} File(s)';
    }
    return fileState;
  }

  updateIsWidgetOpen() {
    var receivedHistoryLogs = Provider.of<HistoryProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedHistoryLogs;
    var index = receivedHistoryLogs
        .indexWhere((element) => element.key == widget.receivedHistory!.key);
    if (index != -1) {
      receivedHistoryLogs[index].isWidgetOpen = isOpen;
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

  deleteReceivedFile() async {
    await showModalBottomSheet(
        context: NavService.navKey.currentContext!,
        backgroundColor: Colors.white,
        builder: (context) => EditBottomSheet(
              onConfirmation: () async {
                var res =
                    await Provider.of<HistoryProvider>(context, listen: false)
                        .deleteReceivedItem(widget.receivedHistory!);

                if (res) {
                  SnackBarService().showSnackBar(
                      NavService.navKey.currentContext!,
                      'Removed from received items list',
                      bgColor: ColorConstants.successGreen);
                  await deleteFileWhenRecevedItemRemoved();
                } else {
                  SnackBarService().showSnackBar(
                      NavService.navKey.currentContext!, 'Failed',
                      bgColor: ColorConstants.redAlert);
                }
              },
              deleteMessage: TextStrings.deleteFileConfirmationMsg,
            ));
  }

  deleteFileWhenRecevedItemRemoved() async {
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content: ConfirmationDialog(
                  TextStrings.deleteDownloadedFileMessage, () async {
                await Future.forEach(widget.receivedHistory!.files!,
                    (FileData element) async {
                  String filePath =
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          element.name!;
                  if (await CommonUtilityFunctions().isFilePresent(filePath)) {
                    var file = File(filePath);
                    file.deleteSync();
                  }
                });

                await Provider.of<MyFilesProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .deleteMyFileRecord(widget.receivedHistory!.key);
              }));
        });
  }

  String getSingleFileDownloadMessage(
      FileTransferProgress? fileTransferProgress, String fileName) {
    String downloadMessage = TextStrings().downloading;

    if (fileTransferProgress == null) {
      return downloadMessage;
    }

    if (fileTransferProgress.fileState == FileState.download &&
        fileTransferProgress.percent != null &&
        fileTransferProgress.fileName == fileName) {
      downloadMessage +=
          '(${fileTransferProgress.percent!.toStringAsFixed(0)}%)';
    } else if (fileTransferProgress.fileState == FileState.decrypt) {
      downloadMessage = 'Decrypting...';
    }
    return downloadMessage;
  }
}
