import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../data_models/file_transfer.dart';
import '../../../data_models/file_transfer_status.dart';
import '../../../services/common_utility_functions.dart';
import '../../../services/navigation_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/text_strings.dart';
import '../../../utils/text_styles.dart';
import '../../../view_models/file_transfer_provider.dart';
import '../../common_widgets/confirmation_dialog.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/triple_dot_loading.dart';
import 'file_recipients.dart';

class SentItemFileView extends StatefulWidget {
  final FileHistory sentHistory;
  final Function(bool) isFileViewOpen;

  SentItemFileView(this.sentHistory, this.isFileViewOpen);

  @override
  _SentItemFileViewState createState() => _SentItemFileViewState();
}

class _SentItemFileViewState extends State<SentItemFileView> {
  List<FileData>? filesList = [];
  List<String?> contactList = [];

  @override
  void initState() {
    filesList = widget.sentHistory.fileDetails!.files;
    contactList = widget.sentHistory.sharedWith!.map((e) => e.atsign).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      color: Color(0xffEFEFEF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (SizeConfig().isTablet(context)
                    ? 80.0.toHeight
                    : 70.0.toHeight) *
                widget.sentHistory.fileDetails!.files!.length,
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      indent: 80.toWidth,
                    ),
                itemCount: filesList!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      String _path = MixedConstants.SENT_FILE_DIRECTORY +
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
                            future: CommonUtilityFunctions().isFilePresent(
                              MixedConstants.SENT_FILE_DIRECTORY +
                                  filesList![index].name!,
                            ),
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              return snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null
                                  ? CommonUtilityFunctions().thumbnail(
                                      filesList![index].name?.split('.').last,
                                      MixedConstants.SENT_FILE_DIRECTORY +
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
                                      filesList![index].name.toString(),
                                      style: CustomTextStyles.primaryRegular16,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: (widget.sentHistory.isOperating != null &&
                                      widget.sentHistory.isOperating!)
                                  ? typingIndicator()
                                  : filesList![index].isUploaded != null &&
                                          filesList![index].isUploaded!
                                      ? getFileShareStatus(
                                          filesList![index], index)
                                      : (filesList![index].isUploading !=
                                                  null &&
                                              filesList![index].isUploading!)
                                          ? typingIndicator()
                                          : getFileShareStatus(
                                              filesList![index], index),
                            )
                          ],
                        ),
                        SizedBox(width: 10.toHeight, height: 5),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                style: CustomTextStyles.secondaryRegular12,
                              ),
                              SizedBox(width: 10.toHeight),
                              Text(
                                '.',
                                style: CustomTextStyles.secondaryRegular12,
                              ),
                              SizedBox(width: 10.toHeight),
                              Text(
                                filesList![index].name!.split('.').last,
                                style: CustomTextStyles.secondaryRegular12,
                              ),
                              CommonUtilityFunctions().isFileDownloadAvailable(
                                      widget.sentHistory.fileDetails!.date!)
                                  ? SizedBox()
                                  : Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Container(
                                          color: ColorConstants.fontSecondary,
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
              widget.isFileViewOpen(false);
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

  Widget getFileShareStatus(FileData fileData, int index) {
    // if file upload failed
    if (fileData.isUploaded != null && !fileData.isUploaded!) {
      return retryButton(fileData, index, FileOperation.REUPLOAD_FILE);
    }

    //  file share failed for any receiver
    var _sharedWith = widget.sentHistory.sharedWith ?? [];
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
            .isFileDownloadAvailable(widget.sentHistory.fileDetails!.date!);

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
                          .reuploadFiles(filesList!, index, widget.sentHistory);
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
            child: FileRecipients(
              widget.sentHistory.sharedWith,
              fileRecipientSection: fileRecipientSection,
              key: UniqueKey(),
            ),
          );
        });
  }
}
