import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/test_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TestModel model;
  bool onboardSuccess = false;

  @override
  void initState() {
    super.initState();
    model = TestModel();
    _checkToOnboard();
  }

  void _checkToOnboard() async {
    // onboard call to get the already setup atsigns
    BackendService backendService = BackendService.getInstance();
    await backendService.onboard().then((isChecked) async {
      if (!isChecked) {
        print("onboard returned: $isChecked");
      } else {
        await backendService.startMonitor();
        onboardSuccess = true;
      }
    }).catchError((error) async {
      print("Error in authenticating: $error");
    });
  }

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
                              if (onboardSuccess) {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    Routes.WELCOME_SCREEN, (route) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    Routes.SCAN_QR_SCREEN, (route) => false);
                              }
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
