import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_switch_atsign.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/loading_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopWelcomeScreenStart extends StatefulWidget {
  const DesktopWelcomeScreenStart({Key key}) : super(key: key);
  @override
  _DesktopWelcomeScreenStartState createState() =>
      _DesktopWelcomeScreenStartState();
}

class _DesktopWelcomeScreenStartState extends State<DesktopWelcomeScreenStart> {
  bool authenticating = false;
  String currentatSign;
  AtClient atClient = AtClientManager.getInstance().atClient;
  List<String> popupMenuList = [];

  void _showLoader(bool loaderState, String authenticatingForAtsign) {
    if (mounted) {
      setState(() {
        if (loaderState) {
          currentatSign = authenticatingForAtsign;
        }
        authenticating = loaderState;
      });
    }
  }

  /// returns list of menu items which contains list of onboarded atsigns and [add_new_atsign], [save_backup_key]
  getpopupMenuList() async {
    popupMenuList = await BackendService.getInstance().getAtsignList();
    popupMenuList.add(TextStrings()
        .addNewAtsign); //to show add option in switch atsign drop down menu.
    popupMenuList.add(TextStrings().saveBackupKey);
    return popupMenuList;
  }

  cleanKeyChain() async {
    var _keyChainManager = KeyChainManager.getInstance();
    var _atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    _atSignsList?.forEach((element) {
      _keyChainManager.deleteAtSignFromKeychain(element);
    });
    print('Keychain cleaned');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MixedConstants.APPBAR_HEIGHT),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
                  // Icon(Icons.notifications, size: 30),
                  // SizedBox(width: 30),
                  FutureBuilder(
                      future: getpopupMenuList(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          List<String> atsignList = snapshot.data;
                          var image = CommonFunctions().getCachedContactImage(
                              atClient.getCurrentAtSign());
                          return Container(
                            width: 100,
                            child: PopupMenuButton<String>(
                                icon: Row(
                                  children: [
                                    image == null
                                        ? ContactInitial(
                                            initials:
                                                atClient.getCurrentAtSign(),
                                            size: 35,
                                            maxSize: (80.0 - 30.0),
                                            minSize: 35,
                                          )
                                        : CustomCircleAvatar(
                                            byteImage: image,
                                            nonAsset: true,
                                            size: 35,
                                          ),
                                    Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                                elevation: 10,
                                itemBuilder: (BuildContext context) {
                                  return getPopupMenuItem(atsignList);
                                },
                                onSelected: onAtsignChange),
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(clipBehavior: Clip.none, children: [
        DesktopWelcomeScreen(),
        authenticating
            ? LoadingDialog().showTextLoader('Initialising for $currentatSign')
            : SizedBox()
      ]),
    );
  }

  getPopupMenuItem(List<String> list) {
    List<PopupMenuItem<String>> menuItems = [];
    list.forEach((element) {
      menuItems.add(PopupMenuItem(
        value: element,
        child: DesktopSwitchAtsign(key: Key(element), atsign: element),
      ));
    });

    return menuItems;
  }

  onAtsignChange(String selectedOption) async {
    var atClientPrefernce;
    await BackendService.getInstance()
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) => print(e));

    if (selectedOption == TextStrings().addNewAtsign) {
      await CustomOnboarding.onboard(
          atSign: '',
          atClientPrefernce: atClientPrefernce,
          showLoader: _showLoader);
    } else if (selectedOption == TextStrings().saveBackupKey) {
      BackupKeyWidget(
        atClientService: AtClientManager.getInstance().atClient,
        atsign: AtClientManager.getInstance().atClient.getCurrentAtSign(),
      ).showBackupDialog(context);
    } else if (selectedOption !=
        AtClientManager.getInstance().atClient.getCurrentAtSign()) {
      await CustomOnboarding.onboard(
          atSign: selectedOption,
          atClientPrefernce: atClientPrefernce,
          showLoader: _showLoader);
    }
  }
}

class DesktopWelcomeScreen extends StatefulWidget {
  const DesktopWelcomeScreen({Key key}) : super(key: key);
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

  final List<String> routes = [
    DesktopRoutes.DEKSTOP_CONTACTS_SCREEN,
    DesktopRoutes.DESKTOP_HISTORY,
    DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN,
    DesktopRoutes.DEKSTOP_MYFILES,
    DesktopRoutes.DESKTOP_GROUP,
    DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER,
    '',
    '',
    '',
  ];

