import 'dart:io';
import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_compress/video_compress.dart';

class CommonFunctions {
  static final CommonFunctions _singleton = CommonFunctions._internal();
  CommonFunctions._internal();

  factory CommonFunctions() {
    return _singleton;
  }

  getCachedContactImage(String atsign) {
    Uint8List image;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags['image'] != null) {
      List<int> intList = contact.tags['image'].cast<int>();
      image = Uint8List.fromList(intList);
    }

    return image;
  }

  String getContactName(String atsign) {
    String name;
    AtContact contact = getCachedContactDetail(atsign);
    if (contact != null &&
        contact.tags != null &&
        contact.tags['name'] != null) {
      name = contact.tags['name'];
    }
    return name;
  }

  Widget thumbnail(String extension, String path, {bool isFilePresent = true}) {
    path = path.trim();

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
                            snapshot.data,
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
                  height: 40.toHeight,
                  width: 40.toWidth,
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

  Future<Uint8List> videoThumbnailBuilder(String path) async {
    Uint8List videoThumbnail;
    if (Platform.isMacOS) {
      videoThumbnail = await VideoCompress.getByteThumbnail(
        path,
        quality: 50,
      );
      return videoThumbnail;
    } else if (Platform.isAndroid || Platform.isIOS) {
      videoThumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );
    }

    return videoThumbnail;
  }

  Future<bool> isFilePresent(String filePath) async {
    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  getCachedContactName(String atsign) {
    String _name;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags['name'] != null) {
      _name = contact.tags['name'].toString();
    }

    return _name;
  }

  deleteAtSign(String atsign) async {
    final _formKey = GlobalKey<FormState>();
    await showDialog(
        context: NavService.navKey.currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Delete @sign',
                style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 0.1,
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete all data associated with',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.1,
                    color: Colors.grey[700],
                    fontSize: 15.toFont,
                  ),
                ),
                SizedBox(height: 20),
                Text('$atsign',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.toFont,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(
                  'Type the @sign above to proceed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    letterSpacing: 0.1,
                    fontSize: 12.toFont,
                  ),
                ),
                SizedBox(height: 5),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value != atsign) {
                        return "The @sign doesn't match. Please retype.";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConstants.fadedText)),
                        filled: true,
                        fillColor: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Caution: this action can't be undone",
                  style: TextStyle(
                    fontSize: 13.toFont,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                        child: Text(TextStrings().buttonDelete,
                            style: CustomTextStyles.primaryBold14),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            await BackendService.getInstance()
                                .deleteAtSignFromKeyChain(atsign);
                          }
                        }),
                    Spacer(),
                    FlatButton(
                        child: Text(TextStrings().buttonCancel,
                            style: CustomTextStyles.primaryBold14),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  shownConfirmationDialog(String title, Function onYesTap) {
    showDialog(
        context: NavService.navKey.currentContext,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            content: Container(
              width: 400.toWidth,
              padding: EdgeInsets.all(15.toFont),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    SizedBox(
                      height: 20.toHeight,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: onYesTap,
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
}
