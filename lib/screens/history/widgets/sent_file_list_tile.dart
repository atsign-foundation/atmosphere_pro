import 'dart:io';
import 'dart:typed_data';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class SentFilesListTile extends StatefulWidget {
  final FileHistory? sentHistory;

  const SentFilesListTile({
    Key? key,
    this.sentHistory,
  }) : super(key: key);
  @override
  _SentFilesListTileState createState() => _SentFilesListTileState();
}

class _SentFilesListTileState extends State<SentFilesListTile> {
  int fileSize = 0;
  List<FileData>? filesList = [];
  List<String?> contactList = [];
  String nickName = '';
  bool isOpen = false, isDeepOpen = false, isFileSharedToGroup = false;
  Uint8List? videoThumbnail, firstContactImage;

  List<bool> fileResending = [];
  bool isResendingToFirstContact = false;

  @override
  void initState() {
    super.initState();
    if (widget.sentHistory!.sharedWith != null) {
      contactList =
          widget.sentHistory!.sharedWith!.map((e) => e.atsign).toList();
      getDisplayDetails();
    } else {
      contactList = [];
    }
    filesList = widget.sentHistory!.fileDetails!.files;

    widget.sentHistory!.fileDetails!.files!.forEach((element) {
      fileSize += element.size!;
    });

    if (contactList[0] != null) {
      firstContactImage =
          CommonUtilityFunctions().getCachedContactImage(contactList[0]!);
    }

    if (widget.sentHistory!.groupName != null) {
      isFileSharedToGroup = true;
    }
  }

