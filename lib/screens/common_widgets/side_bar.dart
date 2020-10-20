import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideBarWidget extends StatefulWidget {
  @override
  _SideBarWidgetState createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  final List<String> menuItemsTitle = [
    TextStrings().sidebarContact,
    TextStrings().sidebarTransferHistory,
    TextStrings().sidebarBlockedUser,
    TextStrings().sidebarTermsAndConditions,
    TextStrings().sidebarFaqs,
  ];

  final List<String> menuItemsIcons = [
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
  ];

  final List<String> targetScreens = [
    Routes.CONTACT_SCREEN,
    Routes.HISTORY,
    Routes.BLOCKED_USERS,
    Routes.TERMS_CONDITIONS,
    Routes.FAQ_SCREEN,
  ];

  bool autoAcceptFiles;

  @override
  void initState() {
    autoAcceptFiles = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig().screenWidth * 0.65,
      child: Drawer(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.toWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.toHeight,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: menuItemsTitle.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(targetScreens[index],
                        arguments: (index == 2)
                            ? {
                                'blockedUserList': ['hello']
                              }
                            : null);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 13.toHeight),
                    child: Row(
                      children: [
                        Image.asset(
                          menuItemsIcons[index],
                          height: 20.toHeight,
                          color: ColorConstants.fadedText,
                        ),
                        SizedBox(
                          width: 15.toWidth,
                        ),
                        Text(
                          menuItemsTitle[index],
                          style: TextStyle(
                            color: ColorConstants.fadedText,
                            fontSize: 14.toFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40.toHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TextStrings().sidebarAutoAcceptFile,
                    style: TextStyle(
                      color: ColorConstants.fadedText,
                      fontSize: 14.toFont,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: CupertinoSwitch(
                      value: autoAcceptFiles,
                      onChanged: (b) {
                        setState(() {
                          autoAcceptFiles = b;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 14.toHeight,
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.toWidth),
                child: Text(
                  TextStrings().sidebarEnablingMessage,
                  style: TextStyle(
                    color: ColorConstants.dullText,
                    fontSize: 12.toFont,
                  ),
                ),
              ),
              SizedBox(
                height: 210.toHeight,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.HOME, (route) => false);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 13.toHeight),
                  child: Row(
                    children: [
                      Image.asset(
                        ImageConstants.logoutIcon,
                        height: 20.toHeight,
                        color: ColorConstants.fadedText,
                      ),
                      SizedBox(
                        width: 15.toWidth,
                      ),
                      Text(
                        TextStrings().sidebarSwitchOut,
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
