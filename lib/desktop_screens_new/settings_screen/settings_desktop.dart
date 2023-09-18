import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/widgets/desktop_settings_card.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreenDesktop extends StatefulWidget {
  const SettingsScreenDesktop({Key? key}) : super(key: key);

  @override
  State<SettingsScreenDesktop> createState() => _SettingsScreenDesktopState();
}

class _SettingsScreenDesktopState extends State<SettingsScreenDesktop> {
  bool enableShareStSign = false;
  final KeyChainManager _keyChainManager = KeyChainManager.getInstance();

  @override
  void initState() {
    super.initState();
    getShareAtSign();
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
      color: ColorConstants.fadedBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 12.toFont,
              fontWeight: FontWeight.bold,
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
              padding: EdgeInsets.all(50),
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
                        child: InkWell(
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
