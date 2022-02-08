import 'dart:io';
import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/add_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ReceivedFilesListTile extends StatefulWidget {
  final FileTransfer receivedHistory;
  final bool isWidgetOpen;

  const ReceivedFilesListTile({
    Key key,
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
  DateTime sendTime;
  Uint8List videoThumbnail, image;
  int fileSize = 0;
  List<String> existingFileNamesToOverwrite = [];

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
  void initState() {
    isOpen = widget.isWidgetOpen;
    widget.receivedHistory.files.forEach((element) {
      fileSize += element.size;
    });

    checkForDownloadAvailability();
    getAtSignDetail();
    isFilesAlreadyDownloaded();
    super.initState();
  }

  checkForDownloadAvailability() {
    var expiryDate = widget.receivedHistory.date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    // if fileList is not having any file then download icon will not be shown
    var isFileUploaded = false;
    widget.receivedHistory.files.forEach((FileData fileData) {
      if (fileData.isUploaded) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      isDownloadAvailable = false;
    }
  }

  getAtSignDetail() {
    AtContact contact;
    if (widget.receivedHistory.sender != null) {
      contact = checkForCachedContactDetail(widget.receivedHistory.sender);
    }
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        if (mounted) {
          if (mounted) {
            setState(() {
              image = Uint8List.fromList(intList);
            });
          }
        }
      }
    }
  }

  isFilesAlreadyDownloaded() async {
    widget.receivedHistory.files.forEach((element) async {
      String path = BackendService.getInstance().downloadDirectory.path +
          '/${element.name}';
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
        if (fileLatsModified.isBefore(widget.receivedHistory.date)) {
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

  @override
  Widget build(BuildContext context) {
    sendTime = DateTime.now();
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      color: (isOpen) ? Color(0xffEFEFEF) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading:
                // CustomCircleAvatar(image: ImageConstants.imagePlaceholder),
                widget.receivedHistory.sender != null
                    ? GestureDetector(
                        onTap: ((widget.receivedHistory.sender != null) &&
                                (ContactService().contactList.indexWhere(
                                        (element) =>
                                            element.atSign ==
                                            widget.receivedHistory.sender) ==
                                    -1))
                            ? () async {
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AddContact(
                                      atSignName: widget.receivedHistory.sender,
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
                                      initials: widget.receivedHistory.sender,
                                      size: 45,
                                    ),
                                  ),
                            ((widget.receivedHistory.sender != null) &&
                                    (ContactService().contactList.indexWhere(
                                            (element) =>
                                                element.atSign ==
                                                widget
                                                    .receivedHistory.sender) ==
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
                                        )))
                                : SizedBox()
                          ],
                        ),
                      )
                    : SizedBox(),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: widget.receivedHistory.sender != null
                          ? Text(
                              widget.receivedHistory.sender,
                              style: CustomTextStyles.primaryRegular16,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : SizedBox(),
                    ),
                    InkWell(
                        onTap: () async {
                          if (isOverwrite) {
                            overwriteDialog();
                            return;
                          }
                          await downloadFiles(widget.receivedHistory);
                        },
                        child: isDownloadAvailable
                            ? widget.receivedHistory.isDownloading
                                ? CircularProgressIndicator()
                                : ((isDownloaded || isFilesAvailableOfline) &&
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
                            : SizedBox())
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
                        '${widget.receivedHistory.files.length} File(s)',
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
                            ? '${fileSize} Kb '
                            : '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} Mb',
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
                      widget.receivedHistory.date != null
                          ? Text(
                              '${DateFormat('MM-dd-yyyy').format(widget.receivedHistory.date)}',
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
                      widget.receivedHistory.date != null
                          ? Text(
                              '${DateFormat('kk:mm').format(widget.receivedHistory.date)}',
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
                    ? GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              isOpen = !isOpen;
                            });
                          }
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
          (isOpen)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 70.0 *
                          (widget.receivedHistory.files.length -
                                  widget.receivedHistory.files
                                      .where((element) =>
                                          element.isUploaded == false)
                                      .length)
                              .toHeight,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                                indent: 80.toWidth,
                              ),
                          itemCount: int.parse(
                              widget.receivedHistory.files.length.toString()),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (!widget
                                .receivedHistory.files[index].isUploaded) {
                              return SizedBox();
                            }
                            if (FileTypes.VIDEO_TYPES.contains(widget
                                .receivedHistory.files[index].name
                                ?.split('.')
                                ?.last)) {
                              // videoThumbnailBuilder(
                              //     widget.receivedHistory.files[index].filePath);

                              Text('Video');
                            }
                            return ListTile(
                              onTap: () async {
                                String path = MixedConstants
                                        .RECEIVED_FILE_DIRECTORY +
                                    '/${widget.receivedHistory.files[index].name}';

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
                                          .receivedHistory.files[index].name);
                                  await OpenFile.open(path);
                                }
                              },
                              leading: Container(
                                height: 50.toHeight,
                                width: 50.toHeight,
                                child: FutureBuilder(
                                    future: isFilePresent(widget
                                        .receivedHistory.files[index].name),
                                    builder: (context, snapshot) {
                                      return snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.data != null
                                          ? thumbnail(
                                              widget.receivedHistory
                                                  .files[index].name
                                                  ?.split('.')
                                                  ?.last,
                                              BackendService.getInstance()
                                                      .downloadDirectory
                                                      .path +
                                                  '/${widget.receivedHistory.files[index].name}',
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
                                        child: RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: widget.receivedHistory
                                                .files[index].name
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
                                          double.parse(widget.receivedHistory
                                                      .files[index].size
                                                      .toString()) <=
                                                  1024
                                              ? '${widget.receivedHistory.files[index].size} Kb '
                                              : '${(widget.receivedHistory.files[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb',
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
                                          widget
                                              .receivedHistory.files[index].name
                                              .split('.')
                                              .last
                                              .toString(),
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        ),
                                        SizedBox(width: 10.toHeight),
                                        Text(
                                          (widget.receivedHistory.files[index]
                                                      .isDownloading ??
                                                  false)
                                              ? 'Downloading...'
                                              : '',
                                          style: CustomTextStyles.redSmall12,
                                        ),
                                        CommonUtilityFunctions()
                                                .isFileDownloadAvailable(
                                                    widget.receivedHistory.date)
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
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            isOpen = !isOpen;
                          });
                        }
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
                )
              : Container()
        ],
      ),
    );
  }

  Widget thumbnail(
    String extension,
    String path, {
    bool isFilePresent = true,
  }) {
    // when file overwrite is true, we are not showing file preview.
    if (isOverwrite) {
      isFilePresent = false;
    }
    if (FileTypes.IMAGE_TYPES.contains(extension)) {
      return ClipRRect(
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
      );
    } else {
      return FileTypes.VIDEO_TYPES.contains(extension)
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

  Future<bool> isFilePresent(String fileName) async {
    String filePath =
        BackendService.getInstance().downloadDirectory.path + '/${fileName}';

    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  /// provide [fileName] to download that file
  downloadFiles(FileTransfer receivedHistory, {String fileName}) async {
    var result;
    if (fileName != null) {
      result = await Provider.of<HistoryProvider>(context, listen: false)
          .downloadSingleFile(
        widget.receivedHistory.key,
        widget.receivedHistory.sender,
        isOpen,
        fileName,
      );
    } else {
      result = await Provider.of<HistoryProvider>(context, listen: false)
          .downloadFiles(
        widget.receivedHistory.key,
        widget.receivedHistory.sender,
        isOpen,
      );
    }

    if (result is bool && result) {
      if (mounted) {
        setState(() {
          isDownloaded = true;
          isFilesAvailableOfline = true;
          isOverwrite = false;
        });
      }
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .sendFileDownloadAcknowledgement(receivedHistory);
    } else if (result is bool && !result) {
      if (mounted) {
        setState(() {
          isDownloaded = false;
        });
      }
    }
  }

  overwriteDialog() {
    showDialog(
        context: NavService.navKey.currentContext,
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
                            child: Text('Yes',
                                style: TextStyle(fontSize: 16.toFont))),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: TextStyle(fontSize: 16.toFont)))
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
                text: 'A file named ',
                style: TextStyle(color: Colors.black, fontSize: 15.toFont)),
            TextSpan(
                text: '${existingFileNamesToOverwrite[0]}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.bold)),
            TextSpan(
                text: ' already exists. Do you want to overwrite it?',
                style: TextStyle(color: Colors.black, fontSize: 15.toFont)),
          ],
        ),
      );
    } else if (existingFileNamesToOverwrite.length > 1) {
      textSpansMessage.add(TextSpan(
        text: 'These files already exist: ',
        style: TextStyle(color: Colors.black, fontSize: 15.toFont),
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
            text: '\nDo you want to overwrite them?',
            style:
                TextStyle(color: Colors.black, fontSize: 15.toFont, height: 2)),
      );
    }
    return textSpansMessage;
  }
}
