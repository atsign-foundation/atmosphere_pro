import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:flutter/material.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String atSign, atClientPrefernce, Function showLoader}) async {
    await Onboarding(
      atsign: atSign,
      context: NavService.navKey.currentContext,
      atClientPreference: atClientPrefernce,
      domain: MixedConstants.ROOT_DOMAIN,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (value, atsign) async {
        print('value $value');
        print('atsign $atsign');

        if (showLoader != null) {
          showLoader(true);
        }
        _backendService.atClientServiceMap = value;

        // await _backendService.atClientServiceMap[atsign]
        //     .makeAtSignPrimary(atsign);
        await _backendService.startMonitor(atsign: atsign, value: value);
        _backendService.initBackendService();
        await ContactProvider().initContactImpl();
        if (showLoader != null) {
          showLoader(false);
        }
        // await Navigator.pushNamedAndRemoveUntil(
        //     NavService.navKey.currentContext,
        //     Routes.WELCOME_SCREEN,
        //     (Route<dynamic> route) => false);
      },
      onError: (error) {
        print('Onboarding throws $error error');
      },
    );
  }
}
