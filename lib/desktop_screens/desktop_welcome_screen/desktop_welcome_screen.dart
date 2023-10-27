import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_switch_atsign.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/gradient_button.dart';
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
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopWelcomeScreenStart extends StatefulWidget {
  const DesktopWelcomeScreenStart({Key? key}) : super(key: key);

  @override
  State<DesktopWelcomeScreenStart> createState() =>
      _DesktopWelcomeScreenStartState();
}

class _DesktopWelcomeScreenStartState extends State<DesktopWelcomeScreenStart> {
  bool authenticating = false;
  String? currentatSign;
  AtClient atClient = AtClientManager.getInstance().atClient;

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
            body: Stack(clipBehavior: Clip.none, children: [
              DesktopWelcomeScreen(atClient: atClient),
              authenticating
                  ? LoadingDialog().showTextLoader(
                      '${TextStrings().initialisingFor} $currentatSign')
                  : const SizedBox()
            ]),
          );
        });
  }
}

class DesktopWelcomeScreen extends StatefulWidget {
  const DesktopWelcomeScreen({
    Key? key,
    required this.atClient,
  }) : super(key: key);

  final AtClient atClient;

  @override
  State<DesktopWelcomeScreen> createState() => _DesktopWelcomeScreenState();
}

class _DesktopWelcomeScreenState extends State<DesktopWelcomeScreen> {
  final List<String> menuItemsIcons = [
    // general
    ImageConstants.homeIcon,
    ImageConstants.contactsIcon,
    ImageConstants.transferHistoryIcon,
    ImageConstants.blockedIcon,
    ImageConstants.myFiles,
    ImageConstants.groups,
    // ImageConstants.transferHistoryIcon,
    ImageConstants.trustedSender,
    // helpcenter
    ImageConstants.faqsIcon,
    ImageConstants.termsAndConditionsIcon,
    ImageConstants.sidebarSettings,
    // ImageConstants.trustedSendersIcon,
    // ImageConstants.contactUs,
  ];

