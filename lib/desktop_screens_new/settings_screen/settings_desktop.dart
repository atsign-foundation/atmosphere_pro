import 'dart:io';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/widgets/desktop_settings_card.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/widgets/desktop_tooltip.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreenDesktop extends StatefulWidget {
  const SettingsScreenDesktop({Key? key}) : super(key: key);

  @override
  State<SettingsScreenDesktop> createState() => _SettingsScreenDesktopState();
}

class _SettingsScreenDesktopState extends State<SettingsScreenDesktop> {
  bool enableShareStSign = false;
  final backupTooltipController = JustTheController();
  final KeyChainManager _keyChainManager = KeyChainManager.getInstance();

  @override
  void initState() {
    super.initState();
    getShareAtSign();
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

  void getShareAtSign() async {
    enableShareStSign = await _keyChainManager.isUsingSharedStorage() ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.all(40),
      height: SizeConfig().screenHeight,
      color: ColorConstants.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            thickness: 1,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),

          //body

          FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.fromLTRB(52, 52, 52, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await DesktopSetupRoutes.nested_push(
                                DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN);
                          },
                          child: DesktopSettingsCard(
                            title: TextStrings().blockedAtSign,
                            subtitle: TextStrings().blockedAtSignSubtitle,
                            vectorIcon: AppVectors.icSettingBlock,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                await BackupKeyWidget(
                                  atsign: AtClientManager.getInstance()
                                      .atClient
                                      .getCurrentAtSign()!,
                                ).showBackupDialog(context);
                              },
                              child: DesktopSettingsCard(
                                title: TextStrings().backUpKeys,
                                subtitle: TextStrings().backUpKeysSubtitle,
                                vectorIcon: AppVectors.icSettingBackup,
                              ),
                            ),
                            SizedBox(width: 16),
                            DesktopTooltip(
                              content:
                                  'Each atSign has a unique key used to verify ownership and encrypt your data. You will get this key when you first activate your atSign, and you will need it to pair your atSign with other devices and all atPlatform apps.'
                                  '\n\n'
                                  'PLEASE SECURELY SAVE YOUR KEYS. WE DO NOT HAVE ACCESS TO THEM AND CANNOT CREATE A BACKUP OR RESET THEM.',
                              controller: backupTooltipController,
                              axisDirection: AxisDirection.down,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            context
                                .read<SideBarProvider>()
                                .changeIsSwitchingAtSign();
                          },
                          child: DesktopSettingsCard(
                            title: TextStrings().switchatSign,
                            subtitle: TextStrings().switchatSignSubtitle,
                            vectorIcon: AppVectors.icSettingSwitch,
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await CommonUtilityFunctions()
                                .showResetAtsignDialog();
                          },
                          child: DesktopSettingsCard(
                            title: TextStrings().deleteAtsigns,
                            subtitle: TextStrings().deleteAtsignsSubtitle,
                            vectorIcon: AppVectors.icSettingDelete,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      DesktopSettingsCard(
                        title: 'Sharing atSign',
                        subtitle: 'Share atSign between apps',
                        vectorIcon: AppVectors.icShare,
                      ),
                      SizedBox(width: 16),
                      Switch(
                          activeColor: ColorConstants.orange,
                          value: enableShareStSign,
                          onChanged: (check) async {
                            if (check) {
                              await _keyChainManager.enableUsingSharedStorage();
                            } else {
                              await _keyChainManager
                                  .disableUsingSharedStorage();
                            }
                            setState(() {
                              enableShareStSign = check;
                            });
                          })
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'App Version ${_packageInfo.version}${Platform.isWindows ? '' : ' (${_packageInfo.buildNumber})'}',
                      style: CustomTextStyles.black12.copyWith(
                        color: ColorConstants.oldSliver,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
