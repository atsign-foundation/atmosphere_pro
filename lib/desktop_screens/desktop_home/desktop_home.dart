import 'dart:io';

import 'package:atsign_atmosphere_pro/desktop_screens/desktop_home/widgets/home_description_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_home/widgets/logo_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key? key}) : super(key: key);

  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  BackendService backendService = BackendService.getInstance();
  late var atClientPrefernce;
  bool authenticating = false, onboardError = false;
  String? currentatSign;

  @override
  void initState() {
    storeApplicationDocumentsDirectory();
    super.initState();
  }

  /// before login we keep atmospher-pro as the directory
  storeApplicationDocumentsDirectory() async {
    var _dir = await getApplicationDocumentsDirectory();
    final path =
        Directory(_dir.path + Platform.pathSeparator + '@mosphere-pro');

    if (!(await path.exists())) {
      await path.create();
    }

    MixedConstants.ApplicationDocumentsDirectory = path.path;
    _checkToOnboard();
  }

  void _checkToOnboard() async {
    currentatSign = await backendService.getAtSign();

    if (currentatSign == '') {
      currentatSign = null;
    }

    if (mounted) {
      setState(() {});
    }
    print('currentatSign $currentatSign, ${(currentatSign != null)}');
    await backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) {
      print(e);
    });

    if (currentatSign != null) {
      await _onBoard(currentatSign);
    }
  }

  Future<void> _onBoard(String? _atsign) async {
    await CustomOnboarding.onboard(
        atSign: _atsign,
        atClientPrefernce: atClientPrefernce,
        isInit: true,
        onError: onOnboardError);
  }

  onOnboardError() {
    if (mounted) {
      setState(() {
        onboardError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 60.toHeight,
              left: 68.toWidth,
            ),
            child: LogoWidget(),
          ),
          SizedBox(
            height: 96.toHeight,
          ),
          Center(
            child: HomeDescriptionWidget(),
          ),
          SizedBox(height: 28.toHeight),
          Center(
            child: CommonButton(
              authenticating
                  ? '${TextStrings().initialisingFor} $currentatSign...'
                  : (currentatSign != null && !onboardError
                      ? TextStrings().authenticating
                      : 'Upload atSign'),
              (currentatSign != null && !onboardError)
                  ? null
                  : () {
                      _onBoard('');
                    },
              color: (currentatSign != null && !onboardError)
                  ? ColorConstants.dullText
                  : ColorConstants.raisinBlack,
              border: 252,
              height: 68.toHeight,
              width: 349.toWidth,
              fontSize: authenticating ? 17 : 20,
              removePadding: true,
            ),
          ),
          SizedBox(height: 18.toHeight),
          Center(
            child: InkWell(
              onTap: () async {
                await CommonUtilityFunctions().showResetAtsignDialog();
              },
              child: Container(
                width: 200,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Reset",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.toFont, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 48.toHeight),
          Flexible(
            child: Image.asset(
              ImageConstants.desktopSplash,
              width: SizeConfig().screenWidth,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }
}
