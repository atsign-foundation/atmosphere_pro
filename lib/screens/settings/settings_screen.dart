import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar_custom.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/switch_at_sign.dart';
import 'package:atsign_atmosphere_pro/screens/settings/widgets/settings_buttons.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBarCustom(
              height: 330,
              title: "Settings",
            ),
      /*CustomAppBar(
              showMenu: false,
              showBackButton: true,
              showLeadingicon: true,
              showTrailingButton: false,
              showTitle: true,
              showClosedBtnText: false,
              title: 'Settings',
            ),*/
      extendBody: true,
      drawerScrimColor: Colors.transparent,
      endDrawer: SideBarWidget(
        isExpanded: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(31, 0, 31, 24),
              children: [
                Text(
                  'App Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
                  style: CustomTextStyles.black12,
                ),
                SizedBox(
                  height: 28,
                ),
                SettingsButton(
                  buttonText: optionTitle[0],
                  onPressed: switchAtsign,
                  image: optionIcons[0],
                ),
                SizedBox(height: 20),
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
                Divider(
                  height: 58,
                  color: ColorConstants.dividerGrey,
                ),
                SettingsButton(
                  buttonText: optionTitle[2],
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.FAQ_SCREEN,
                    );
                  },
                  image: optionIcons[2],
                ),
                SizedBox(height: 20),
                SettingsButton(
                  buttonText: optionTitle[3],
                  onPressed: () async {
                    await launchUrl(Uri(
                        scheme: 'mailto', path: 'atmospherepro@atsign.com'));
                  },
                  image: optionIcons[3],
                ),
                SizedBox(height: 20),
                SettingsButton(
                  buttonText: optionTitle[4],
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.WEBSITE_SCREEN,
                      arguments: {
                        'title': optionTitle[4],
                        'url': MixedConstants.PRIVACY_POLICY
                      },
                    );
                  },
                  image: optionIcons[4],
                ),
                SizedBox(height: 20),
                SettingsButton(
                  buttonText: optionTitle[5],
                  onPressed: () async {
                    CommonUtilityFunctions().showResetAtsignDialog();
                  },
                  image: optionIcons[5],
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