  getDisplayDetails() async {
    var displayDetails = await getAtSignDetails(contactList[0] ?? '');
    if (displayDetails.tags != null) {
      nickName = displayDetails.tags!['nickname'] ??
          displayDetails.tags!['name'] ??
          '';
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        Container(
          color: (isOpen) ? Color(0xffEFEFEF) : null,
          child: ListTile(
            enableFeedback: true,
            onLongPress: deleteSentFile,
            leading: contactList.isNotEmpty
                ? Container(
                    width: 55.toHeight,
                    height: 55.toHeight,
                    child: isResendingToFirstContact
                        ? TypingIndicator(
                            showIndicator: true,
                            flashingCircleBrightColor: ColorConstants.dullText,
                            flashingCircleDarkColor: ColorConstants.fadedText,
                          )
                        : Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  openFileReceiptBottomSheet();
                                },
                                child: Container(
                                  width: 45.toHeight,
                                  height: 45.toHeight,
                                  child: (firstContactImage != null &&
                                          !isFileSharedToGroup)
                                      ? CustomCircleAvatar(
                                          byteImage: firstContactImage,
                                          nonAsset: true,
                                          size: 50,
                                        )
                                      : ContactInitial(
                                          initials: isFileSharedToGroup
                                              ? widget.sentHistory!.groupName
                                              : contactList[0],
                                          size: 50,
                                        ),
                                ),
                              ),
                              (contactList.length > 1 ||
                                      isFileDownloadedForSingleAtsign())
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        height: 35.toHeight,
                                        width: 35.toHeight,
                                        child: ContactInitial(
                                          initials: '  ',
                                          background: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              (contactList.length > 1 ||
                                      isFileDownloadedForSingleAtsign())
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: InkWell(
                                        onTap: () {
                                          openFileReceiptBottomSheet();
                                        },
                                        child: Container(
                                          height: 35.toHeight,
                                          width: 35.toHeight,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50.toWidth),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5)),
                                          child: Center(
                                            child: contactList.length > 1
                                                ? Text(
                                                    isFileSharedToGroup
                                                        ? '+${contactList.length}'
                                                        : '+${contactList.length - 1}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.toFont))
                                                : Icon(Icons.download_done,
                                                    color: Colors.white,
                                                    size: 15),
                                          ),
                                        ),
                                      ))
                                  : SizedBox()
                            ],
                          ),
                  )
                : SizedBox(),
            title: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: nickName.isNotEmpty
                              ? RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: '${nickName}',
                                      style: CustomTextStyles.primaryRegular16,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          openFileReceiptBottomSheet();
                                        },
                                    ),
                                  ]),
                                )
                              : SizedBox()),
                    ],
                  ),
                  isFileSharedToGroup == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: contactList.isNotEmpty
                                  ? RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: '${contactList[0]} ',
                                            style: CustomTextStyles
                                                .primaryMedium14,
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                openFileReceiptBottomSheet();
                                              },
                                            children: [
                                              contactList.length - 1 > 0
                                                  ? TextSpan(
                                                      text: 'and ',
                                                    )
                                                  : TextSpan(),
                                              contactList.length - 1 > 0
                                                  ? TextSpan(
                                                      text:
                                                          '${contactList.length - 1} others',
                                                      style: CustomTextStyles
                                                          .blueRegular16,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              openFileReceiptBottomSheet();
                                                            })
                                                  : TextSpan()
                                            ]),
                                      ]),
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                  onTap: openFileReceiptBottomSheet,
                                  child: Text(widget.sentHistory!.groupName!)),
                            )
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
                          '${filesList!.length} File(s)',
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
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.toHeight,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.sentHistory!.fileDetails!.date != null
                            ? Text(
                                '${DateFormat("MM-dd-yyyy").format(widget.sentHistory!.fileDetails!.date!)}',
                                style: CustomTextStyles.secondaryRegular12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox(),
                        SizedBox(width: 10.toHeight),
                        Container(
                          color: ColorConstants.fontSecondary,
                          height: 14.toHeight,
                          width: 1.toWidth,
                        ),
                        SizedBox(width: 10.toHeight),
                        widget.sentHistory!.fileDetails!.date != null
                            ? Text(
                                '${DateFormat('kk: mm').format(widget.sentHistory!.fileDetails!.date!)}',
                                style: CustomTextStyles.secondaryRegular12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.toHeight,
                  ),
                  (!isOpen)
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isOpen = !isOpen;
                            });
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
        (isOpen)
            ? Container(
                color: Color(0xffEFEFEF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: (SizeConfig().isTablet(context)
                              ? 80.0.toHeight
                              : 70.0.toHeight) *
                          widget.sentHistory!.fileDetails!.files!.length,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                                indent: 80.toWidth,
                              ),
                          itemCount: filesList!.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                String _path =
                                    MixedConstants.SENT_FILE_DIRECTORY +
                                        filesList![index].name!;
                                File test = File(_path);
                                bool fileExists = await test.exists();

                                if (fileExists) {
                                  await OpenFile.open(_path);
                                } else {
                                  _showNoFileDialog(deviceTextFactor);
                                }
                              },
                              leading: Container(
                                  height: 50.toHeight,
                                  width: 50.toHeight,
                                  child: FutureBuilder(
                                      future: isFilePresent(
                                        MixedConstants.SENT_FILE_DIRECTORY +
                                            filesList![index].name!,
                                      ),
                                      builder: (context,
                                          AsyncSnapshot<bool> snapshot) {
                                        return snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.data != null
                                            ? CommonUtilityFunctions().thumbnail(
                                                filesList![index]
                                                    .name
                                                    ?.split('.')
                                                    ?.last,
                                                MixedConstants
                                                        .SENT_FILE_DIRECTORY +
                                                    filesList![index].name!,
                                                isFilePresent: snapshot.data)
                                            : SizedBox();
                                      })),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                filesList![index]
                                                    .name
                                                    .toString(),
                                                style: CustomTextStyles
                                                    .primaryRegular16,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // upload failed icon
                                            // (filesList[index].isUploaded !=
                                            //             null &&
                                            //         !filesList[index]
                                            //             .isUploaded)
                                            //     ? Tooltip(
                                            //         message: 'Upload failed',
                                            //         child: Icon(
                                            //             Icons
                                            //                 .priority_high_outlined,
                                            //             color: ColorConstants
                                            //                 .redAlert,
                                            //             size: 20),
                                            //       )
                                            //     : SizedBox(),
                                            // Expanded(
                                            //   child: SizedBox(),
                                            // )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: (widget.sentHistory!
                                                        .isOperating !=
                                                    null &&
                                                widget
                                                    .sentHistory!.isOperating!)
                                            ? typingIndicator()
                                            : filesList![index].isUploaded !=
                                                        null &&
                                                    filesList![index]
                                                        .isUploaded!
                                                ? getFileShareStatus(
                                                    filesList![index], index)
                                                : (filesList![index]
                                                                .isUploading !=
                                                            null &&
                                                        filesList![index]
                                                            .isUploading!)
                                                    ? typingIndicator()
                                                    : getFileShareStatus(
                                                        filesList![index],
                                                        index),
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10.toHeight, height: 5),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          double.parse(filesList![index]
                                                      .size
                                                      .toString()) <=
                                                  1024
                                              ? '${filesList![index].size} ' +
                                                  TextStrings().kb
                                              : '${(filesList![index].size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                                                  TextStrings().mb,
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
                                          filesList![index]
                                              .name!
                                              .split('.')
                                              .last,
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        ),
                                        CommonUtilityFunctions()
                                                .isFileDownloadAvailable(widget
                                                    .sentHistory!
                                                    .fileDetails!
                                                    .date!)
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
                                              ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    (contactList.length < 2)
                        ? Container()
                        : SizedBox(
                            height: 10.toHeight,
                          ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isOpen = !isOpen;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 85.toHeight),
                        child: Row(
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
            : Container()
      ],
    );
  }

  void _showNoFileDialog(double deviceTextFactor) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              height: 200.0.toHeight,
              width: 300.0.toWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Text(
                    TextStrings().noFileFound,
                    style: CustomTextStyles.primaryBold16,
                  ),
                  Padding(padding: EdgeInsets.only(top: 30.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        height: 50.toHeight * deviceTextFactor,
                        isInverted: false,
                        buttonText: TextStrings().buttonClose,
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool isFileDownloadedForSingleAtsign() {
    bool _isDownloaded = false;

    widget.sentHistory!.sharedWith!.forEach((element) {
      if (element.isFileDownloaded!) {
        _isDownloaded = true;
      }
    });
    return _isDownloaded;
  }

  Future<bool> isFilePresent(String filePath) async {
    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  openFileReceiptBottomSheet({FileRecipientSection? fileRecipientSection}) {
    Provider.of<FileTransferProvider>(context, listen: false)
        .selectedFileHistory = widget.sentHistory;

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
            child: FileRecipients(widget.sentHistory!.sharedWith,
                fileRecipientSection: fileRecipientSection),
          );
        });
  }

  Widget getFileShareStatus(FileData fileData, int index) {
    // if file upload failed
    if (fileData.isUploaded != null && !fileData.isUploaded!) {
      return retryButton(fileData, index, FileOperation.REUPLOAD_FILE);
    }

    //  file share failed for any receiver
    var _sharedWith = widget.sentHistory!.sharedWith ?? [];
    for (ShareStatus sharedWithAtsign in _sharedWith) {
      if (sharedWithAtsign.isNotificationSend != null &&
          !sharedWithAtsign.isNotificationSend!) {
        return retryButton(fileData, index, FileOperation.RESEND_NOTIFICATION);
      }
    }

    // file everyone received file
    for (ShareStatus sharedWithAtsign in _sharedWith) {
      if (sharedWithAtsign.isFileDownloaded != null &&
          !sharedWithAtsign.isFileDownloaded!) {
        return sentConfirmation();
      }
    }

    // if file is downloaded by everyone
    return downloadedConfirmation();
  }

  Widget retryButton(FileData fileData, index, FileOperation fileOperation) {
    return InkWell(
      onTap: () async {
        var isFileDownloadAvailable = CommonUtilityFunctions()
            .isFileDownloadAvailable(widget.sentHistory!.fileDetails!.date!);

        if (fileOperation == FileOperation.REUPLOAD_FILE &&
            isFileDownloadAvailable) {
          await showDialog(
              context: NavService.navKey.currentContext!,
              builder: (context) {
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.toWidth),
                    ),
                    content: ConfirmationDialog(TextStrings.reUploadFileMsg,
                        () async {
                      await Provider.of<FileTransferProvider>(context,
                              listen: false)
                          .reuploadFiles(
                              filesList!, index, widget.sentHistory!);
                    }));
              });
        } else {
          openFileReceiptBottomSheet(
              fileRecipientSection: FileRecipientSection.FAILED);
        }
      },
      child: SizedBox(
        width: 60,
        child: Icon(
          Icons.refresh,
          color: Color(0xFFF86061),
          size: 25.toFont,
        ),
      ),
    );
  }

  Widget sentConfirmation() {
    return InkWell(
      onTap: () async {
        openFileReceiptBottomSheet(
            fileRecipientSection: FileRecipientSection.DELIVERED);
      },
      child: SizedBox(
        width: 60,
        child: Icon(
          Icons.done,
          color: ColorConstants.successGreen,
          size: 25.toFont,
        ),
      ),
    );
  }

  Widget downloadedConfirmation() {
    return InkWell(
      onTap: () async {
        openFileReceiptBottomSheet(
            fileRecipientSection: FileRecipientSection.DOWNLOADED);
      },
      child: SizedBox(
        width: 60,
        child: Icon(
          Icons.done_all_outlined,
          color: ColorConstants.blueText,
          size: 25.toFont,
        ),
      ),
    );
  }

  deleteSentFile() async {
    await showModalBottomSheet(
        context: NavService.navKey.currentContext!,
        backgroundColor: Colors.white,
        builder: (context) => EditBottomSheet(fileHistory: widget.sentHistory));
  }

  Widget typingIndicator() {
    return SizedBox(
      height: 10,
      child: TypingIndicator(
        showIndicator: true,
        flashingCircleBrightColor: ColorConstants.dullText,
        flashingCircleDarkColor: ColorConstants.fadedText,
      ),
    );
  }
}
