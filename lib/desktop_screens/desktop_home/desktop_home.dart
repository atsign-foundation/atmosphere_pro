import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key key}) : super(key: key);

  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  BackendService backendService = BackendService.getInstance();
  var atClientPrefernce;
  bool authenticating = false;

  @override
  void initState() {
    _checkToOnboardinHome();
    super.initState();
  }

  void _checkToOnboardinHome() async {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    String currentatSign = await backendService.getAtSign();
    print('currentatSign $currentatSign');
    await backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) => print(e));

    await CustomOnboarding.onboard(
        atSign: currentatSign,
        atClientPrefernce: atClientPrefernce,
        showLoader: showLoaderInHome);
  }

  void showLoaderInHome(bool loaderState) {
    setState(() {
      authenticating = loaderState;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Row(
        children: [
          Container(
              width:
                  (SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH) / 2,
              padding: EdgeInsets.all(36),

              /// If we remove this Scaffold then it doesnt login
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      ImageConstants.logoIcon,
                      height: 80.toHeight,
                      width: 80.toHeight,
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Text(
                      'File transfer.',
                      style: CustomTextStyles.desktopBlackPlayfairDisplay26,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "It's safe!",
                      style: CustomTextStyles.desktopBlackPlayfairDisplay26,
                    ),
                    Spacer(),
                    Text(
                      '@sign',
                      style: CustomTextStyles.secondaryRegular16,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () {},
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: ColorConstants.textBoxBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: ListTile(
                              title: Text('Enter @sign',
                                  style: CustomTextStyles
                                      .desktopSecondaryRegular18),
                            ))),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CommonButton(
                        'Send',
                        () {},
                        color: ColorConstants.orangeColor,
                        border: 7,
                        height: 50,
                        width: double.infinity,
                        fontSize: 20,
                        removePadding: true,
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Don't have an @sign? Get now.",
                        style: CustomTextStyles.orangeMedium16,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '@mosphere',
                      style: CustomTextStyles.blackBold(size: 14),
                    ),
                    Text(
                      'The @company Copyrights',
                      style: CustomTextStyles.secondaryRegular14,
                    ),
                  ],
                ),
              )),
          Expanded(
              child: Container(
            width:
                (SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH) / 2,
            height: SizeConfig().screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.homeBgDesktop,
                ),
                fit: BoxFit.fill,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
