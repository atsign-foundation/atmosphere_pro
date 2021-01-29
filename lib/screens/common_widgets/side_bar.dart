import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    TextStrings().sidebarPrivacyPolicy,
    TextStrings().sidebarFaqs,
    TextStrings().sidebarTrustedSenders
  ];

  final List<String> menuItemsIcons = [
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
    ImageConstants.trustedSendersIcon,
  ];

  final List<String> targetScreens = [
    Routes.CONTACT_SCREEN,
    Routes.HISTORY,
    Routes.BLOCKED_USERS,
    Routes.WEBSITE_SCREEN,
    Routes.WEBSITE_SCREEN,
    Routes.FAQ_SCREEN,
    Routes.TRUSTED_CONTACTS
  ];

  bool autoAcceptFiles = true;
  @override
  void initState() {
    autoAcceptFiles = true;
    BackendService.getInstance().autoAcceptFiles = autoAcceptFiles;
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
                        arguments: (index == 0)
                            ? {
                                'currentAtsign':
                                    BackendService.getInstance().currentAtsign,
                                'context': NavService.navKey.currentContext,
                                'selectedList': (s) {
                                  Provider.of<WelcomeScreenProvider>(
                                          NavService.navKey.currentContext,
                                          listen: false)
                                      .updateSelectedContacts(s);
                                }
                              }
                            : (index == 3)
                                ? {
                                    "title":
                                        TextStrings().sidebarTermsAndConditions,
                                    "url": MixedConstants.TERMS_CONDITIONS
                                  }
                                : (index == 4)
                                    ? {
                                        "title":
                                            TextStrings().sidebarPrivacyPolicy,
                                        "url": MixedConstants.PRIVACY_POLICY
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
                        Expanded(
                          child: Text(
                            menuItemsTitle[index],
                            softWrap: true,
                            style: TextStyle(
                              color: ColorConstants.fadedText,
                              fontSize: 14.toFont,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _deleteAtSign(BackendService.getInstance().currentAtsign);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 13.toHeight),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: ColorConstants.fadedText),
                      SizedBox(
                        width: 15.toWidth,
                      ),
                      Text(
                        TextStrings().sidebarDeleteAtsign,
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40.toHeight,
              ),
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,

                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          print('AUTO IN SWITCH======>$autoAcceptFiles');
                          BackendService.getInstance().autoAcceptFiles =
                              autoAcceptFiles;
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
              Expanded(child: SizedBox()),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
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

  _deleteAtSign(String atsign) async {
    final _formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Delete @sign',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to delete all data associated with',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 20),
                Text('$atsign',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Type the @sign above to proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 5),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    autovalidate: true,
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
                Text("Caution: this action can't be undone",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                            await Navigator.pushNamedAndRemoveUntil(
                                context, Routes.HOME, (route) => false);
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
}
