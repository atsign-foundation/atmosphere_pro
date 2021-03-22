import 'dart:io';
import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:at_contacts_group_flutter/widgets/add_single_contact_group.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';

import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

class SentFilesListTile extends StatefulWidget {
  final FilesModel sentHistory;
  final ContactProvider contactProvider;
  final int id;
  final Map<String, Set<FilesDetail>> testList;

  const SentFilesListTile(
      {Key key, this.sentHistory, this.contactProvider, this.testList, this.id})
      : super(key: key);
  @override
  _SentFilesListTileState createState() => _SentFilesListTileState();
}

class _SentFilesListTileState extends State<SentFilesListTile> {
  int fileLength;
  List<FilesDetail> filesList = [];
  Set<AtContact> contactList;
  @override
  void initState() {
    super.initState();
    fileLength = 0;
    contactList = Set<AtContact>();
    widget.testList.forEach((key, value) {
      ContactService().contactList.forEach((element) {
        if (element.atSign == key) {
          contactList.add(element);
        }
      });
      fileLength = widget.testList[key].length;
      print(widget.testList[key].length);
      value.forEach((element) {
        filesList.add(element);
      });
    });
    // contactList
    //     .removeWhere((element) => element.atSign == widget.testList.keys.first);
    print('WIDGET ID===>${widget.id}');
  }

  bool isOpen = false;
  bool isDeepOpen = false;
  DateTime sendTime;
  Uint8List videoThumbnail;

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
    sendTime = DateTime.parse(widget.sentHistory.date);
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    Uint8List image;
    if (contactList?.first?.tags != null &&
        contactList?.first?.tags['image'] != null) {
      List<int> intList = contactList?.first?.tags['image'].cast<int>();
      image = Uint8List.fromList(intList);
    }
    return Column(
      children: [
        Container(
          color: (isOpen) ? Color(0xffF86060).withAlpha(50) : Colors.white,
          child: ListTile(
            leading: (contactList?.first?.tags != null &&
                    contactList?.first?.tags['image'] != null)
                ? CustomCircleAvatar(
                    byteImage: image,
                    nonAsset: true,
                  )
                : ContactInitial(
                    initials:
                        contactList.first.atSign?.substring(1, 3) ?? 'hello',
                  ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.testList.keys.first,
                        style: CustomTextStyles.primaryRegular16,
                      ),
                    ),
                    ContactService()
                            .allContactsList
                            .contains(widget.sentHistory.name)
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AddSingleContact(
                                  atSignName: widget.sentHistory.name,
                                ),
                              );
                              this.setState(() {});
                            },
                            child: Container(
                              height: 20.toHeight,
                              width: 20.toWidth,
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
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
                        '${fileLength} Files',
                        style: CustomTextStyles.secondaryRegular12,
                      ),
                      SizedBox(width: 10.toHeight),
                      Text(
                        '.',
                        style: CustomTextStyles.secondaryRegular12,
                      ),
                      SizedBox(width: 10.toHeight),
                      Text(
                        double.parse(widget.sentHistory.totalSize.toString()) <=
                                1024
                            ? '${widget.sentHistory.totalSize} Kb '
                            : '${(widget.sentHistory.totalSize / (1024 * 1024)).toStringAsFixed(2)} Mb',
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
                      Text(
                        '${DateFormat('MM-dd-yyyy').format(sendTime)}',
                        style: CustomTextStyles.secondaryRegular12,
                      ),
                      SizedBox(width: 10.toHeight),
                      Container(
                        color: ColorConstants.fontSecondary,
                        height: 14.toHeight,
                        width: 1.toWidth,
                      ),
                      SizedBox(width: 10.toHeight),
                      Text(
                        '${DateFormat('kk:mm').format(sendTime)}',
                        style: CustomTextStyles.secondaryRegular12,
                      ),
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
                                'More Details',
                                style: CustomTextStyles.primaryBold14,
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
            trailing: Consumer<FileTransferProvider>(
              builder: (context, provider, _) {
                TransferStatus test =
                    provider.getStatus(widget.id, contactList.first.atSign);
                return Container(
                  height: 20.toHeight,
                  width: 20.toHeight,
                  child: Icon(
                    test == TransferStatus.DONE
                        ? Icons.check_circle_outline_outlined
                        : test == TransferStatus.FAILED
                            ? Icons.cancel_outlined
                            : Icons.priority_high_rounded,
                    color: test == TransferStatus.DONE
                        ? Colors.green
                        : test == TransferStatus.FAILED
                            ? Colors.red
                            : Colors.orange,
                  ),
                  // color: provider.tStatus[i].status ==
                  //         TransferStatus.PENDING
                  //     ? Colors.orange
                  //     : provider.tStatus[i].status ==
                  //             TransferStatus.DONE
                  //         ? Colors.green
                  // : Colors.red,
                );
              },
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
                      height: 166.0 * widget.sentHistory.files.length,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                                indent: 80.toWidth,
                              ),
                          itemCount: fileLength,
                          itemBuilder: (context, index) {
                            if (FileTypes.VIDEO_TYPES.contains(
                                filesList[index].fileName?.split('.')?.last)) {
                              videoThumbnailBuilder(filesList[index].filePath);
                            }
                            return ListTile(
                              onTap: () async {
                                // preview file
                                File test = File(filesList[index].filePath);
                                bool fileExists = await test.exists();
                                if (fileExists) {
                                  await OpenFile.open(
                                      filesList[index].filePath);
                                } else {
                                  _showNoFileDialog(deviceTextFactor);
                                }
                              },
                              leading: Container(
                                height: 50.toHeight,
                                width: 50.toHeight,
                                child: thumbnail(
                                  filesList[index].fileName?.split('.')?.last,
                                  filesList[index].filePath,
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          filesList[index].fileName.toString(),
                                          style:
                                              CustomTextStyles.primaryRegular16,
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
                                          double.parse(filesList[index]
                                                      .size
                                                      .toString()) <=
                                                  1024
                                              ? '${filesList[index].size} Kb '
                                              : '${(filesList[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb',
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
                                          filesList[index].type.toString(),
                                          style: CustomTextStyles
                                              .secondaryRegular12,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    (contactList.isEmpty)
                        ? Container()
                        : SizedBox(
                            height: 10.toHeight,
                          ),
                    (contactList.isEmpty)
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
                    (contactList.isEmpty)
                        ? Container()
                        : SizedBox(
                            height: 10.toHeight,
                          ),
                    (contactList.isEmpty)
                        ? Container()
                        : TranferOverlappingContacts(
                            selectedList: contactList.toList(),
                            id: widget.id,
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

  Widget thumbnail(String extension, String path) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
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
}
