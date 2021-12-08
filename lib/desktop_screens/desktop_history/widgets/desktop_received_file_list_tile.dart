import 'dart:io';
import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:math' as math;
import 'package:video_thumbnail/video_thumbnail.dart';

class DesktopReceivedFilesListTile extends StatefulWidget {
  final FileTransfer receivedHistory;
  final ContactProvider contactProvider;
  final bool isSelected;

  const DesktopReceivedFilesListTile(
      {Key key,
      this.receivedHistory,
      this.contactProvider,
      this.isSelected = false})
      : super(key: key);
  @override
  _DesktopReceivedFilesListTileState createState() =>
      _DesktopReceivedFilesListTileState();
}

class _DesktopReceivedFilesListTileState
    extends State<DesktopReceivedFilesListTile> {
  int fileLength, fileSize = 0;
  List<FileData> filesList = [];
  List<String> contactList;
  bool isOpen = false;
  bool isDeepOpen = false;
  Uint8List videoThumbnail, firstContactImage;
  String contactName;
  List<bool> fileResending = [];
  bool isResendingToFirstContact = false;

  @override
  void initState() {
    super.initState();
    // isWidgetRebuilt = true;
    fileLength = widget.receivedHistory.files.length;
    fileResending = List<bool>.generate(fileLength, (i) => false);
    contactList = [widget.receivedHistory.sender];

    filesList = widget.receivedHistory.files;

    widget.receivedHistory.files.forEach((element) {
      fileSize += element.size;
    });

    getContactImage();
  }

  getContactImage() {
    AtContact contact;

    if (contactList[0] != null) {
      contactName = CommonFunctions().getContactName(contactList[0]);
      contact = checkForCachedContactDetail(contactList[0]);
    }
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        if (mounted) {
          setState(() {
            firstContactImage = Uint8List.fromList(intList);
          });
        }
      }
    }
  }

  Future videoThumbnailBuilder(String path) async {
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
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;

    return Column(
      children: [
        Container(
          color: (widget.isSelected)
              ? ColorConstants.receivedSelectedTileColor
              : null,
          child: ListTile(
            leading: contactList.isNotEmpty
                ? firstContactImage != null
                    ? CustomCircleAvatar(
                        byteImage: firstContactImage, nonAsset: true)
                    : isResendingToFirstContact
                        ? TypingIndicator(
                            showIndicator: true,
                            flashingCircleBrightColor: ColorConstants.dullText,
                            flashingCircleDarkColor: ColorConstants.fadedText,
                          )
                        : Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: firstContactImage != null
                                    ? CustomCircleAvatar(
                                        byteImage: firstContactImage,
                                        nonAsset: true,
                                      )
                                    : ContactInitial(
                                        initials: contactList[0],
                                        size: 50,
                                      ),
                              ),
                            ],
                          )
                : SizedBox(),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        contactName != null
                            ? Text(
                                contactName ?? '',
                                style: CustomTextStyles.primaryRegularBold18,
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        contactList.isNotEmpty
                            ? Text(
                                contactList[0],
                                style: CustomTextStyles.primaryRegular18,
                              )
                            : SizedBox(),
                      ],
                    )),
                  ],
                ),
                SizedBox(height: 5.toHeight),
                SizedBox(
                  height: 8.toHeight,
                ),
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${fileLength} Files',
                            style: CustomTextStyles.secondaryRegular14,
                          ),
                          SizedBox(width: 10.toHeight),
                          Text(
                            '.',
                            style: CustomTextStyles.secondaryRegular14,
                          ),
                          SizedBox(width: 10.toHeight),
                          Text(
                            double.parse(fileSize.toString()) <= 1024
                                ? '${fileSize} Kb '
                                : '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} Mb',
                            style: CustomTextStyles.secondaryRegular14,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Transform.rotate(
                                  angle: 180 * math.pi / 340,
                                  child: Icon(Icons.keyboard_arrow_up),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
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
                      widget.receivedHistory.date != null
                          ? Text(
                              '${DateFormat("MM-dd-yyyy").format(widget.receivedHistory.date)}',
                              style: CustomTextStyles.secondaryRegular14,
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
                      widget.receivedHistory.date != null
                          ? Text(
                              '${DateFormat('kk: mm').format(widget.receivedHistory.date)}',
                              style: CustomTextStyles.secondaryRegular14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                SizedBox(height: 3.toHeight),
              ],
            ),
          ),
        ),
        (isOpen)
            ? Container(
                color: Color(0xffF86060).withAlpha(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 70.0 * widget.receivedHistory.files.length,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                                indent: 80.toWidth,
                              ),
                          itemCount: fileLength,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (FileTypes.VIDEO_TYPES.contains(
                                filesList[index].name?.split('.')?.last)) {
                              videoThumbnailBuilder(filesList[index].path);
                            }
                            return ListTile(
                              onTap: () async {
                                String _path =
                                    MixedConstants.SENT_FILE_DIRECTORY +
                                        '/${filesList[index].name}';
                                File test = File(_path);
                                bool fileExists = await test.exists();
                                print(
                                    'test file: ${test}, fileExists: ${fileExists}');
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
                                            '/${filesList[index].name}'),
                                    builder: (context, snapshot) {
                                      return snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.data != null
                                          ? thumbnail(
                                              filesList[index]
                                                  .name
                                                  ?.split('.')
                                                  ?.last,
                                              MixedConstants
                                                      .SENT_FILE_DIRECTORY +
                                                  '/${filesList[index].name}',
                                              isFilePresent: snapshot.data)
                                          : SizedBox();
                                    }),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          filesList[index].name.toString(),
                                          style:
                                              CustomTextStyles.primaryRegular16,
                                        ),
                                      ),
                                      Container(
                                        child: filesList[index].isUploaded !=
                                                    null &&
                                                filesList[index].isUploaded
                                            ? Icon(
                                                Icons.done,
                                                color: Color(0xFF08CB21),
                                                size: 25.toFont,
                                              )
                                            : fileResending[index]
                                                ? TypingIndicator(
                                                    showIndicator: true,
                                                    flashingCircleBrightColor:
                                                        ColorConstants.dullText,
                                                    flashingCircleDarkColor:
                                                        ColorConstants
                                                            .fadedText,
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        fileResending[index] =
                                                            true;
                                                      });

                                                      fileResending[index] =
                                                          false;
                                                    },
                                                    child: Icon(
                                                      Icons.refresh,
                                                      color: Color(0xFFF86061),
                                                      size: 25.toFont,
                                                    ),
                                                  ),
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10.toHeight),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          double.parse(filesList[index]
                                                      .size
                                                      .toString()) <=
                                                  1024
                                              ? '${filesList[index].size} Kb '
                                              : '${(filesList[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb',
                                          style: CustomTextStyles
                                              .secondaryRegular14,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Text(
                                          '.',
                                          style: CustomTextStyles
                                              .secondaryRegular14,
                                        ),
                                        SizedBox(width: 10.toHeight),
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
                    (contactList.length < 2)
                        ? Container()
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 20.toWidth),
                                  child: Text(
                                    'Delivered to',
                                    style: CustomTextStyles.primaryRegular16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isOpen = !isOpen;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.toWidth),
                        child: Row(
                          children: [
                            Text(
                              'Lesser Details',
                              style: CustomTextStyles.primaryBold14,
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

  Widget thumbnail(String extension, String path, {bool isFilePresent = true}) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: isFilePresent
                  ? Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.image,
                      size: 30.toFont,
                    ),
            ),
          )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(10.toHeight),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50.toHeight,
                    width: 50.toWidth,
                    child: (snapshot.data == null)
                        ? Image.asset(
                            ImageConstants.unknownLogo,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            videoThumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, o, ot) =>
                                CircularProgressIndicator(),
                          ),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 50.toHeight,
                  width: 50.toWidth,
                  child: Image.asset(
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
                  ),
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
              height: 200.0,
              width: 300.0,
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

  Future<bool> isFilePresent(String filePath) async {
    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }
}
