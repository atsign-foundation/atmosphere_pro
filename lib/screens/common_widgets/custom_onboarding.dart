import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/loading_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/switch_atsign_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String atSign,
      atClientPrefernce,
      Function showLoader,
      bool isInit = false,
      Function onError}) async {
    await Onboarding(
      atsign: atSign,
      context: NavService.navKey.currentContext,
      atClientPreference: atClientPrefernce,
      domain: MixedConstants.ROOT_DOMAIN,
      appColor: Color.fromARGB(255, 240, 94, 62),
      appAPIKey: MixedConstants.ONBOARD_API_KEY,
      rootEnvironment: RootEnvironment.Production,
      onboard: (value, atsign) async {
        await KeychainUtil.makeAtSignPrimary(atsign);

        await AtClientManager.getInstance().setCurrentAtSign(
            atsign, MixedConstants.appNamespace, atClientPrefernce);
        BackendService.getInstance().syncWithSecondary();

        if (!isInit) {
          await DesktopSetupRoutes.nested_pop();
        }

        if (showLoader != null) {
          LoadingDialog().showTextLoader('Initialising for $atsign');
        }

        await _backendService.startMonitor(atsign: atsign, value: value);
        _backendService.initBackendService();
        await initServices();
        getTransferData();

        if (showLoader != null) {
          showLoader(false, '');
          LoadingDialog().hide();
        }

        if (isInit) {
          await Navigator.pushReplacementNamed(
            NavService.navKey.currentContext,
            DesktopRoutes.DESKTOP_WELCOME,
          );
        }

        if (!isInit) {
          // if it is not init then we re-render the welcome screen
          Provider.of<SwitchAtsignProvider>(NavService.navKey.currentContext,
                  listen: false)
              .update();
        }
      },
      onError: (error) {
        print('Onboarding throws error: $error ');
        if (onError != null) {
          onError();
        }
      },
    );
  }

  static initServices() async {
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  static getTransferData() async {
    HistoryProvider historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext,
        listen: false);
    historyProvider.resetData();
    await historyProvider.getSentHistory();
    await historyProvider.getReceivedHistory();

    await Provider.of<FileDownloadChecker>(NavService.navKey.currentContext,
            listen: false)
        .checkForUndownloadedFiles();
  }
}
