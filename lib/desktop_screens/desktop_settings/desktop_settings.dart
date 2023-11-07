import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/settings/widgets/settings_buttons.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopSettings extends StatefulWidget {
  const DesktopSettings({Key? key}) : super(key: key);

  @override
  State<DesktopSettings> createState() => _DesktopSettingsState();
}

class _DesktopSettingsState extends State<DesktopSettings> {
  final List<String> optionTitle = [
    TextStrings().switchatSign,
    TextStrings().backUpKeys,
    TextStrings().faqs,
    TextStrings().contactUs,
    TextStrings().termsAppBar,
    TextStrings().deleteAtsigns,
  ];

  final List<String> optionIcons = [
    ImageConstants.switchAtSign,
    ImageConstants.backupKeys,
    ImageConstants.faqs,
    ImageConstants.contactUsLogo,
    ImageConstants.termsAndConditions,
    ImageConstants.deleteAtsigns,
  ];

  void switchAtsign() async {
    var atSignList = await KeychainUtil.getAtsignList();
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.transparent,
      builder: (context) => AtSignBottomSheet(
        atSignList: atSignList,
      ),
    );
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.backgroundDesktop,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                DesktopHeader(
                  title: TextStrings().sidebarSettings,
                  showBackIcon: false,
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        'App Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
                        style: CustomTextStyles.black12,
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      SettingsButton(
                        buttonText: optionTitle[0],
                        onPressed: switchAtsign,
                        image: optionIcons[0],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SettingsButton(
                        buttonText: optionTitle[1],
                        onPressed: () async {
                          BackupKeyWidget(
                            atsign: AtClientManager.getInstance()
                                .atClient
                                .getCurrentAtSign()!,
                          ).showBackupDialog(context);
                        },
                        image: optionIcons[1],
                      ),
                      const Divider(
                        height: 58,
                        color: ColorConstants.dividerGrey,
                      ),
                      SettingsButton(
                        buttonText: optionTitle[3],
                        onPressed: () async {
                          await launchUrl(Uri(
                              scheme: 'mailto',
                              path: 'atmospherepro@atsign.com'));
                        },
                        image: optionIcons[3],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      SettingsButton(
                        buttonText: optionTitle[5],
                        onPressed: () async {
                          CommonUtilityFunctions().showResetAtsignDialog();
                        },
                        image: optionIcons[5],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}