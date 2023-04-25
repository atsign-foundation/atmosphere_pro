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
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/switch_atsign_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopWelcomeScreenStart extends StatefulWidget {
  const DesktopWelcomeScreenStart({Key? key}) : super(key: key);
  @override
  _DesktopWelcomeScreenStartState createState() =>
      _DesktopWelcomeScreenStartState();
}

class _DesktopWelcomeScreenStartState extends State<DesktopWelcomeScreenStart> {
  bool authenticating = false;
  String? currentatSign;
  AtClient atClient = AtClientManager.getInstance().atClient;

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
  Future<List<String>> getpopupMenuList() async {
    var popupMenuList = <String>[];
    var atsignList = await BackendService.getInstance().getAtsignList();
    atsignList?.forEach((element) {
      popupMenuList.add(element);
    });

    popupMenuList.add(TextStrings()
        .addNewAtsign); //to show add option in switch atsign drop down menu.
    popupMenuList.add(TextStrings().saveBackupKey);
    return popupMenuList;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ProviderHandler<SwitchAtsignProvider>(
        functionName: 'switchAtsign',
        showError: true,
        load: (provider) {
          provider.update();
        },
        errorBuilder: (provider) {
          return Text(TextStrings().error);
        },
        successBuilder: (provider) {
          atClient = AtClientManager.getInstance().atClient;

          print(
              'ProviderHandler SwitchAtsignProvider build called ${AtClientManager.getInstance().atClient.getCurrentAtSign()}');
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
                      leading: InkWell(
                        onTap: () {
                          DesktopSetupRoutes.nested_pop();
                        },
                        child: Image.asset(
                          ImageConstants.logoIcon,
                          height: 50.toHeight,
                          width: 50.toHeight,
                        ),
                      ),
                      actions: [
                        FutureBuilder(
                            key: Key(AtClientManager.getInstance()
                                .atClient
                                .getCurrentAtSign()!),
                            future: getpopupMenuList(),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.data != null) {
                                List<String>? atsignList = snapshot.data;
                                var image = CommonUtilityFunctions()
                                    .getCachedContactImage(
                                        atClient.getCurrentAtSign()!);
                                return Container(
                                  width: 100,
                                  child: PopupMenuButton<String>(
                                      icon: Row(
                                        children: [
                                          image == null
                                              ? ContactInitial(
                                                  initials: atClient
                                                      .getCurrentAtSign(),
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
                                        return getPopupMenuItem(atsignList!);
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
                  ? LoadingDialog().showTextLoader(
                      '${TextStrings().initialisingFor} $currentatSign')
                  : SizedBox()
            ]),
          );
        });
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
    late var atClientPrefernce;
    await BackendService.getInstance()
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) => print(e));

    if (selectedOption == TextStrings().addNewAtsign) {
      await CustomOnboarding.onboard(
        atSign: '',
        atClientPrefernce: atClientPrefernce,
        showLoader: _showLoader,
      );
    } else if (selectedOption == TextStrings().saveBackupKey) {
      BackupKeyWidget(
        atsign: AtClientManager.getInstance().atClient.getCurrentAtSign()!,
      ).showBackupDialog(context);
    } else if (selectedOption !=
        AtClientManager.getInstance().atClient.getCurrentAtSign()) {
      await CustomOnboarding.onboard(
        atSign: selectedOption,
        atClientPrefernce: atClientPrefernce,
        showLoader: _showLoader,
      );
    }
  }
}

class DesktopWelcomeScreen extends StatefulWidget {
  const DesktopWelcomeScreen({Key? key}) : super(key: key);
  @override
  _DesktopWelcomeScreenState createState() => _DesktopWelcomeScreenState();
}

class _DesktopWelcomeScreenState extends State<DesktopWelcomeScreen> {
  final List<String> menuItemsIcons = [
    ImageConstants.homeIcon,
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.myFiles,
    ImageConstants.groups,
    // ImageConstants.transferHistoryIcon,
    ImageConstants.trustedSender,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.faqsIcon,
    ImageConstants.trustedSendersIcon,
    ImageConstants.contactUs,
  ];

  final List<String> menuItemsTitle = [
    TextStrings().sidebarHome,
    TextStrings().sidebarContact,
    TextStrings().sidebarTransferHistory,
    TextStrings().sidebarBlockedUser,
    TextStrings().myFiles,
    TextStrings().groups,
    // TextStrings().downloadAllFiles,
    TextStrings().sidebarTrustedSenders,
    TextStrings().sidebarTermsAndConditions,
    TextStrings().sidebarFaqs,
    TextStrings().sidebarContactUs,
  ];

  final List<String> routes = [
    DesktopRoutes.DESKTOP_HOME,
    DesktopRoutes.DEKSTOP_CONTACTS_SCREEN,
    DesktopRoutes.DESKTOP_HISTORY,
    DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN,
    DesktopRoutes.DEKSTOP_MYFILES,
    DesktopRoutes.DESKTOP_GROUP,
    // DesktopRoutes.DESKTOP_DOWNLOAD_ALL,
    DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER,
    '',
    '',
    '',
  ];

  bool showContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Row(
        children: [
          Consumer<SideBarProvider>(
            builder: (_context, _sideBarProvider, _) {
              if (_sideBarProvider.isSidebarExpanded) {
                MixedConstants.SIDEBAR_WIDTH = 180;
              } else {
                MixedConstants.SIDEBAR_WIDTH = 70;
              }

              return SingleChildScrollView(
                child: Container(
                  width: MixedConstants.SIDEBAR_WIDTH,
                  padding: EdgeInsets.only(
                      left: _sideBarProvider.isSidebarExpanded ? 10 : 0),
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
                    functionName: 'routes',
                    showError: true,
                    load: (provider) {
                      provider.init();
                    },
                    successBuilder: (provider) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: _sideBarProvider.isSidebarExpanded
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.center,
                      children: [
                        SideBarIcon(
                          menuItemsIcons[0],
                          routes[0],
                          title: menuItemsTitle[0],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[1],
                          routes[1],
                          arguments: {
                            'isBlockedScreen': false,
                          },
                          title: menuItemsTitle[1],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[2],
                          routes[2],
                          title: menuItemsTitle[2],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[3],
                          routes[3],
                          arguments: {
                            'isBlockedScreen': true,
                          },
                          title: menuItemsTitle[3],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[4],
                          routes[4],
                          title: menuItemsTitle[4],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[5],
                          routes[5],
                          title: menuItemsTitle[5],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[6],
                          routes[6],
                          title: menuItemsTitle[6],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        // SideBarIcon(
                        //   menuItemsIcons[7],
                        //   routes[7],
                        //   isUrlLauncher: true,
                        //   title: menuItemsTitle[7],
                        //   isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        // ),
                        // SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[7],
                          routes[7],
                          isUrlLauncher: true,
                          arguments: {"url": MixedConstants.TERMS_CONDITIONS},
                          title: menuItemsTitle[7],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[8],
                          routes[8],
                          isUrlLauncher: true,
                          arguments: {"url": MixedConstants.FAQ},
                          title: menuItemsTitle[8],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                        SizedBox(height: 40.toHeight),
                        SideBarIcon(
                          menuItemsIcons[10],
                          routes[7],
                          isEmailLauncher: true,
                          arguments: {"email": 'atmospherepro@atsign.com'},
                          title: menuItemsTitle[9],
                          isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                        ),
                      ],
                    ),
                    errorBuilder: (provider) => Center(
                      child: Text(TextStrings().errorOccured),
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ClipRect(
              child: Navigator(
                key: NavService.nestedNavKey,
                initialRoute: DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL,
                onGenerateRoute: (routeSettings) {
                  var routeBuilders =
                      DesktopSetupRoutes.routeBuilders(context, routeSettings);
                  return MaterialPageRoute(builder: (context) {
                    return routeBuilders[routeSettings.name!]!(context);
                  });
                },
              ),
            ),
          ),
        ],
      ),
      Consumer<SideBarProvider>(builder: (_context, _provider, _) {
        return Positioned(
          top: 40,
          left: _provider.isSidebarExpanded ? 160 : 50,
          child: Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  Provider.of<SideBarProvider>(context, listen: false)
                      .updateSidebarWidth();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.toWidth),
                      color: Colors.black),
                  child: Icon(
                      _provider.isSidebarExpanded
                          ? Icons.arrow_back_ios
                          : Icons.arrow_forward_ios_sharp,
                      size: 20,
                      color: Colors.white),
                ),
              );
            },
          ),
        );
      }),
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
  final String? image, routeName, title;
  final Map<String, dynamic>? arguments;
  final bool isUrlLauncher, isSidebarExpanded, isEmailLauncher;
  SideBarIcon(this.image, this.routeName,
      {this.arguments,
      this.isUrlLauncher = false,
      this.isEmailLauncher = false,
      this.isSidebarExpanded = true,
      this.title});
  bool isHovered = false;
  bool isCurrentRoute = false;
  var nestedProvider = Provider.of<NestedRouteProvider>(
      NavService.navKey.currentContext!,
      listen: false);

