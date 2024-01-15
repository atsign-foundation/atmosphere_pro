import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/loading_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/switch_atsign_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String? atSign,
      required atClientPreference,
      Function? showLoader,
      bool isInit = false,
      Function? onError}) async {
    AtOnboardingResult result;
    final OnboardingService _onboardingService =
        OnboardingService.getInstance();

    _onboardingService.setAtsign = atSign;

    result = await AtOnboarding.onboard(
        context: NavService.navKey.currentContext!,
        config: AtOnboardingConfig(
          atClientPreference: atClientPreference!,
          domain: MixedConstants.ROOT_DOMAIN,
          rootEnvironment: RootEnvironment.Production,
          appAPIKey: MixedConstants.ONBOARD_API_KEY,
        ),
        isSwitchingAtsign: !isInit,
        atsign: atSign);

    switch (result.status) {
      case AtOnboardingResultStatus.success:
        final atsign = result.atsign!;
        final OnboardingService _onboardingService =
            OnboardingService.getInstance();
        final value = _onboardingService.atClientServiceMap;
        await AtClientManager.getInstance().setCurrentAtSign(
            atsign, MixedConstants.appNamespace, atClientPreference);

        _backendService.atClientServiceInstance = value[atsign];
        _backendService.currentAtSign =
            value[atsign]!.atClientManager.atClient.getCurrentAtSign();

        BackendService.getInstance().syncWithSecondary();

        if (!isInit) {
          await DesktopSetupRoutes.nested_pop(checkGroupSelection: false);
        }

        if (showLoader != null) {
          LoadingDialog().showTextLoader('Initialising for $atsign');
        }

        _backendService.initLocalNotification();
        await initServices();
        getTransferData();
        await _backendService.startMonitor();
        // _backendService.setPeriodicFileHistoryRefresh();

        if (showLoader != null) {
          showLoader(false, '');
          LoadingDialog().hide();
        }

        if (isInit) {
          await Navigator.pushReplacementNamed(
            NavService.navKey.currentContext!,
            DesktopRoutes.DESKTOP_WELCOME,
          );
        }

        if (!isInit) {
          // if it is not init then we re-render the welcome screen
          Provider.of<SwitchAtSignProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .update();
          Provider.of<FileTransferProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .resetData();

          /// WelcomeScreenHome "currentScreen" depends on WelcomeScreenProvider , so we first change FileTransferProvider and then WelcomeScreenProvider
          Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .resetData();
        }
        break;
      case AtOnboardingResultStatus.error:
        ScaffoldMessenger.of(NavService.navKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
              (result.message ?? '').isNotEmpty
                  ? result.message!
                  : 'Error in onboarding',
            ),
            backgroundColor: ColorConstants.red,
          ),
        );
        if (onError != null) {
          onError();
        }
        break;
      case AtOnboardingResultStatus.cancel:
        break;
    }
  }

  static initServices() async {
    await initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  static getTransferData() async {
    HistoryProvider historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    var myFilesProvider = Provider.of<MyFilesProvider>(
        NavService.navKey.currentContext!,
        listen: false);

    historyProvider.resetData();
    myFilesProvider.resetData();
    await historyProvider.getReceivedHistory();
    await historyProvider.getFileDownloadedAcknowledgement();
    await historyProvider.getSentHistory();
    await myFilesProvider.init();

    await Provider.of<TrustedContactProvider>(NavService.navKey.currentContext!,
            listen: false)
        .resetData();
    await Provider.of<TrustedContactProvider>(NavService.navKey.currentContext!,
            listen: false)
        .getTrustedContact();
    await historyProvider.downloadAllTrustedSendersData();

    Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
            listen: false)
        .checkForUnDownloadedFiles();
  }
}
