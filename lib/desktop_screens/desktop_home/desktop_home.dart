import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key key}) : super(key: key);

  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  BackendService backendService = BackendService.getInstance();
  var atClientPrefernce;
  bool authenticating = false, onboardError = false;
  String currentatSign;
  int _currentPageNumber = 0;

  var _constants = [
    [
      ImageConstants.homeCaraousel1,
      'Easy file sharing',
      'Share any files, no restrictions,',
      'Fast and secure across your contacts',
    ],
    [
      ImageConstants.homeCaraousel2,
      'Share with groups',
      'create groups and transfer file across',
      'all members',
    ],
    [
      ImageConstants.homeCaraousel3,
      'Trusted Senders',
      'Customise senders and receive files',
      'From trusted senders.'
    ],
  ];

  @override
  void initState() {
    storeApplicationDocumentsDirectory();
    _checkToOnboard();
    super.initState();
  }

  storeApplicationDocumentsDirectory() async {
    var _dir;
    // TODO: have to implement for linux and windows
    if (Platform.isMacOS || Platform.isWindows) {
      _dir = await getApplicationDocumentsDirectory();
    }
    final path = Directory(_dir.path + '/@mosphere-pro');

    if (!(await path.exists())) {
      await path.create();
    }

    MixedConstants.ApplicationDocumentsDirectory = path.path;
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

  Future<void> _onBoard(String _atsign) async {
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
                        onTap: currentatSign != null
                            ? () {}
                            : () {
                                _onBoard('');
                              },
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: ColorConstants.textBoxBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: ListTile(
                              title: Text(currentatSign ?? 'Enter @sign',
                                  style: CustomTextStyles
                                      .desktopSecondaryRegular18),
                            ))),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CommonButton(
                        authenticating
                            ? 'Initialising for $currentatSign...'
                            : (currentatSign != null && !onboardError
                                ? 'Authenticating...'
                                : 'Start'),
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
                        child: Text('RESET',
                            style:
                                TextStyle(color: ColorConstants.orangeColor)),
                        onPressed: () {
                          _showResetDialog();
                        },
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

  _showResetDialog() async {
    bool isSelectAtsign = false;
    bool isSelectAll = false;
    var atsignsList = await KeychainUtil.getAtsignList();
    if (atsignsList == null) {
      atsignsList = [];
    }
    Map atsignMap = {};
    for (String atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, stateSet) {
            return AlertDialog(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TextStrings.resetDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 0.8,
                    )
                  ],
                ),
                content: atsignsList.isEmpty
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(TextStrings.noAtsignToReset,
                            style: TextStyle(fontSize: 15)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 15,
                                // color: AtTheme.themecolor,
                              ),
                            ),
                          ),
                        )
                      ])
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CheckboxListTile(
                              onChanged: (value) {
                                isSelectAll = value;
                                atsignMap
                                    .updateAll((key, value1) => value1 = value);
                                stateSet(() {});
                              },
                              value: isSelectAll,
                              checkColor: Colors.white,
                              title: Text('Select All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            for (var atsign in atsignsList)
                              CheckboxListTile(
                                onChanged: (value) {
                                  atsignMap[atsign] = value;
                                  stateSet(() {});
                                },
                                value: atsignMap[atsign],
                                checkColor: Colors.white,
                                title: Text('$atsign'),
                              ),
                            Divider(thickness: 0.8),
                            if (isSelectAtsign)
                              Text(TextStrings.resetErrorText,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(TextStrings.resetWarningText,
                                style: TextStyle(fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(children: [
                              TextButton(
                                onPressed: () {
                                  var tempAtsignMap = {};
                                  tempAtsignMap.addAll(atsignMap);
                                  tempAtsignMap.removeWhere(
                                      (key, value) => value == false);
                                  if (tempAtsignMap.keys.toList().isEmpty) {
                                    isSelectAtsign = true;
                                    stateSet(() {});
                                  } else {
                                    isSelectAtsign = false;
                                    _resetDevice(tempAtsignMap.keys.toList());
                                  }
                                },
                                child: Text('Remove',
                                    style: TextStyle(
                                      color: ColorConstants.fontPrimary,
                                      fontSize: 15,
                                    )),
                              ),
                              Spacer(),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black)))
                            ])
                          ],
                        ),
                      ));
          });
        });
  }

  _resetDevice(List checkedAtsigns) async {
    Navigator.of(context).pop();
    await BackendService.getInstance()
        .resetAtsigns(checkedAtsigns)
        .then((value) async {
      print('reset done');
    }).catchError((e) {
      print('error in reset: $e');
    });
  }
}
