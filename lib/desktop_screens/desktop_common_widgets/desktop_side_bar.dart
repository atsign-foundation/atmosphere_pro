import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_list_item.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DesktopSideBarWidget extends StatefulWidget {
  DesktopSideBarWidget();

  @override
  _DesktopSideBarWidgetState createState() => _DesktopSideBarWidgetState();
}

class _DesktopSideBarWidgetState extends State<DesktopSideBarWidget> {
  final List<String> menuItemsTitle = [
    TextStrings().sidebarContact,
    TextStrings().sidebarTransferHistory,
    TextStrings().sidebarBlockedUser,
    TextStrings().myFiles,
    TextStrings().groups,
    TextStrings().sidebarTrustedSenders,
    TextStrings().sidebarTermsAndConditions,
    // TextStrings().sidebarPrivacyPolicy,
    TextStrings().sidebarFaqs,
  ];

  final List<String> menuItemsIcons = [
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.myFiles,
    ImageConstants.groups,
    ImageConstants.trustedSender,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
    ImageConstants.trustedSendersIcon,
  ];

  final List<String> targetScreens = [
    DesktopRoutes.DEKSTOP_CONTACTS_SCREEN,
    DesktopRoutes.DESKTOP_HISTORY,
    DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN,
    DesktopRoutes.DEKSTOP_MYFILES,
    DesktopRoutes.DESKTOP_GROUP,
    DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER,
    null,
    null,
    null,
  ];

  bool showCloseIcon = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 325,
          color: ColorConstants.inputFieldColor,
          child: Container(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[0],
                    title: menuItemsTitle[0],
                    routeName: targetScreens[0],
                    showIconOnly: false,
                    arguments: {
                      'isBlockedScreen': false,
                    },
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[1],
                    title: menuItemsTitle[1],
                    routeName: targetScreens[1],
                    showIconOnly: false,
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[2],
                    title: menuItemsTitle[2],
                    routeName: targetScreens[2],
                    showIconOnly: false,
                    isDesktop: true,
                    arguments: {
                      'isBlockedScreen': true,
                    },
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[3],
                    title: menuItemsTitle[3],
                    routeName: targetScreens[3],
                    showIconOnly: false,
                    arguments: {
                      "title": TextStrings().sidebarTermsAndConditions,
                      "url": MixedConstants.TERMS_CONDITIONS
                    },
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[4],
                    title: menuItemsTitle[4],
                    routeName: targetScreens[4],
                    showIconOnly: false,
                    arguments: {
                      "currentAtsign":
                          BackendService.getInstance().currentAtsign
                    },
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[5],
                    title: menuItemsTitle[5],
                    routeName: targetScreens[5],
                    showIconOnly: false,
                    arguments: {
                      'title': menuItemsTitle[5],
                      'url': MixedConstants.TERMS_CONDITIONS
                    },
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[6],
                    title: menuItemsTitle[6],
                    routeName: targetScreens[6],
                    showIconOnly: false,
                    arguments: {
                      'title': menuItemsTitle[6],
                      'url': MixedConstants.TERMS_CONDITIONS
                    },
                    isDesktop: true,
                  ),
                  SizedBox(height: 20.toHeight),
                  SideBarItem(
                    image: menuItemsIcons[7],
                    title: menuItemsTitle[7],
                    routeName: targetScreens[7],
                    showIconOnly: false,
                    isDesktop: true,
                    arguments: {
                      'title': menuItemsTitle[7],
                      'url': MixedConstants.PRIVACY_POLICY
                    },
                  ),
                  // SizedBox(height: 20.toHeight),
                  // Text(
                  //   TextStrings().sidebarEnablingMessage,
                  //   style: TextStyle(
                  //       color: ColorConstants.dullText,
                  //       fontSize: 18,
                  //       letterSpacing: 0.1),
                  // )
                ],
              ),
            ),
          ),
        ),
        showCloseIcon
            ? Positioned(
                top: 50,
                left: 305,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showCloseIcon = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.toWidth),
                        color: Colors.black),
                    child: Icon(Icons.arrow_back_ios,
                        size: 20, color: Colors.white),
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }
}
