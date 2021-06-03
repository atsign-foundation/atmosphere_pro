import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';

class DesktopWelcomeScreen extends StatefulWidget {
  @override
  _DesktopWelcomeScreenState createState() => _DesktopWelcomeScreenState();
}

class _DesktopWelcomeScreenState extends State<DesktopWelcomeScreen> {
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
                maxSize: (80.0 - 30.0),
                minSize: 50,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 100.toHeight),
                SideBarIcon(menuItemsIcons[0]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[1]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[2]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[3]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[4]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[5]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[6]),
                SizedBox(height: 40.toHeight),
                SideBarIcon(menuItemsIcons[7]),
                // SizedBox(height: 100.toHeight),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      sendFileTo(),
                      SizedBox(
                        height: 20.toHeight,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CommonButton(
                          'Send',
                          () {},
                          color: ColorConstants.orangeColor,
                          border: 3,
                          height: 45,
                          width: 110,
                          fontSize: 20,
                          removePadding: true,
                        ),
                      )
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

class SideBarIcon extends StatefulWidget {
  final String image;
  SideBarIcon(this.image);
  @override
  _SideBarIconState createState() => _SideBarIconState();
}

class _SideBarIconState extends State<SideBarIcon> {
  bool isHovered = false;

  hoverActivation(bool _newValue) {
    setState(() {
      isHovered = _newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: isHovered ? SystemMouseCursors.click : SystemMouseCursors.text,
      onEnter: (event) {
        hoverActivation(true);
      },
      onExit: (event) {
        hoverActivation(false);
      },
      child: Image.asset(
        widget.image,
        height: 22.toHeight,
        color: ColorConstants.fadedText,
      ),
    );
  }
}
