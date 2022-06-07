import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  int _currentPageNumber = 0;

  var _constants = [
    [
      ImageConstants.homeCaraousel1,
      TextStrings().shareWithGroup,
      TextStrings().createGroupAndTransferFile,
      TextStrings().allMembers,
    ],
    [
      ImageConstants.homeCaraousel2,
      TextStrings().easyFileSharing,
      TextStrings().shareAnyFiles,
      TextStrings().fastAndSecure,
    ],
    [
      ImageConstants.homeCaraousel3,
      TextStrings().trustedContacts,
      TextStrings().customiseFiles,
      TextStrings().fromTrustedSenders
    ],
  ];

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
      body: Row(
        children: [
          Container(
              width: SizeConfig().screenWidth / 2,
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
                      TextStrings().homeDescriptionDesktop,
                      style: CustomTextStyles.desktopBlackPlayfairDisplay26,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text.rich(
                      TextSpan(
                        text: TextStrings().homeDescriptionSub,
                        style: TextStyle(
                          fontSize: 20.toFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CommonButton(
                        authenticating
                            ? '${TextStrings().initialisingFor} $currentatSign...'
                            : (currentatSign != null && !onboardError
                                ? TextStrings().authenticating
                                : TextStrings().buttonStart),
                        (currentatSign != null && !onboardError)
                            ? null
                            : () {
                                _onBoard('');
                              },
                        color: (currentatSign != null && !onboardError)
                            ? ColorConstants.dullText
                            : ColorConstants.orangeColor,
                        border: 7,
                        height: 50,
                        width: double.infinity,
                        fontSize: authenticating ? 17 : 20,
                        removePadding: true,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text(TextStrings.resetButton,
                            style: TextStyle(
                              color: ColorConstants.orangeColor,
                              fontWeight: FontWeight.normal,
                            )),
                        onPressed: () {
                          CommonUtilityFunctions().showResetAtsignDialog();
                        },
                      ),
                    ),
                    Spacer(),
                    Text(
                      TextStrings().desktopAppName,
                      style: CustomTextStyles.blackBold(size: 14),
                    ),
                    Text(
                      TextStrings().copyRight,
                      style: CustomTextStyles.secondaryRegular14,
                    ),
                  ],
                ),
              )),
          Expanded(
              child: Container(
            width: SizeConfig().screenWidth / 2,
            height: SizeConfig().screenHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CarouselSlider(
                    items: _constants.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: SizeConfig().screenWidth / 2,
                            color: ColorConstants.inputFieldColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: ((SizeConfig().screenWidth) / 2) / 2,
                                    height: SizeConfig().screenHeight / 2,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(i[0]),
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                                SizedBox(
                                  height: 18,
                                ),
                                Text(
                                  i[1],
                                  style: CustomTextStyles.blackBold(size: 22),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  i[2],
                                  style: CustomTextStyles
                                      .desktopSecondaryRegular18,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  i[3],
                                  style: CustomTextStyles
                                      .desktopSecondaryRegular18,
                                ),
                                SizedBox(
                                  height: 18,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: SizeConfig().screenHeight,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (_index, __) {
                        setState(() {
                          _currentPageNumber = _index;
                        });
                      },
                      scrollDirection: Axis.horizontal,
                    )),
                Positioned(
                    bottom: 50,
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [0, 1, 2].map((i) {
                          return _circle(i);
                        }).toList(),
                      ),
                    ))
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _circle(int _index) {
    return Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: _index != _currentPageNumber
              ? ColorConstants.dullText
              : ColorConstants.fontPrimary,
          shape: BoxShape.circle,
        ));
  }
}