  bool showContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DesktopSideBarWidget(),
        body: Stack(children: [
          Row(
            children: [
              Container(
                width: MixedConstants.SIDEBAR_WIDTH,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(
                      color: Colors.black,
                      width: 0.1,
                    ),
                  ),
                ),
                child: ProviderHandler<NestedRouteProvider>(
                  functionName: Provider.of<NestedRouteProvider>(
                          NavService.navKey.currentContext,
                          listen: false)
                      .Routes,
                  showError: true,
                  load: (provider) {
                    provider.init();
                  },
                  successBuilder: (provider) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(height: 100.toHeight),
                      SideBarIcon(menuItemsIcons[0], routes[0], arguments: {
                        'isBlockedScreen': false,
                      }),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(menuItemsIcons[1], routes[1]),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(menuItemsIcons[2], routes[2], arguments: {
                        'isBlockedScreen': true,
                      }),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(menuItemsIcons[3], routes[3]),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(menuItemsIcons[4], routes[4]),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(menuItemsIcons[5], routes[5]),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(
                        menuItemsIcons[6],
                        routes[6],
                        isUrlLauncher: true,
                        arguments: {"url": MixedConstants.TERMS_CONDITIONS},
                      ),
                      SizedBox(height: 40.toHeight),
                      SideBarIcon(
                        menuItemsIcons[7],
                        routes[7],
                        isUrlLauncher: true,
                        arguments: {"url": MixedConstants.PRIVACY_POLICY},
                      ),
                      // SizedBox(height: 100.toHeight),
                    ],
                  ),
                  errorBuilder: (provider) => Center(
                    child: Text('Some error occured'),
                  ),
                ),
              ),
              Expanded(
                child: Navigator(
                  key: NavService.nestedNavKey,
                  initialRoute: DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL,
                  onGenerateRoute: (routeSettings) {
                    var routeBuilders = DesktopSetupRoutes.routeBuilders(
                        context, routeSettings);
                    return MaterialPageRoute(builder: (context) {
                      return routeBuilders[routeSettings.name](context);
                    });
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 50,
            child: Builder(
              builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.toWidth),
                        color: Colors.black),
                    child: Icon(Icons.arrow_forward_ios_sharp,
                        size: 20, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ]));
  }

  Widget sendFileTo({bool isSelectContacts = false}) {
    return InkWell(
        onTap: () {
          setState(() {
            showContent = !showContent;
          });
        },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListTile(
              title: showContent
                  ? Text(
                      (isSelectContacts
                          ? '18 contacts added'
                          : '2 files selected'),
                      style: CustomTextStyles.desktopSecondaryRegular18)
                  : SizedBox(),
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
            )));
  }
}

// ignore: must_be_immutable
class SideBarIcon extends StatelessWidget {
  final String image, routeName;
  final Map<String, dynamic> arguments;
  final bool isUrlLauncher;
  SideBarIcon(this.image, this.routeName,
      {this.arguments, this.isUrlLauncher = false});
  bool isHovered = false;
  bool isCurrentRoute = false;
  var nestedProvider = Provider.of<NestedRouteProvider>(
      NavService.navKey.currentContext,
      listen: false);

  @override
  Widget build(BuildContext context) {
    isCurrentRoute = nestedProvider.current_route == routeName ? true : false;
    return Container(
        width: 32,
        height: 32,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              isCurrentRoute ? ColorConstants.orangeColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () {
            if (routeName != null && routeName != '') {
              DesktopSetupRoutes.nested_push(routeName, arguments: arguments);
            }
            if ((isUrlLauncher) &&
                (arguments != null) &&
                (arguments['url'] != null)) {
              _launchInBrowser(arguments['url']);
            }
          },
          child: Image.asset(
            image,
            height: 22,
            color: isCurrentRoute ? Colors.white : ColorConstants.fadedText,
          ),
        ));

    //  MouseRegion(
    //   cursor: isHovered ? SystemMouseCursors.click : SystemMouseCursors.text,
    //   onEnter: (event) {
    //     hoverActivation(true);
    //   },
    //   onExit: (event) {
    //     hoverActivation(false);
    //   },
    //   child: Image.asset(
    //     widget.image,
    //     height: 22.toHeight,
    //     color: ColorConstants.fadedText,
    //   ),
    // );

    // hoverActivation(bool _newValue) {
    //   setState(() {
    //     isHovered = _newValue;
    //   });
    // }
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
