import 'dart:io';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CommonUtilityFunctions {
  static final CommonUtilityFunctions _singleton =
      CommonUtilityFunctions._internal();
  CommonUtilityFunctions._internal();

  factory CommonUtilityFunctions() {
    return _singleton;
  }

  Uint8List getCachedContactImage(String atsign) {
    Uint8List image;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags['image'] != null) {
      try {
        List<int> intList = contact.tags['image'].cast<int>();
        image = Uint8List.fromList(intList);
      } catch (e) {
        print('error in getting atsign image : $e');
      }
    }

    return image;
  }

  showResetAtsignDialog() async {
    bool isSelectAtsign = false;
    bool isSelectAll = false;
    var atsignsList = await KeychainUtil.getAtsignList();
    if (atsignsList == null) {
      atsignsList = [];
    }
    Map atsignMap = {};
    for (String atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    await showDialog(
        barrierDismissible: true,
        context: NavService.navKey.currentContext,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, stateSet) {
            return AlertDialog(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TextStrings.resetDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 0.8,
                    )
                  ],
                ),
                content: atsignsList.isEmpty
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(TextStrings.noAtsignToReset,
                            style: TextStyle(fontSize: 15)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 15,
                                // color: AtTheme.themecolor,
                              ),
                            ),
                          ),
                        )
                      ])
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CheckboxListTile(
                              onChanged: (value) {
                                isSelectAll = value;
                                atsignMap
                                    .updateAll((key, value1) => value1 = value);
                                // atsignMap[atsign] = value;
                                stateSet(() {});
                              },
                              value: isSelectAll,
                              checkColor: Colors.white,
                              title: Text('Select All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            for (var atsign in atsignsList)
                              CheckboxListTile(
                                onChanged: (value) {
                                  atsignMap[atsign] = value;
                                  stateSet(() {});
                                },
                                value: atsignMap[atsign],
                                checkColor: Colors.white,
                                title: Text('$atsign'),
                              ),
                            Divider(thickness: 0.8),
                            if (isSelectAtsign)
                              Text(TextStrings.resetErrorText,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(TextStrings.resetWarningText,
                                style: TextStyle(fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(children: [
                              TextButton(
                                onPressed: () async {
                                  var tempAtsignMap = {};
                                  tempAtsignMap.addAll(atsignMap);
                                  tempAtsignMap.removeWhere(
                                      (key, value) => value == false);
                                  int atsignsList =
                                      tempAtsignMap.keys.toList().length;
                                  if (tempAtsignMap.keys.toList().isEmpty) {
                                    isSelectAtsign = true;
                                    stateSet(() {});
                                  } else {
                                    showConfirmationDialog(() async {
                                      isSelectAtsign = false;
                                      await _resetDevice(
                                          tempAtsignMap.keys.toList());
                                      await _onboardNextAtsign();
                                    }, 'Remove ${atsignsList} @sign${atsignsList > 1 ? 's' : ''} from this device?');
                                  }
                                },
                                child: Text('Remove',
                                    style: TextStyle(
                                      color: ColorConstants.fontPrimary,
                                      fontSize: 15,
                                    )),
                              ),
                              Spacer(),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black)))
                            ])
                          ],
                        ),
                      ));
          });
        });
  }

  _resetDevice(List checkedAtsigns) async {
    Navigator.of(NavService.navKey.currentContext).pop();
    await BackendService.getInstance()
        .resetAtsigns(checkedAtsigns)
        .then((value) async {
      print('reset done');
    }).catchError((e) {
      print('error in reset: $e');
    });
  }

  _onboardNextAtsign() async {
    var _backendService = BackendService.getInstance();
    var atSignList = await KeychainUtil.getAtsignList();
    if (atSignList != null &&
        atSignList.isNotEmpty &&
        _backendService.currentAtSign != atSignList.first) {
      // _backendService.checkToOnboard(atSign: atSignList.first);
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext,
          Routes.HOME, (Route<dynamic> route) => false);
    } else if (atSignList == null || atSignList.isEmpty) {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext,
          Routes.HOME, (Route<dynamic> route) => false);
    }
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

  Future videoThumbnailBuilder(String path) async {
    var videoThumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return videoThumbnail;
  }

  bool isFileDownloadAvailable(DateTime date) {
    var expiryDate = date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      return true;
    } else {
      return false;
    }
  }

  Uint8List getContactImage(AtContact contact) {
    Uint8List image;
    if (contact.tags != null && contact.tags['image'] != null) {
      try {
        List<int> intList = contact.tags['image'].cast<int>();
        image = Uint8List.fromList(intList);
      } catch (e) {
        print('error in getting atsign image : $e');
      }
    }

    return image;
  }

  showConfirmationDialog(Function onSuccess, String title) {
    showDialog(
        context: NavService.navKey.currentContext,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            content: ConfirmationDialog(title, onSuccess),
          );
        });
  }
}
