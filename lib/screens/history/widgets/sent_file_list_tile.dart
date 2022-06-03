import 'dart:io';
import 'dart:typed_data';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/sent_item_file_view.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
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
  bool isTextExpanded = false;

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
    return Column(
      children: [
        Container(
          color: (isOpen) ? Color(0xffEFEFEF) : null,
          child: ListTile(
            enableFeedback: true,
            onLongPress: deleteSentFile,
            leading: getListTileLeading(),
            title: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isFileSharedToGroup == false
                      ? getContactNickname()
                      : SizedBox(),
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
                                          style:
                                              CustomTextStyles.primaryMedium14,
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
                                          ],
                                        ),
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
                    height: 10.toHeight,
                  ),
                  widget.sentHistory!.notes != null &&
                          widget.sentHistory!.notes!.isNotEmpty
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
                                  text: '${widget.sentHistory!.notes}',
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
                    height: widget.sentHistory!.notes != null ? 5.toHeight : 0,
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
                  SizedBox(height: 3.toHeight),
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
            ? SentItemFileView(widget.sentHistory!, onFileViewChange)
            : SizedBox()
      ],
    );
  }

  Widget getListTileLeading() {
    return contactList.isNotEmpty
        ? Container(
            width: 55.toHeight,
            height: 55.toHeight,
            child: Stack(
              children: [
                InkWell(
                  onTap: openFileReceiptBottomSheet,
                  child: Container(
                    width: 45.toHeight,
                    height: 45.toHeight,
                    child: (firstContactImage != null && !isFileSharedToGroup)
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
                (contactList.length > 1 || isFileDownloadedForSingleAtsign())
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
                (contactList.length > 1 || isFileDownloadedForSingleAtsign())
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: openFileReceiptBottomSheet,
                          child: Container(
                            height: 35.toHeight,
                            width: 35.toHeight,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(50.toWidth),
                                border: Border.all(
                                    color: Colors.white, width: 1.5)),
                            child: Center(
                              child: contactList.length > 1
                                  ? Text(
                                      isFileSharedToGroup
                                          ? '+${contactList.length}'
                                          : '+${contactList.length - 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.toFont,
                                        fontWeight: FontWeight.normal,
                                      ))
                                  : Icon(Icons.download_done,
                                      color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          )
        : SizedBox();
  }

  Widget getContactNickname() {
    return Row(
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
    );
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
            child: FileRecipients(
              widget.sentHistory!.sharedWith,
              fileRecipientSection: fileRecipientSection,
              key: UniqueKey(),
            ),
          );
        });
  }

  deleteSentFile() async {
    await showModalBottomSheet(
        context: NavService.navKey.currentContext!,
        backgroundColor: Colors.white,
        builder: (context) => EditBottomSheet(
              onConfirmation: () async {
                await Provider.of<HistoryProvider>(context, listen: false)
                    .deleteSentItem(widget.sentHistory!.fileDetails!.key);
              },
            ));
  }

  onFileViewChange(bool _isOpen) {
    setState(() {
      isOpen = _isOpen;
    });
  }
}