  @override
  Widget build(BuildContext context) {
    isCurrentRoute = nestedProvider.current_route == routeName ? true : false;
    if (!isCurrentRoute) {
      isCurrentRoute = (nestedProvider.current_route == null &&
              routeName == DesktopRoutes.DESKTOP_HOME)
          ? true
          : false;
    }
    return Container(
        width: isSidebarExpanded ? null : 32,
        height: 32,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () {
            if (routeName != null && routeName != '') {
              if (routeName == DesktopRoutes.DESKTOP_HOME) {
                DesktopSetupRoutes.nested_pop();
                return;
              }
              DesktopSetupRoutes.nested_push(routeName, arguments: arguments);
            }
            if ((isUrlLauncher) &&
                (arguments != null) &&
                (arguments!['url'] != null)) {
              _launchInBrowser(arguments!['url']);
            }
            if ((isEmailLauncher) &&
                (arguments != null) &&
                (arguments!['email'] != null)) {
              _launchInEmail(arguments!['email']);
            }
          },
          child: routeName == DesktopRoutes.DESKTOP_HISTORY
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          image!,
                          height: 22,
                          color: isCurrentRoute
                              ? ColorConstants.orangeColor
                              : ColorConstants.fadedText,
                        ),
                        SizedBox(width: isSidebarExpanded ? 10 : 0),
                        isSidebarExpanded
                            ? Text(
                                title!,
                                softWrap: true,
                                style: TextStyle(
                                  color: isCurrentRoute
                                      ? ColorConstants.orangeColor
                                      : ColorConstants.fadedText,
                                  letterSpacing: 0.1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                    Consumer<FileDownloadChecker>(
                      builder: (context, _fileDownloadChecker, _) {
                        return _fileDownloadChecker.undownloadedFilesExist
                            ? Positioned(
                                left: 10,
                                top: -8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(1.toHeight),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 5.toWidth,
                                  ),
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Image.asset(
                      image!,
                      height: 22,
                      color: isCurrentRoute
                          ? ColorConstants.orangeColor
                          : ColorConstants.fadedText,
                    ),
                    SizedBox(width: isSidebarExpanded ? 10 : 0),
                    isSidebarExpanded
                        ? Text(
                            title!,
                            softWrap: true,
                            style: TextStyle(
                              color: isCurrentRoute
                                  ? ColorConstants.orangeColor
                                  : ColorConstants.fadedText,
                              letterSpacing: 0.1,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : SizedBox()
                  ],
                ),
        ));
  }

  Future<void> _launchInBrowser(String url) async {
    try {
      await launchUrl(
        Uri(
          scheme: 'https',
          path: 'atsign.com/terms-conditions/',
        ),
      );
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInEmail(String email) async {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: email,
      ),
    );
  }
}
