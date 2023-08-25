import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/menu_item.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/onboarded_atsign_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/sidebar_item.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/switching_atsign_dialog.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';

class SideBarNew extends StatefulWidget {
  const SideBarNew({Key? key}) : super(key: key);

  @override
  State<SideBarNew> createState() => _SideBarNewState();
}

class _SideBarNewState extends State<SideBarNew> {
  List<MenuItem> generalMenuItems = [
    MenuItem(
      title: TextStrings().sidebarContact,
      image: ImageConstants.contactsIcon,
      routeName: DesktopRoutes.DEKSTOP_CONTACTS_SCREEN,
      children: [
        MenuItem(
          title: TextStrings().sidebarTrustedSenders,
          image: ImageConstants.trustedSender,
          routeName: DesktopRoutes.DESKTOP_TRUSTED_SENDER,
        ),
        MenuItem(
          title: TextStrings().groups,
          image: ImageConstants.groups,
          routeName: DesktopRoutes.DESKTOP_GROUP,
        ),
      ],
    ),
    MenuItem(
      title: TextStrings().sidebarTransferHistory,
      image: ImageConstants.transferHistoryIcon,
      routeName: DesktopRoutes.DESKTOP_HISTORY,
    ),
    MenuItem(
      title: TextStrings().myFiles,
      image: ImageConstants.myFiles,
      routeName: DesktopRoutes.DEKSTOP_MYFILES,
    ),
  ];

  List<MenuItem> helpCenterMenuItems = [
    MenuItem(
      title: TextStrings().sidebarFaqs,
      image: ImageConstants.faqs,
      routeName: MixedConstants.FAQ,
      isUrl: true,
    ),
    MenuItem(
      title: TextStrings().contactUs,
      image: ImageConstants.contactUs,
      isEmail: true,
    ),
    MenuItem(
      title: TextStrings().termsAndConditions,
      image: ImageConstants.termsAndConditions,
      routeName: MixedConstants.TERMS_CONDITIONS,
      isUrl: true,
    ),
  ];

  var settingsMenuItem = MenuItem(
    title: TextStrings().sidebarSettings,
    image: ImageConstants.settings,
    routeName: DesktopRoutes.DESKTOP_SETTINGS,
  );

  Uint8List? image;

  String? name;

  @override
  void initState() {
    getAtsignDetails();
    super.initState();
  }

  Future<void> getAtsignDetails({String? atSign}) async {
    AtContact? contact;
    if (BackendService.getInstance().currentAtSign != null) {
      contact = await getAtSignDetails(
          atSign ?? BackendService.getInstance().currentAtSign!);
    }

    if (contact != null) {
      if (mounted) {
        setState(() {
          image = CommonUtilityFunctions().getContactImage(contact!);
        });
      }

      if (contact.tags != null && contact.tags!['name'] != null) {
        String newName = contact.tags!['name'].toString();
        if (mounted) {
          setState(() {
            name = newName;
          });
        }
      }
    }

    if (mounted) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SideBarProvider>(
      builder: (_context, _sideBarProvider, _) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: _sideBarProvider.isSidebarExpanded
                        ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
                        : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.toHeight),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    DesktopSetupRoutes.nested_pop();
                                  },
                                  child: Image.asset(
                                      ImageConstants.logoWhiteIcon,
                                      height: 52.toHeight),
                                ),
                                SizedBox(width: 10.toWidth),
                                _sideBarProvider.isSidebarExpanded
                                    ? Text.rich(
                                        TextSpan(
                                            text: "Atmosphere",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Pro",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ]),
                                        style: TextStyle(
                                          fontSize: 20.toFont,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            SizedBox(height: 20.toHeight),
                            Container(
                              height: 1.toHeight,
                              width: double.maxFinite,
                              color: Colors.white,
                            ),
                            SizedBox(height: 20.toHeight),
                            InkWell(
                              onTap: () async {
                                await DesktopSetupRoutes.nested_pop();
                              },
                              child: _sideBarProvider.isSidebarExpanded
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15.toHeight,
                                          horizontal: 25.toWidth),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Transfer",
                                            style: TextStyle(
                                              fontSize: 15.toFont,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8.toWidth),
                                          Icon(
                                            Icons.send_outlined,
                                            size: 22,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    )
                                  : CircleAvatar(
                                      minRadius: 25,
                                      backgroundColor: Colors.white,
                                      child: Center(
                                        child: Icon(
                                          Icons.send_outlined,
                                          size: 22,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 20.toHeight),
                            Text(
                              "GENERAL",
                              style: TextStyle(
                                fontSize: 8.toFont,
                                color: ColorConstants.lightGray,
                              ),
                            ),
                            SizedBox(height: 5.toHeight),
                            ListView.builder(
                              itemCount: generalMenuItems.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: SidebarItem(
                                    menuItem: generalMenuItems[index],
                                    isSidebarExpanded:
                                        _sideBarProvider.isSidebarExpanded,
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 40.toHeight),
                            Text(
                              "HELP CENTER",
                              style: TextStyle(
                                fontSize: 8.toFont,
                                color: ColorConstants.lightGray,
                              ),
                            ),
                            SizedBox(height: 5.toHeight),
                            ListView.builder(
                              itemCount: helpCenterMenuItems.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: SidebarItem(
                                    menuItem: helpCenterMenuItems[index],
                                    isSidebarExpanded:
                                        _sideBarProvider.isSidebarExpanded,
                                    isUrlLauncher:
                                        helpCenterMenuItems[index].isUrl ??
                                            false,
                                    isEmailLauncher:
                                        helpCenterMenuItems[index].isEmail ??
                                            false,
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 100),
                            SizedBox(
                              width: double.maxFinite,
                              child: SidebarItem(
                                menuItem: settingsMenuItem,
                                isSidebarExpanded:
                                    _sideBarProvider.isSidebarExpanded,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                      errorBuilder: (provider) => Center(
                        child: Text(TextStrings().errorOccured),
                      ),
                    ),
                  ),
                  if (_sideBarProvider.isSwitchingAtSign &&
                      _sideBarProvider.isSidebarExpanded)
                    Positioned(
                      left: 20,
                      right: 16,
                      bottom: 24,
                      child: SwitchingAtSignDialog(
                        onSwitchAtSign: (value) async {
                          _sideBarProvider.changeIsSwitchingAtSign();
                          await getAtsignDetails(atSign: value);
                          await DesktopSetupRoutes.nested_pop();
                        },
                      ),
                    ),
                ],
              ),
            ),
            OnboardedAtSignCard(
              avatar: image,
              displayName: name,
              atSignKey: BackendService.getInstance().currentAtSign!,
              isExpanded: _sideBarProvider.isSidebarExpanded,
              isSelected: _sideBarProvider.isSwitchingAtSign,
              onTap: () {
                _sideBarProvider.changeIsSwitchingAtSign();
              },
            ),
          ],
        );
      },
    );
  }
}
