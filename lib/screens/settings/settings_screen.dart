import 'dart:io';
import 'dart:ui';

import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/blocked_contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/settings/widgets/settings_buttons.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> optionTitle = [
    TextStrings().blockedAtSign,
    TextStrings().backUpKeys,
    TextStrings().switchatSign,
    TextStrings().deleteAtsigns,
    TextStrings().faqs,
    TextStrings().contactUs,
    TextStrings().termsAppBar,
  ];

  final List<String> optionIcons = [
    AppVectors.icSettingBlock,
    AppVectors.icSettingBackup,
    AppVectors.icSettingSwitch,
    AppVectors.icSettingDelete,
    AppVectors.icSettingFAQ,
    AppVectors.icSettingContactUs,
    AppVectors.icSettingPrivacy,
  ];

  void switchAtsign() async {
    var atSignList = await KeychainUtil.getAtsignList();
    await showModalBottomSheet(
      isScrollControlled: true,
      context: NavService.navKey.currentContext!,
      constraints: const BoxConstraints(
        minHeight: 900,
        maxHeight: double.maxFinite,
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: AtSignBottomSheet(
            atSignList: atSignList,
          ),
        );
      },
    );
  }

  showBackupDialog(BuildContext context) {
    SizeConfig().init(context);
    showDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            title: Center(
              child: Text(
                'Backup your secret keys',
                style: CustomTextStyles.primaryBold18,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
              width:
              (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                  ? 600
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'To be safe, we recommend that you keep a backup of your keys',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.toHeight),
                      Row(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                    Colors.white),
                                side: MaterialStateProperty.all<BorderSide>(
                                  const BorderSide(color: Colors.black),
                                ),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                    TextStyle(
                                      fontSize: 16.toFont,
                                    )),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(
                                        horizontal: 15.toWidth,
                                        vertical: 10.toHeight)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Colors.black),
                                    ))),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onPressed: () {
                              if (Navigator.canPop(ctxt)) {
                                Navigator.pop(ctxt);
                              }
                            },
                          ),
                          const Spacer(),
                          TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                    Colors.black),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                    TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16.toFont,
                                    )),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(
                                        horizontal: 15.toWidth,
                                        vertical: 10.toHeight)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Colors.black),
                                    ))),
                            child: const Text(
                              "Backup",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              await BackupKeyWidget(
                                atsign: AtClientManager.getInstance()
                                    .atClient
                                    .getCurrentAtSign()!,
                              ).onBackup(ctxt);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.background,
      // extendBodyBehindAppBar: true,
      appBar: AppBarCustom(
        height: 330,
        title: "Settings",
      ),
      // extendBody: true,
      // drawerScrimColor: Colors.transparent,
      // endDrawer: SideBarWidget(
      //   isExpanded: true,
      // ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(31, 0, 31, 24),
          children: [
            SizedBox(height: 28),
            SettingsButton(
              buttonText: optionTitle[0],
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return BlockedContactScreen();
                    },
                  ),
                );
              },
              image: optionIcons[0],
            ),
            SizedBox(height: 32),
            SettingsButton(
              buttonText: optionTitle[1],
              onPressed: () async {
                await showBackupDialog(context);
              },
              image: optionIcons[1],
            ),
            SizedBox(height: 16),
            SettingsButton(
              buttonText: optionTitle[2],
              onPressed: switchAtsign,
              image: optionIcons[2],
            ),
            SizedBox(height: 16),
            SettingsButton(
              buttonText: optionTitle[3],
              onPressed: () async {
                CommonUtilityFunctions().showResetAtsignDialog();
              },
              image: optionIcons[3],
            ),
            SizedBox(height: 33),
            SettingsButton(
              buttonText: optionTitle[4],
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.FAQ_SCREEN,
                );
              },
              image: optionIcons[4],
            ),
            SizedBox(height: 16),
            SettingsButton(
              buttonText: optionTitle[5],
              onPressed: () async {
                await launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: 'atmospherepro@atsign.com',
                  ),
                );
              },
              image: optionIcons[5],
            ),
            SizedBox(height: 16),
            SettingsButton(
              buttonText: optionTitle[6],
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.WEBSITE_SCREEN,
                  arguments: {
                    'title': optionTitle[6],
                    'url': MixedConstants.PRIVACY_POLICY
                  },
                );
              },
              image: optionIcons[6],
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              'App Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
              style: CustomTextStyles.black12.copyWith(
                color: ColorConstants.oldSliver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
