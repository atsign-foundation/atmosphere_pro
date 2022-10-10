import 'dart:io';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CommonUtilityFunctions {
  static final CommonUtilityFunctions _singleton =
      CommonUtilityFunctions._internal();
  CommonUtilityFunctions._internal();

  factory CommonUtilityFunctions() {
    return _singleton;
  }

  Uint8List? getCachedContactImage(String atsign) {
    Uint8List? image;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags!['image'] != null) {
      try {
        return getContactImage(contact);
      } catch (e) {
        print('error in getting atsign image : $e');
      }
    }

    return image;
  }

  String? getContactName(String atsign) {
    String? name;
    AtContact? contact = getCachedContactDetail(atsign);
    if (contact != null &&
        contact.tags != null &&
        contact.tags!['name'] != null) {
      name = contact.tags!['name'];
    }
    return name;
  }

  getCachedContactName(String atsign) {
    String? _name;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags!['name'] != null) {
      _name = contact.tags!['name'].toString();
    }

    return _name;
  }

  Future<bool> isFilePresent(String filePath) async {
    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  showResetAtsignDialog() async {
    bool isSelectAtsign = false;
    bool? isSelectAll = false;
    var atsignsList = await KeychainUtil.getAtsignList();
    if (atsignsList == null) {
      atsignsList = [];
    }
    Map atsignMap = {};
    for (String atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    GlobalKey _one = GlobalKey();
    BuildContext? myContext;
    await showDialog(
        barrierDismissible: true,
        context: NavService.navKey.currentContext!,
        builder: (BuildContext context) {
          return ShowCaseWidget(builder: Builder(builder: (context) {
            myContext = context;
            return StatefulBuilder(builder: (context, stateSet) {
              return Dialog(
                  child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Showcase(
                              key: _one,
                              description:
                                  'You can have more than one atSign associated with this app and can remove one or all of the atSigns from the app at any time.',
                              shapeBorder: CircleBorder(),
                              disableAnimation: true,
                              radius: BorderRadius.all(Radius.circular(40)),
                              showArrow: false,
                              overlayPadding: EdgeInsets.all(5),
                              blurValue: 2,
                              child: Text(
                                TextStrings.resetDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ShowCaseWidget.of(myContext!)
                                  .startShowCase([_one]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(50)),
                              margin: EdgeInsets.all(0),
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.question_mark,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 0.8,
                      ),
                      atsignsList!.isEmpty
                          ? Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(TextStrings.noAtsignToReset,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    TextStrings().buttonClose,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      // color: AtTheme.themecolor,
                                    ),
                                  ),
                                ),
                              )
                            ])
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CheckboxListTile(
                                  onChanged: (value) {
                                    isSelectAll = value;
                                    atsignMap.updateAll(
                                        (key, value1) => value1 = value);
                                    // atsignMap[atsign] = value;
                                    stateSet(() {});
                                  },
                                  value: isSelectAll,
                                  checkColor: Colors.white,
                                  activeColor: Theme.of(context).primaryColor,
                                  title: Text(TextStrings().selectAll,
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
                                    activeColor: Theme.of(context).primaryColor,
                                    title: Text('$atsign'),
                                  ),
                                Divider(thickness: 0.8),
                              ],
                            ),
                      if (isSelectAtsign)
                        Text(TextStrings.resetErrorText,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(TextStrings.resetWarningText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            TextStrings().buttonCancel,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor)),
                          onPressed: () async {
                            var tempAtsignMap = {};
                            tempAtsignMap.addAll(atsignMap);
                            tempAtsignMap
                                .removeWhere((key, value) => value == false);
                            int atsignsListLength =
                                tempAtsignMap.keys.toList().length;
                            if (tempAtsignMap.keys.toList().isEmpty) {
                              isSelectAtsign = true;
                              stateSet(() {});
                            } else {
                              showConfirmationDialog(() async {
                                isSelectAtsign = false;
                                await _resetDevice(tempAtsignMap.keys.toList());
                                await _onboardNextAtsign();
                              }, 'Remove ${atsignsListLength} atSign${atsignsListLength > 1 ? 's' : ''} from this device?');
                            }
                          },
                          child: Text(TextStrings().remove,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              )),
                        ),
                      ])
                    ],
                  ),
                ),
              ));
            });
          }));
        });
  }

  _resetDevice(List checkedAtsigns) async {
    Navigator.of(NavService.navKey.currentContext!).pop();
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
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.HOME, (Route<dynamic> route) => false);
    } else if (atSignList == null || atSignList.isEmpty) {
      BackendService.getInstance().periodicHistoryRefresh?.cancel();
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.HOME, (Route<dynamic> route) => false);
    }
  }

  Widget thumbnail(String? extension, String? path,
      {bool? isFilePresent = true}) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: isFilePresent!
                  ? Image.file(
                      File(path!),
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext _context, _, __) {
                        return Container(
                          child: Icon(
                            Icons.image,
                            size: 30.toFont,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.image,
                      size: 30.toFont,
                    ),
            ),
          )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path!),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(10.toHeight),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50.toHeight,
                    width: 50.toWidth,
                    child: (snapshot.data == null)
                        ? Image.asset(ImageConstants.videoLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext _context, _, __) {
                            return Container(
                              child: Icon(
                                Icons.image,
                                size: 30.toFont,
                              ),
                            );
                          })
                        : Image.memory(
                            snapshot.data as Uint8List,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext _context, _, __) {
                              return Container(
                                child: Icon(
                                  Icons.image,
                                  size: 30.toFont,
                                ),
                              );
                            },
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
                                        : FileTypes.ARCHIVE_TYPES
                                                .contains(extension)
                                            ? ImageConstants.archiveLogo
                                            : FileTypes.WEB_IMAGE_TYPES
                                                    .contains(extension)
                                                ? ImageConstants.svgLogo
                                                : ImageConstants.otherFileLogo,
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

  Uint8List? getContactImage(AtContact contact) {
    Uint8List? image;
    if (contact.tags != null && contact.tags!['image'] != null) {
      try {
        List<int> intList = contact.tags!['image'].cast<int>();
        image = Uint8List.fromList(intList);
      } catch (e) {
        print('error in getting atsign image : $e');
      }
    }

    return image;
  }

  showConfirmationDialog(Function onSuccess, String title) {
    showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            content: ConfirmationDialog(title, onSuccess),
          );
        });
  }

  deleteAtSign(String atsign) async {
    final _formKey = GlobalKey<FormState>();
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                TextStrings().deleteAtSign,
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
                  TextStrings().deleteDataMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.1,
                    color: Colors.grey[700],
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.normal,
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
                  TextStrings().typeAtsignAbove,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    letterSpacing: 0.1,
                    fontSize: 12.toFont,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 5),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value != atsign) {
                        return TextStrings().atSignDoesNotMatch;
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
                  TextStrings().actionCannotUndone,
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
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        TextStrings().buttonCancel,
                        style: TextStyle(
                          fontSize: 16.toFont,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await BackendService.getInstance()
                                .deleteAtSignFromKeyChain(atsign);
                          }
                        },
                        child: Text(TextStrings().buttonDelete,
                            style: TextStyle(
                                fontSize: 16.toFont,
                                fontWeight: FontWeight.normal,
                                color: Colors.white))),
                  ],
                )
              ],
            ),
          );
        });
  }

  shownConfirmationDialog(String title, Function onYesTap) {
    showDialog(
        context: NavService.navKey.currentContext!,
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
                            onPressed: onYesTap as void Function()?,
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

  void showNoFileDialog({double deviceTextFactor = 1}) {
    showDialog(
        context: NavService.navKey.currentContext!,
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
}
