import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_app/screens/widgets/common_button.dart';
import 'package:atsign_atmosphere_app/screens/widgets/side_bar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/select_contact_widget.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isContactSelected;
  bool isFileSelected;

  @override
  void initState() {
    isContactSelected = false;
    isFileSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showLeadingicon: true,
        ),
        endDrawer: SideBarWidget(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 26.toWidth, vertical: 20.toHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TextStrings().welcomeUser('John'),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 28.toFont,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                Text(
                  TextStrings().welcomeRecipient,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 13.toFont,
                  ),
                ),
                SizedBox(
                  height: 67.toHeight,
                ),
                Text(
                  TextStrings().welcomeSendFilesTo,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 12.toFont,
                  ),
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                SelectContactWidget(
                  (b) {
                    setState(() {
                      isContactSelected = b;
                    });
                  },
                ),
                SizedBox(
                  height: 40.toHeight,
                ),
                SelectFileWidget(
                  (b) {
                    setState(() {
                      isFileSelected = b;
                    });
                  },
                ),
                SizedBox(
                  height: 60.toHeight,
                ),
                if (isContactSelected && isFileSelected) ...[
                  Align(
                    alignment: Alignment.topRight,
                    child: CommonButton(
                      TextStrings().buttonSend,
                      () {},
                    ),
                  ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
