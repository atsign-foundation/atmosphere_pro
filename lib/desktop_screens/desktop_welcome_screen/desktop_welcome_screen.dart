import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_contacts_group_flutter/widgets/custom_input_field.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_contact_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopWelcomeScreen extends StatefulWidget {
  @override
  _DesktopWelcomeScreenState createState() => _DesktopWelcomeScreenState();
}

class _DesktopWelcomeScreenState extends State<DesktopWelcomeScreen> {
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
    ImageConstants.trustedSender,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
    ImageConstants.trustedSendersIcon,
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 0.1,
              ),
            ),
          ),
          child: AppBar(
            leading: Image.asset(
              ImageConstants.logoIcon,
              height: 50.toHeight,
              width: 50.toHeight,
            ),
            actions: [
              Icon(Icons.notification_important),
              SizedBox(width: 15),
              ContactInitial(
                initials: 'Levina',
                size: 30,
              )
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          Container(
            width: 70,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.black,
                  width: 0.1,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: true ? 100.toHeight : 0),
                InkWell(
                  child: Image.asset(
                    menuItemsIcons[0],
                    height: 22.toHeight,
                    color: ColorConstants.fadedText,
                  ),
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[1],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[2],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[3],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[4],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[5],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[6],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 20.toHeight : 0),
                Image.asset(
                  menuItemsIcons[7],
                  height: 22.toHeight,
                  color: ColorConstants.fadedText,
                ),
                SizedBox(height: true ? 100.toHeight : 0),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: (SizeConfig().screenWidth - 70) / 2,
                  height: SizeConfig().screenHeight - 80,
                  padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100.toHeight,
                      ),
                      Text(
                        'Welcome @John!',
                        style: CustomTextStyles.blackPlayfairDisplay26,
                      ),
                      SizedBox(
                        height: 20.toHeight,
                      ),
                      Text(
                        'Type a receipient and start sending them files.',
                        style: CustomTextStyles.secondaryRegular12,
                      ),
                      SizedBox(
                        height: 50.toHeight,
                      ),
                      Text(
                        TextStrings().welcomeSendFilesTo,
                        style: CustomTextStyles.secondaryRegular12,
                      ),
                      SizedBox(
                        height: 20.toHeight,
                      ),
                      sendFileTo(isSelectContacts: true),
                      SizedBox(
                        height: 30,
                      ),
                      Text(TextStrings().welcomeFilePlaceholder,
                          style: CustomTextStyles.secondaryRegular12),
                      SizedBox(
                        height: 20.toHeight,
                      ),
                      sendFileTo()
                    ],
                  ),
                ),
                Container(
                  width: (SizeConfig().screenWidth - 70) / 2,
                  height: SizeConfig().screenHeight - 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        ImageConstants.welcomeDesktop,
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sendFileTo({bool isSelectContacts = false}) {
    return Container(
        decoration: BoxDecoration(
          color: ColorConstants.inputFieldColor,
        ),
        child: ListTile(
          trailing: isSelectContacts
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Image.asset(
                    ImageConstants.contactsIcon,
                    color: Colors.black,
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.black,
                  ),
                ),
        ));
  }
}
