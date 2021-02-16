import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_list_item.dart';
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
  String activeAtSign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig().screenWidth * 0.65,
      child: Drawer(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.toWidth),
          child: ListView(
            children: [
              SizedBox(
                height: 120.toHeight,
              ),
              SideBarItem(
                image: menuItemsIcons[0],
                title: menuItemsTitle[0],
                routeName: targetScreens[0],
                arguments: {
                  'currentAtsign': BackendService.getInstance().currentAtsign,
                  'context': NavService.navKey.currentContext,
                  'selectedList': (s) {
                    Provider.of<WelcomeScreenProvider>(
                            NavService.navKey.currentContext,
                            listen: false)
                        .updateSelectedContacts(s);
                  }
                },
              ),
              SideBarItem(
                image: menuItemsIcons[1],
                title: menuItemsTitle[1],
                routeName: targetScreens[1],
              ),
              SideBarItem(
                image: menuItemsIcons[2],
                title: menuItemsTitle[2],
                routeName: targetScreens[2],
              ),
              SideBarItem(
                image: menuItemsIcons[3],
                title: menuItemsTitle[3],
                routeName: targetScreens[3],
                arguments: {
                  "title": TextStrings().sidebarTermsAndConditions,
                  "url": MixedConstants.TERMS_CONDITIONS
                },
              ),
              SideBarItem(
                image: menuItemsIcons[4],
                title: menuItemsTitle[4],
                routeName: targetScreens[4],
                arguments: {
                  "currentAtsign": BackendService.getInstance().currentAtsign
                },
              ),
              SideBarItem(
                image: menuItemsIcons[5],
                title: menuItemsTitle[5],
                routeName: targetScreens[5],
                arguments: {
                  'title': menuItemsTitle[5],
                  'url': MixedConstants.TERMS_CONDITIONS
                },
              ),
              SideBarItem(
                  image: menuItemsIcons[6],
                  title: menuItemsTitle[6],
                  routeName: targetScreens[6],
                  arguments: {
                    'title': menuItemsTitle[6],
                    'url': MixedConstants.PRIVACY_POLICY
                  }),
              SideBarItem(
                image: menuItemsIcons[7],
                title: menuItemsTitle[7],
                routeName: targetScreens[7],
              ),
              SideBarItem(
                image: menuItemsIcons[8],
                title: menuItemsTitle[8],
                routeName: targetScreens[8],
              ),
              ListTile(
                onTap: () async {
                  _deleteAtSign(
                      await BackendService.getInstance().currentAtsign);
                  setState(() {});
                },
                leading: Icon(Icons.delete, color: ColorConstants.fadedText),
                title: Text(
                  TextStrings().sidebarDeleteAtsign,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 14.toFont,
                  ),
                ),
              ),
              SizedBox(
                height: 40.toHeight,
              ),
              ListTile(
                leading: Text(
                  TextStrings().sidebarAutoAcceptFile,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 14.toFont,
                  ),
                ),
                title: Transform.scale(
                  scale: 0.6,
                  child: CupertinoSwitch(
                    value: BackendService.getInstance().autoAcceptFiles,
                    onChanged: (b) {
                      setState(() {
                        BackendService.getInstance().autoAcceptFiles = b;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                ),
              ),
              // SizedBox(
              //   height: 14.toHeight,
              // ),
              Padding(
                padding: EdgeInsets.only(left: 16.toWidth),
                child: Text(
                  TextStrings().sidebarEnablingMessage,
                  style: TextStyle(
                    color: ColorConstants.dullText,
                    fontSize: 12.toFont,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.HOME, (route) => false);
                },
                leading: Image.asset(
                  ImageConstants.logoutIcon,
                  height: 20.toHeight,
                  color: ColorConstants.fadedText,
                ),
                title: Text(
                  TextStrings().sidebarSwitchOut,
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