  final List<String> menuItemsTitle = [
    // general
    TextStrings().sidebarHome,
    TextStrings().sidebarContact,
    TextStrings().sidebarTransferHistory,
    TextStrings().sidebarBlockedUser,
    TextStrings().myFiles,
    TextStrings().groups,
    // TextStrings().downloadAllFiles,
    TextStrings().sidebarTrustedSenders,
    // helpcenter
    TextStrings().sidebarFaqs,
    TextStrings().sidebarTermsAndConditions,
    TextStrings().sidebarSettings,
    // TextStrings().sidebarContactUs,
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
    DesktopRoutes.DESKTOP_SETTINGS,
    '',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SideBarProvider>(builder: (context, sideBarProvider, _) {
            return SizedBox(
              width: sideBarProvider.isSidebarExpanded
                  ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
                  : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
            );
          }),
          Expanded(
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
        ],
      ),
      Consumer<SideBarProvider>(
        builder: (context, sideBarProvider, _) {
          return Container(
            width: sideBarProvider.isSidebarExpanded
                ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
                : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
            height: SizeConfig().screenHeight,
            margin: const EdgeInsets.only(right: 2),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  // color: Colors.grey.withOpacity(0.5),
                  color: ColorConstants.light_grey,
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: Offset(1, 2), // changes position of shadow
                ),
              ],
            ),
            child: ProviderHandler<NestedRouteProvider>(
              functionName: 'routes',
              showError: true,
              load: (provider) {
                provider.init();
              },
              successBuilder: (provider) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: sideBarProvider.isSidebarExpanded
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.toHeight),
                    InkWell(
                      onTap: () {
                        DesktopSetupRoutes.nested_pop();
                      },
                      child: Image.asset(ImageConstants.logoIcon,
                          height: 58.toHeight),
                    ),
                    SizedBox(height: 20.toHeight),
                    if (sideBarProvider.isSidebarExpanded)
                      GradientButton(
                        onPressed: () {},
                        height: 50.toHeight,
                        width: MixedConstants.SIDEBAR_WIDTH_EXPANDED - 41,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              TextStrings().sidebarSendFiles,
                              style: CustomTextStyles.desktopButton15,
                            ),
                            SizedBox(width: 8.toWidth),
                            Image.asset(
                              ImageConstants.sendIcon,
                              height: 20.toHeight,
                              fit: BoxFit.cover,
                              color: CustomTextStyles.desktopButton15.color,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 2.toHeight),
                    SidebarTitleText(TextStrings().sidebarGeneral),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[0],
                      routes[0],
                      title: menuItemsTitle[0],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[1],
                      routes[1],
                      arguments: const {
                        'isBlockedScreen': false,
                      },
                      title: menuItemsTitle[1],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[2],
                      routes[2],
                      title: menuItemsTitle[2],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[3],
                      routes[3],
                      arguments: const {
                        'isBlockedScreen': true,
                      },
                      title: menuItemsTitle[3],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[4],
                      routes[4],
                      title: menuItemsTitle[4],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[5],
                      routes[5],
                      title: menuItemsTitle[5],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[6],
                      routes[6],
                      title: menuItemsTitle[6],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SidebarTitleText(TextStrings().sidebarHelpCenter),
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
                      routes[10],
                      isUrlLauncher: true,
                      arguments: const {"url": MixedConstants.FAQ},
                      title: menuItemsTitle[7],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[8],
                      routes[8],
                      isUrlLauncher: true,
                      arguments: const {"url": MixedConstants.TERMS_CONDITIONS},
                      title: menuItemsTitle[8],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 2.toHeight),
                    SideBarIcon(
                      menuItemsIcons[9],
                      routes[7],
                      title: menuItemsTitle[9],
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    // SideBarIcon(
                    //   menuItemsIcons[10],
                    //   routes[7],
                    //   isEmailLauncher: true,
                    //   arguments: {"email": 'atmospherepro@atsign.com'},
                    //   title: menuItemsTitle[9],
                    //   isSidebarExpanded: _sideBarProvider.isSidebarExpanded,
                    // ),
                    SizedBox(height: 10.toHeight),
                    BuildAvatarWidget(
                      atClient: widget.atClient,
                      isSidebarExpanded: sideBarProvider.isSidebarExpanded,
                    ),
                    SizedBox(height: 10.toHeight),
                  ],
                ),
              ),
              errorBuilder: (provider) => Center(
                child: Text(TextStrings().errorOccured),
              ),
            ),
          );
        },
      ),
      Consumer<SideBarProvider>(builder: (context, provider, _) {
        return Positioned(
          top: 40,
          left: provider.isSidebarExpanded
              ? MixedConstants.SIDEBAR_WIDTH_EXPANDED - 20
              : MixedConstants.SIDEBAR_WIDTH_COLLAPSED - 20,
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
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                      provider.isSidebarExpanded
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
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: ListTile(
              title: showContent
                  ? Text(
                      (isSelectContacts
                          ? '18 contacts added'
                          : '2 files selected'),
                      style: CustomTextStyles.desktopSecondaryRegular18)
                  : const SizedBox(),
              trailing: isSelectContacts
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                      child: Image.asset(
                        ImageConstants.contactsIcon,
                        color: Colors.black,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                      child: const Icon(
                        Icons.add_circle,
                        color: Colors.black,
                      ),
                    ),
            )));
  }
}

class BuildAvatarWidget extends StatefulWidget {
  const BuildAvatarWidget({
    Key? key,
    required this.atClient,
    required this.isSidebarExpanded,
  }) : super(key: key);

  final AtClient atClient;
  final bool isSidebarExpanded;

  @override
  State<BuildAvatarWidget> createState() => _BuildAvatarWidgetState();
}

class _BuildAvatarWidgetState extends State<BuildAvatarWidget> {
  bool authenticating = false;

  String? currentatSign;

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

  getPopupMenuItem(List<String> list) {
    List<PopupMenuItem<String>> menuItems = [];
    for (var element in list) {
      menuItems.add(PopupMenuItem(
        value: element,
        child: DesktopSwitchAtsign(key: Key(element), atsign: element),
      ));
    }

    return menuItems;
  }

  onAtsignChange(String selectedOption) async {
    late AtClientPreference atClientPrefernce;
    await BackendService.getInstance()
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);

