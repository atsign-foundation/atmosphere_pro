import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar_list_item.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
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
  Uint8List image;
  AtContact contact;
  String name;

  @override
  void initState() {
    super.initState();
    // getEventCreator();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initializeContactsService(
          BackendService.getInstance().atClientInstance,
          BackendService.getInstance().currentAtSign);
    });
  }

  // getEventCreator() async {
  //   AtContact contact = await getAtSignDetails(BackendService.getInstance()
  //       .atClientServiceInstance
  //       .atClient
  //       .currentAtSign);
  //   if (contact != null) {
  //     if (contact.tags != null && contact.tags['image'] != null) {
  //       List<int> intList = contact.tags['image'].cast<int>();
  //       setState(() {
  //         image = Uint8List.fromList(intList);
  //       });
  //     }
  //     if (contact.tags != null && contact.tags['name'] != null) {
  //       String newName = contact.tags['name'].toString();
  //       setState(() {
  //         name = newName;
  //       });
  //     } else {
  //       setState(() {
  //         name = contact.atSign.substring(1);
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig().screenWidth * 0.65,
      child: Drawer(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.toWidth),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 30.toHeight,
                  bottom: 10.toHeight,
                  left: 10.toWidth,
                ),
                child: Row(
                  children: [
                    (image != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: Image.memory(
                              image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill,
                            ),
                          )
                        : ContactInitial(
                            initials: BackendService.getInstance()
                                .currentAtSign
                                .substring(1, 3)),
                    Flexible(
                        child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? 'Full Name',
                            // style: CustomTextStyles().darkGrey16,
                            maxLines: 1,
                            // style: TextStyle(letterSpacing: 0.1),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            BackendService.getInstance().currentAtSign ??
                                '@sign',
                            // style: CustomTextStyles().darkGrey14,
                            maxLines: 1, style: TextStyle(letterSpacing: 0.1),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SideBarItem(
                image: menuItemsIcons[0],
                title: menuItemsTitle[0],
                routeName: targetScreens[0],
                arguments: {
                  'singleSelection': false,
                  'showGroups': true,
                  'showContacts': true,
                  'selectedList': (s) {}
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
              InkWell(
                  onTap: () async {
                    _deleteAtSign(
                        await BackendService.getInstance().currentAtsign);
                    setState(() {});
                  },
                  child: Container(
                    height: 50,
                    child: Row(children: [
                      Icon(Icons.delete,
                          color: ColorConstants.fadedText, size: 20.toFont),
                      SizedBox(width: 10),
                      Text(
                        TextStrings().sidebarDeleteAtsign,
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                    ]),
                  )),
              InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    String atSign =
                        await BackendService.getInstance().getAtSign();

                    var atSignList = await BackendService.getInstance()
                        .atClientServiceMap[atSign]
                        .getAtsignList();
                    await showModalBottomSheet(
                      context: NavService.navKey.currentContext,
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
                        height: 20.toHeight,
                        color: ColorConstants.fadedText,
                      ),
                      SizedBox(width: 10),
                      Text(
                        TextStrings().sidebarSwitchOut,
                        style: TextStyle(
                            color: ColorConstants.fadedText,
                            fontSize: 14.toFont,
                            letterSpacing: 0.1),
                      ),
                    ]),
                  )),

              ListTile(
                leading: Text(
                  TextStrings().sidebarAutoAcceptFile,
                  style: TextStyle(
                      color: ColorConstants.fadedText,
                      fontSize: 14.toFont,
                      letterSpacing: 0.1),
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
                      letterSpacing: 0.1),
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
                style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to delete all data associated with',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(letterSpacing: 0.1, color: Colors.grey[700])),
                SizedBox(height: 20),
                Text('$atsign',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Type the @sign above to proceed',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey[700], letterSpacing: 0.1)),
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
                    style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold)),
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
