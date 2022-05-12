import 'dart:io';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_backup_item.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_list_item.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SideBarWidget extends StatefulWidget {
  final bool isExpanded;
  SideBarWidget({this.isExpanded = false});

  @override
  _SideBarWidgetState createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  final List<String> menuItemsTitle = [
    TextStrings().sidebarContact,
    TextStrings().sidebarTransferHistory,
    TextStrings().sidebarBlockedUser,
    TextStrings().myFiles,
    TextStrings().groups,
    TextStrings().sidebarTermsAndConditions,
    TextStrings().sidebarPrivacyPolicy,
    TextStrings().sidebarFaqs,
    TextStrings().sidebarTrustedSenders
  ];

  final List<String> menuItemsIcons = [
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.myFiles,
    ImageConstants.groups,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
    ImageConstants.trustedSendersIcon,
    ImageConstants.trustedSender,
  ];

  final List<String> targetScreens = [
    Routes.CONTACT_SCREEN,
    Routes.HISTORY,
    Routes.BLOCKED_USERS,
    Routes.MY_FILES,
    Routes.GROUPS,
    Routes.WEBSITE_SCREEN,
    Routes.WEBSITE_SCREEN,
    Routes.FAQ_SCREEN,
    Routes.TRUSTED_CONTACTS
  ];
  String? activeAtSign;
  Uint8List? image;
  AtContact? contact;
  String? name;
  WelcomeScreenProvider _welcomeScreenProvider = WelcomeScreenProvider();
  bool isTablet = false, isExpanded = true, isLoading = false;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    isExpanded = widget.isExpanded;
    getAtsignDetails();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _welcomeScreenProvider.isExpanded = false;
  }

  getAtsignDetails() async {
    AtContact? contact;
    if (BackendService.getInstance().currentAtSign != null) {
      contact =
          await getAtSignDetails(BackendService.getInstance().currentAtSign!);
    }

    if (contact != null) {
      if (mounted) {
        setState(() {
          image = CommonUtilityFunctions().getContactImage(contact!);
        });
      }

      if (contact.tags != null && contact.tags!['name'] != null) {
        String newName = contact.tags!['name'].toString();
        if (mounted) {
          setState(() {
            name = newName;
          });
        }
      }
    }

    if (mounted) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    isTablet = SizeConfig().isTablet(context);
    return Stack(
      children: [
        Container(
          width: SizeConfig().isTablet(context)
              ? 405
              : SizeConfig().screenWidth * 0.65,
          color: ColorConstants.inputFieldColor,
          child: Container(
            child: Container(
              padding: isExpanded
                  ? EdgeInsets.symmetric(horizontal: 30.toWidth)
                  : EdgeInsets.only(left: 30),
              child: ListView(
                children: [
                  isExpanded
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: 30.toHeight,
                            bottom: 10.toHeight,
                            left: 10.toWidth,
                          ),
                          child: Row(
                            children: [
                              (image != null)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.toFont)),
                                      child: Image.memory(
                                        image!,
                                        width: 50.toFont,
                                        height: 50.toFont,
                                        fit: BoxFit.fill,
                                        errorBuilder:
                                            (BuildContext _context, _, __) {
                                          return Container(
                                            child: Icon(
                                              Icons.image,
                                              size: 30.toFont,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : BackendService.getInstance()
                                              .currentAtSign !=
                                          null
                                      ? ContactInitial(
                                          initials:
                                              BackendService?.getInstance()
                                                  .currentAtSign)
                                      : SizedBox(),
                              Flexible(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    name != null
                                        ? Text(name ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.toFont,
                                              fontWeight: FontWeight.normal,
                                            ))
                                        : SizedBox(),
                                    Text(
                                      BackendService.getInstance()
                                              .currentAtSign ??
                                          TextStrings().atSign,
                                      maxLines: 1,
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize: 15.toFont,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        )
                      : SizedBox(height: 50.toHeight),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    image: menuItemsIcons[0],
                    title: menuItemsTitle[0],
                    routeName: targetScreens[0],
                    showIconOnly: !isExpanded,
                    arguments: {
                      'asSelectionScreen': true,
                      'singleSelection': false,
                      'showGroups': true,
                      'showContacts': true,
                      'selectedList': (s) async {
                        await Provider.of<WelcomeScreenProvider>(
                                NavService.navKey.currentContext!,
                                listen: false)
                            .updateSelectedContacts(s);
                      },
                      'showSelectedData': Provider.of<WelcomeScreenProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .selectedContacts
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  Consumer<FileDownloadChecker>(
                    builder: (context, _fileDownloadChecker, _) {
                      return SideBarItem(
                        image: menuItemsIcons[1],
                        title: menuItemsTitle[1],
                        routeName: targetScreens[1],
                        showIconOnly: !isExpanded,
                        displayColor:
                            _fileDownloadChecker.undownloadedFilesExist
                                ? ColorConstants.orangeColor
                                : ColorConstants.fadedText,
                        showNotificationDot:
                            _fileDownloadChecker.undownloadedFilesExist
                                ? true
                                : false,
                      );
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    image: menuItemsIcons[2],
                    title: menuItemsTitle[2],
                    routeName: targetScreens[2],
                    showIconOnly: !isExpanded,
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    isScale: true,
                    image: menuItemsIcons[3],
                    title: menuItemsTitle[3],
                    routeName: targetScreens[3],
                    showIconOnly: !isExpanded,
                    arguments: {
                      "title": TextStrings().sidebarTermsAndConditions,
                      "url": MixedConstants.TERMS_CONDITIONS
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    isScale: true,
                    image: menuItemsIcons[4],
                    title: menuItemsTitle[4],
                    routeName: targetScreens[4],
                    showIconOnly: !isExpanded,
                    arguments: {
                      "currentAtsign":
                          BackendService.getInstance().currentAtsign
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    image: menuItemsIcons[5],
                    title: menuItemsTitle[5],
                    routeName: targetScreens[5],
                    showIconOnly: !isExpanded,
                    arguments: {
                      'title': menuItemsTitle[5],
                      'url': MixedConstants.TERMS_CONDITIONS
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarBackupItem(
                    title: isExpanded ? TextStrings().sidebarBackupKey : '',
                    leadingIcon: Icon(Icons.file_copy,
                        color: Color(0xFF757581),
                        size: (isTablet ? 26 : 21.toFont)),
                    onPressed: () {
                      BackupKeyWidget(
                        atsign: AtClientManager.getInstance()
                            .atClient
                            .getCurrentAtSign()!,
                      ).showBackupDialog(context);
                    },
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                      image: menuItemsIcons[6],
                      title: menuItemsTitle[6],
                      routeName: targetScreens[6],
                      showIconOnly: !isExpanded,
                      arguments: {
                        'title': menuItemsTitle[6],
                        'url': MixedConstants.PRIVACY_POLICY
                      }),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    image: menuItemsIcons[7],
                    title: menuItemsTitle[7],
                    routeName: targetScreens[7],
                    showIconOnly: !isExpanded,
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  SideBarItem(
                    isScale: true,
                    image: menuItemsIcons[8],
                    title: menuItemsTitle[8],
                    routeName: targetScreens[8],
                    showIconOnly: !isExpanded,
                  ),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  InkWell(
                      onTap: () async {
                        CommonUtilityFunctions().showResetAtsignDialog();
                      },
                      child: Container(
                        height: 50,
                        child: Row(children: [
                          Icon(Icons.delete,
                              color: ColorConstants.fadedText,
                              size: isTablet ? 20.toHeight : 25.toHeight),
                          SizedBox(width: 10),
                          isExpanded
                              ? Text(
                                  TextStrings().sidebarDeleteAtsign,
                                  style: TextStyle(
                                    color: ColorConstants.fadedText,
                                    fontSize: 14.toFont,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              : SizedBox(),
                        ]),
                      )),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  InkWell(
                      onTap: () async {
                        var atSignList = await KeychainUtil.getAtsignList();
                        await showModalBottomSheet(
                          context: NavService.navKey.currentContext!,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AtSignBottomSheet(
                            atSignList: atSignList,
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        child: Row(children: [
                          Image.asset(
                            ImageConstants.logoutIcon,
                            height: isTablet ? 20.toHeight : 22.toHeight,
                            color: ColorConstants.fadedText,
                          ),
                          SizedBox(width: 10),
                          isExpanded
                              ? Text(
                                  TextStrings().sidebarSwitchOut,
                                  style: TextStyle(
                                    color: ColorConstants.fadedText,
                                    fontSize: 14.toFont,
                                    letterSpacing: 0.1,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              : SizedBox(),
                        ]),
                      )),
                  SizedBox(height: isTablet ? 20.toHeight : 0),
                  isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              'App Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
                              style: CustomTextStyles.darkGrey13),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TextStrings().switchingAtSign,
                      style: CustomTextStyles.orangeMedium16,
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorConstants.redText)),
                  ],
                ),
              )
            : SizedBox(
                height: 100,
              ),
      ],
    );
  }
}
