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
import 'package:atsign_atmosphere_pro/view_models/switch_atsign_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String? atSign,
      required atClientPrefernce,
      Function? showLoader,
      bool isInit = false,
      Function? onError}) async {
    AtOnboardingResult result;
    if (isInit) {
      //Case: onboarding
      result = await AtOnboarding.onboard(
        context: NavService.navKey.currentContext!,
        config: AtOnboardingConfig(
          atClientPreference: atClientPrefernce!,
          domain: MixedConstants.ROOT_DOMAIN,
          rootEnvironment: RootEnvironment.Production,
          appAPIKey: MixedConstants.ONBOARD_API_KEY,
        ),
      );
    } else {
      if ((atSign ?? '').isNotEmpty) {
        //Case: switch account
        await AtOnboarding.changePrimaryAtsign(atsign: atSign!);
        result = result = await AtOnboarding.onboard(
          context: NavService.navKey.currentContext!,
          config: AtOnboardingConfig(
            atClientPreference: atClientPrefernce!,
            domain: MixedConstants.ROOT_DOMAIN,
            rootEnvironment: RootEnvironment.Production,
            appAPIKey: MixedConstants.ONBOARD_API_KEY,
          ),
        );
      } else {
        //Case: add new account
        result = await AtOnboarding.start(
          context: NavService.navKey.currentContext!,
          config: AtOnboardingConfig(
            atClientPreference: atClientPrefernce!,
            domain: MixedConstants.ROOT_DOMAIN,
            rootEnvironment: RootEnvironment.Production,
            appAPIKey: MixedConstants.ONBOARD_API_KEY,
          ),
        );
      }
    }

    switch (result.status) {
      case AtOnboardingResultStatus.success:
        final atsign = result.atsign!;
        final OnboardingService _onboardingService =
            OnboardingService.getInstance();
        final value = _onboardingService.atClientServiceMap;
        await AtClientManager.getInstance().setCurrentAtSign(
            atsign, MixedConstants.appNamespace, atClientPrefernce);

        _backendService.atClientInstance =
            value[atsign]!.atClientManager.atClient;
        _backendService.atClientServiceInstance = value[atsign];
        _backendService.atClientManager = value[atsign]!.atClientManager;
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
        _backendService.setPeriodicFileHistoryRefresh();

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
          Provider.of<SwitchAtsignProvider>(NavService.navKey.currentContext!,
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
            content: Text('Error in onboarding'),
            backgroundColor: ColorConstants.red,
          ),
        );
        if (onError != null) {
          onError();
        }
        break;
      case AtOnboardingResultStatus.cancel:
        // TODO: Handle this case.
        break;
    }
    // await Onboarding(
    //   atsign: atSign,
    //   context: NavService.navKey.currentContext!,
    //   atClientPreference: atClientPrefernce,
    //   domain: MixedConstants.ROOT_DOMAIN,
    //   appColor: Color.fromARGB(255, 240, 94, 62),
    //   appAPIKey: MixedConstants.ONBOARD_API_KEY,
    //   rootEnvironment: RootEnvironment.Production,
    //   onboard: (value, atsign) async {
    //     await KeychainUtil.makeAtSignPrimary(atsign!);
    //
    //     await AtClientManager.getInstance().setCurrentAtSign(
    //         atsign, MixedConstants.appNamespace, atClientPrefernce);
    //
    //     _backendService.atClientInstance =
    //         value[atsign]!.atClientManager.atClient;
    //     _backendService.atClientServiceInstance = value[atsign];
    //     _backendService.atClientManager = value[atsign]!.atClientManager;
    //     _backendService.currentAtSign =
    //         value[atsign]!.atClientManager.atClient.getCurrentAtSign();
    //
    //     BackendService.getInstance().syncWithSecondary();
    //
    //     if (!isInit) {
    //       await DesktopSetupRoutes.nested_pop(checkGroupSelection: false);
    //     }
    //
    //     if (showLoader != null) {
    //       LoadingDialog().showTextLoader('Initialising for $atsign');
    //     }
    //
    //     _backendService.initLocalNotification();
    //     await initServices();
    //     getTransferData();
    //     await _backendService.startMonitor();
    //     _backendService.setPeriodicFileHistoryRefresh();
    //
    //     if (showLoader != null) {
    //       showLoader(false, '');
    //       LoadingDialog().hide();
    //     }
    //
    //     if (isInit) {
    //       await Navigator.pushReplacementNamed(
    //         NavService.navKey.currentContext!,
    //         DesktopRoutes.DESKTOP_WELCOME,
    //       );
    //     }
    //
    //     if (!isInit) {
    //       // if it is not init then we re-render the welcome screen
    //       Provider.of<SwitchAtsignProvider>(NavService.navKey.currentContext!,
    //               listen: false)
    //           .update();
    //       Provider.of<FileTransferProvider>(NavService.navKey.currentContext!,
    //               listen: false)
    //           .resetData();
    //
    //       /// WelcomeScreenHome "currentScreen" depends on WelcomeScreenProvider , so we first change FileTransferProvider and then WelcomeScreenProvider
    //       Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
    //               listen: false)
    //           .resetData();
    //     }
    //   },
    //   onError: (error) {
    //     print('Onboarding throws error: $error ');
    //     ScaffoldMessenger.of(NavService.navKey.currentContext!).showSnackBar(
    //       SnackBar(
    //         content: Text('Error in onboarding'),
    //         backgroundColor: ColorConstants.red,
    //       ),
    //     );
    //     if (onError != null) {
    //       onError();
    //     }
    //   },
    // );
  }

  static initServices() async {
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  static getTransferData() async {
    HistoryProvider historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    historyProvider.resetData();
    await historyProvider.getReceivedHistory();
    await historyProvider.getSentHistory();

    await Provider.of<TrustedContactProvider>(NavService.navKey.currentContext!,
            listen: false)
        .getTrustedContact();
    await historyProvider.downloadAllTrustedSendersData();

    Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
            listen: false)
        .checkForUndownloadedFiles();
  }
}
