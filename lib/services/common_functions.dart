import 'dart:io';
import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
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
}