    if (selectedOption == TextStrings().addNewAtsign) {
      await CustomOnboarding.onboard(
        atSign: '',
        atClientPrefernce: atClientPrefernce,
        showLoader: _showLoader,
      );
    } else if (selectedOption == TextStrings().saveBackupKey) {
      if (mounted) {
        BackupKeyWidget(
          atsign: AtClientManager.getInstance().atClient.getCurrentAtSign()!,
        ).showBackupDialog(context);
      }
    } else if (selectedOption !=
        AtClientManager.getInstance().atClient.getCurrentAtSign()) {
      await CustomOnboarding.onboard(
        atSign: selectedOption,
        atClientPrefernce: atClientPrefernce,
        showLoader: _showLoader,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: Key(AtClientManager.getInstance().atClient.getCurrentAtSign()!),
        future: getpopupMenuList(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.data != null) {
            List<String>? atsignList = snapshot.data;
            var image = CommonUtilityFunctions()
                .getCachedContactImage(widget.atClient.getCurrentAtSign()!);
            return SizedBox(
              width: widget.isSidebarExpanded
                  ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
                  : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
              height: 74.toHeight,
              child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisAlignment: widget.isSidebarExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      image == null
                          ? ContactInitialV2(
                              initials: widget.atClient.getCurrentAtSign(),
                              size: 50.toFont,
                              maxSize: (80.0 - 30.0),
                              minSize: 50,
                            )
                          : CustomCircleAvatarV2(
                              byteImage: image,
                              nonAsset: true,
                              size: 50.toFont,
                            ),
                      // Icon(Icons.arrow_drop_down)
                      if (widget.isSidebarExpanded)
                        Flexible(
                          child: Text(
                            '     ${widget.atClient.getCurrentAtSign()!}',
                            style:
                                CustomTextStyles.desktopPrimaryBold12.copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  elevation: 10,
                  itemBuilder: (BuildContext context) {
                    return getPopupMenuItem(atsignList!);
                  },
                  onSelected: onAtsignChange),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}

class SidebarTitleText extends StatelessWidget {
  const SidebarTitleText(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.toHeight),
      child: Text(
        text,
        style: CustomTextStyles.desktopSecondaryBold12,
      ),
    );
  }
}

// ignore: must_be_immutable
class SideBarIcon extends StatelessWidget {
  final String? image, routeName, title;
  final Map<String, dynamic>? arguments;
  final bool isUrlLauncher, isSidebarExpanded, isEmailLauncher;

  SideBarIcon(this.image, this.routeName,
      {Key? key,
      this.arguments,
      this.isUrlLauncher = false,
      this.isEmailLauncher = false,
      this.isSidebarExpanded = true,
      this.title})
      : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isCurrentRoute
              ? Image.asset(
                  ImageConstants.sidebarSelectedTile,
                  height: 50.toHeight,
                  width: 4,
                )
              : const SizedBox(width: 4),
          Flexible(
            child: Container(
                width: isSidebarExpanded ? double.maxFinite : 50,
                height: 50.toHeight,
                padding: EdgeInsets.symmetric(
                  vertical: 14.toHeight,
                  horizontal: isSidebarExpanded ? 20 : 12,
                ),
                decoration: isCurrentRoute
                    ? const BoxDecoration(
                        color: ColorConstants.sidebarTileSelected,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ))
                    : null,
                child: InkWell(
                  onTap: () {
                    if (routeName != null && routeName != '') {
                      if (routeName == DesktopRoutes.DESKTOP_HOME) {
                        DesktopSetupRoutes.nested_pop();
                        return;
                      }
                      DesktopSetupRoutes.nested_push(routeName,
                          arguments: arguments);
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
                            BuildSidebarIconTitle(
                              image: image,
                              isCurrentRoute: isCurrentRoute,
                              isSidebarExpanded: isSidebarExpanded,
                              title: title,
                            ),
                            Consumer<FileDownloadChecker>(
                              builder: (context, fileDownloadChecker, _) {
                                return fileDownloadChecker
                                        .undownloadedFilesExist
                                    ? Positioned(
                                        left: 12,
                                        top: -4,
                                        child: Container(
                                          decoration: const BoxDecoration(
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
                                    : const SizedBox();
                              },
                            ),
                          ],
                        )
                      : BuildSidebarIconTitle(
                          image: image,
                          isCurrentRoute: isCurrentRoute,
                          isSidebarExpanded: isSidebarExpanded,
                          title: title,
                        ),
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    try {
      await launchUrl(
        Uri(
          scheme: 'https',
          path: url,
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

class BuildSidebarIconTitle extends StatelessWidget {
  const BuildSidebarIconTitle({
    Key? key,
    required this.image,
    required this.isCurrentRoute,
    required this.isSidebarExpanded,
    required this.title,
  }) : super(key: key);

  final String? image;
  final bool isCurrentRoute;
  final bool isSidebarExpanded;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          image!,
          height: 22.toFont,
          color: isCurrentRoute
              ? ColorConstants.sidebarTextSelected
              : ColorConstants.sidebarTextUnselected,
        ),
        SizedBox(width: isSidebarExpanded ? 10 : 0),
        isSidebarExpanded
            ? Text(
                title!,
                softWrap: true,
                style: CustomTextStyles.desktopPrimaryRegular12.copyWith(
                  color: isCurrentRoute
                      ? null
                      : ColorConstants.sidebarTextUnselected,
                  fontWeight: FontWeight.w500,
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
