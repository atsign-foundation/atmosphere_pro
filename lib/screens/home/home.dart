import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: SizeConfig().screenWidth,
        height: SizeConfig().screenHeight,
        decoration: BoxDecoration(
          color: Colors.red,
          image: DecorationImage(
            image: AssetImage(
              ImageConstants.welcomeBackground,
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10.toWidth,
                      top: 10.toHeight,
                    ),
                    child: Image.asset(
                      ImageConstants.logoIcon,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 36.toWidth,
                    vertical: 10.toHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          TextStrings().homeFileTransferItsSafe,
                          style: GoogleFonts.playfairDisplay(
                            textStyle: TextStyle(
                              fontSize: 38.toFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text.rich(
                          TextSpan(
                            text: TextStrings().homeHassleFree,
                            style: TextStyle(
                              fontSize: 15.toFont,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: TextStrings().homeWeWillSetupAccount,
                                style: TextStyle(
                                  color: ColorConstants.fadedText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CommonButton(
                            TextStrings().buttonStart,
                            () {
                              // Navigator.pushNamed(context, Routes.FILE_PICKER);
                              Navigator.pushNamedAndRemoveUntil(context,
                                  Routes.WELCOME_SCREEN, (route) => false);
                            },
                          ),
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
