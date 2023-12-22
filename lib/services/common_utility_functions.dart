import 'dart:io';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CommonUtilityFunctions {
  static final CommonUtilityFunctions _singleton =
      CommonUtilityFunctions._internal();

  CommonUtilityFunctions._internal();

  factory CommonUtilityFunctions() {
    return _singleton;
  }

  Uint8List? getCachedContactImage(String atSign) {
    Uint8List? image;
    AtContact contact = checkForCachedContactDetail(atSign);

    if (contact.tags != null && contact.tags!['image'] != null) {
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

  getCachedContactName(String atSign) {
    String? _name;
    AtContact contact = checkForCachedContactDetail(atSign);

    if (contact.tags != null && contact.tags!['name'] != null) {
      _name = contact.tags!['name'].toString();
    }

    return _name;
  }

  Future<bool> isFilePresent(String filePath) async {
    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  showResetAtSignDialog() async {
    bool isSelectAtSign = false;
    bool? isSelectAll = false;
    var atSignsList = await KeychainUtil.getAtsignList();
    atSignsList ??= [];
    Map atSignMap = {};
    for (String atSign in atSignsList) {
      atSignMap[atSign] = false;
    }
    GlobalKey _one = GlobalKey();
    await showDialog(
        barrierDismissible: true,
        context: NavService.navKey.currentContext!,
        builder: (BuildContext context) {
          return ShowCaseWidget(builder: Builder(builder: (context) {
            return StatefulBuilder(builder: (context, stateSet) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Delete Your Keys',
                              style: CustomTextStyles.primaryBold18,
                            ),
                            SizedBox(height: 15.toHeight),
                            Row(
                              children: [
                                Expanded(
                                  child: Showcase(
                                    key: _one,
                                    description:
                                        'You can have more than one atSign associated with this app and can remove one or all of the atSigns from the app at any time.',
                                    targetShapeBorder: const CircleBorder(),
                                    disableMovingAnimation: true,
                                    disableScaleAnimation: true,
                                    targetBorderRadius: const BorderRadius.all(
                                        Radius.circular(40)),
                                    showArrow: false,
                                    targetPadding: const EdgeInsets.all(5),
                                    blurValue: 2,
                                    child: Text(
                                      'This action will remove the selected atSign and its details from this app.',
                                      style: TextStyle(
                                        fontSize: 15.toFont,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Warning: ',
                                style: TextStyle(
                                  fontSize: 15.toFont,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "This action cannot be undone!",
                                    style: TextStyle(
                                      fontSize: 15.toFont,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15.toHeight,
                            ),
                            atSignsList!.isEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Text(
                                            'There are no atSigns paired with this device.',
                                            style: TextStyle(
                                              fontSize: 15.toFont,
                                              fontWeight: FontWeight.normal,
                                            )),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Close',
                                              style: TextStyle(
                                                fontSize: 15.toFont,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        )
                                      ])
                                : Container(
                                    decoration: BoxDecoration(
                                      color: ColorConstants.bottomBlack,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CheckboxListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                          side: MaterialStateBorderSide
                                              .resolveWith(
                                            (states) => const BorderSide(
                                                width: 2,
                                                color: ColorConstants.orange),
                                          ),
                                          onChanged: (value) {
                                            isSelectAll = value;
                                            atSignMap.updateAll((key, value1) =>
                                                value1 = value);
                                            stateSet(() {});
                                          },
                                          value: isSelectAll,
                                          activeColor: const Color(0x00473d24),
                                          checkColor: ColorConstants.orange,
                                          title: Text('Select All',
                                              style: TextStyle(
                                                fontSize: 16.toFont,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.toWidth),
                                          child: const Divider(
                                            thickness: 0.8,
                                            color: Colors.white,
                                          ),
                                        ),
                                        for (var atsign in atSignsList)
                                          CheckboxListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                            side: MaterialStateBorderSide
                                                .resolveWith(
                                              (states) => const BorderSide(
                                                  width: 2,
                                                  color: ColorConstants.orange),
                                            ),
                                            onChanged: (value) {
                                              atSignMap[atsign] = value;
                                              stateSet(() {});
                                            },
                                            value: atSignMap[atsign],
                                            activeColor:
                                                const Color(0x00473d24),
                                            checkColor: ColorConstants.orange,
                                            title: Text(
                                              atsign,
                                              style: TextStyle(
                                                fontSize: 16.toFont,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        const Divider(thickness: 0.8),
                                      ],
                                    ),
                                  ),
                            if (isSelectAtSign)
                              Text('Please select at least one atSign to reset',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14.toFont,
                                    fontWeight: FontWeight.normal,
                                  )),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Row(children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      side:
                                          MaterialStateProperty.all<BorderSide>(
                                        const BorderSide(color: Colors.black),
                                      ),
                                      textStyle:
                                          MaterialStateProperty.all<TextStyle>(
                                              TextStyle(
                                        fontSize: 16.toFont,
                                      )),
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(
                                              horizontal: 15.toWidth,
                                              vertical: 10.toHeight)),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ))),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    textStyle:
                                        MaterialStateProperty.all<TextStyle>(
                                            const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    )),
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        EdgeInsets.symmetric(
                                            horizontal: 15.toWidth,
                                            vertical: 10.toHeight)),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side:
                                          const BorderSide(color: Colors.black),
                                    ))),
                                onPressed: () async {
                                  var tempAtsignMap = {};
                                  tempAtsignMap.addAll(atSignMap);
                                  tempAtsignMap.removeWhere(
                                      (key, value) => value == false);
                                  int atsignsListLength =
                                      tempAtsignMap.keys.toList().length;
                                  if (tempAtsignMap.keys.toList().isEmpty) {
                                    isSelectAtSign = true;
                                    stateSet(() {});
                                  } else {
                                    await showConfirmationDialog(() async {
                                      isSelectAtsign = false;
                                      await _resetDevice(
                                          tempAtsignMap.keys.toList());
                                      await _onboardNextAtSign();
                                    }, 'Remove $atsignsListLength atSign${atsignsListLength > 1 ? 's' : ''} from this device?');
                                  }
                                },
                                child: Text('Remove',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.toFont,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ])
                          ],
                        ),
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

  _onboardNextAtSign() async {
    var _backendService = BackendService.getInstance();
    var atSignList = await KeychainUtil.getAtsignList();
    if (atSignList != null &&
        atSignList.isNotEmpty &&
        _backendService.currentAtSign != atSignList.first) {
      // _backendService.checkToOnboard(atSign: atSignList.first);
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.HOME, (Route<dynamic> route) => false);
    } else if (atSignList == null || atSignList.isEmpty) {
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext!,
            DesktopRoutes.DESKTOP_HOME,
            (Route<dynamic> route) => false);
      } else if (Platform.isAndroid || Platform.isIOS) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext!,
            Routes.HOME,
            (Route<dynamic> route) => false);
      }
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
      maxWidth: 50,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
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

  Future<void> showConfirmationDialog(Function onSuccess, String title) async {
    await showDialog(
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

  String formatDateTime(DateTime datetime) {
    return "${datetime.day}/${datetime.month}/${datetime.year} | ${datetime.hour}:${datetime.minute}";
  }

  Widget getDownloadStatus(FileTransferProgress? fileTransferProgress) {
    Widget spinner = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        ColorConstants.orange,
      ),
    );

    if (fileTransferProgress == null) {
      return spinner;
    }

    if (fileTransferProgress.fileState == FileState.download &&
        fileTransferProgress.percent != null) {
      spinner = LabelledCircularProgressIndicator(
          value: (fileTransferProgress.percent! / 100));
    }

    return spinner;
  }

  bool checkForDownloadAvailability(FileTransfer file) {
    bool isDownloadAvailable = false;

    var expiryDate = file.date!.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    // if fileList is not having any file then download icon will not be shown
    var isFileUploaded = false;
    file.files!.forEach((FileData fileData) {
      if (fileData.isUploaded!) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      isDownloadAvailable = false;
    }

    return isDownloadAvailable;
  }

  Future<String> getNickname(String atSign) async {
    var res = await ContactService().getContactDetails(atSign, null);
    return res['nickname'] ?? "";
  }

  Widget interactThumbnail(String extension, String path,
      FilesDetail fileDetail, Function onDelete) {
    GroupService().allContacts;
    String nickname = "";
    final date = DateTime.parse(fileDetail.date ?? "").toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    for (var contact in GroupService().allContacts) {
      if (contact?.contact?.atSign == fileDetail.contactName) {
        nickname = contact?.contact?.tags?["nickname"] ?? "";
        break;
      }
    }
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: GestureDetector(
              onTap: () async {
                File test = File(path);
                bool fileExists = await test.exists();
                if (fileExists) {
                  await showDialog(
                    context: NavService.navKey.currentContext!,
                    builder: (_) => Material(
                      type: MaterialType.transparency,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(
                                      NavService.navKey.currentContext!);
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await openFilePath(path);
                              },
                              child: Container(
                                // height: double.infinity,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 33),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(path),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 6.0),
                              //   child: SvgPicture.asset(
                              //     AppVectors.icDownloadFile,
                              //     height: 50,
                              //     width: 50,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(
                                        NavService.navKey.currentContext!);
                                    Navigator.pop(
                                        NavService.navKey.currentContext!);
                                    await FileUtils.moveToSendFile(path);
                                  },
                                  child: SvgPicture.asset(
                                    AppVectors.icSendFile,
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: GestureDetector(
                                  onTap: () {
                                    onDelete.call();
                                  },
                                  child: SvgPicture.asset(
                                    AppVectors.icDeleteFile,
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.symmetric(horizontal: 25),
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fileDetail.fileName ?? "",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "$shortDate",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ColorConstants.oldSliver,
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 8,
                                            color: Color(0xFFD7D7D7),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                          ),
                                          Text(
                                            "$time",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ColorConstants.oldSliver,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    double.parse(fileDetail.size.toString()) <=
                                            1024
                                        ? '${fileDetail.size} ' +
                                            TextStrings().kb
                                        : '${(fileDetail.size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                                            TextStrings().mb,
                                    style: TextStyle(
                                      color: ColorConstants.grey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 10),
                                  nickname.isNotEmpty
                                      ? Text(
                                          nickname,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 5),
                                  Text(
                                    fileDetail.contactName ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // fileDetail.message.isNotNull
                                  //     ?
                                  if ((fileDetail.message ?? '').isNotEmpty)
                                    Text(
                                      "Message",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  // : SizedBox(),
                                  SizedBox(height: 5),
                                  Text(
                                    fileDetail.message ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  CommonUtilityFunctions().showNoFileDialog();
                }
              },
              child: Container(
                height: 50.toHeight,
                width: 50.toWidth,
                child: Image.file(
                  File(path),
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
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(10.toHeight),
                  child: GestureDetector(
                    onTap: () async {
                      //   await openDownloadsFolder(context);
                      await openFilePath(path);
                    },
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
                ),
              )
            : Builder(
                builder: (context) => ClipRRect(
                  borderRadius: BorderRadius.circular(10.toHeight),
                  child: GestureDetector(
                    onTap: () async {
                      await openFilePath(path);
                      //   await openDownloadsFolder(context);
                    },
                    child: Container(
                      // padding: EdgeInsets.only(left: 10),
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
                                        : FileTypes.TEXT_TYPES
                                                .contains(extension)
                                            ? ImageConstants.txtLogo
                                            : ImageConstants.unknownLogo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
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
