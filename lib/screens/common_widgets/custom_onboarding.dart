import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        await initServices();
        await getTransferData();

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

  static initServices() {
    initializeContactsService(BackendService.getInstance().atClientInstance,
        BackendService.getInstance().atClientInstance.currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);

    initGroups();
  }

  static initGroups() async {
    // await GroupService().init(await BackendService.getInstance().getAtSign());
    await GroupService().init(
        BackendService.getInstance().atClientInstance,
        BackendService.getInstance().currentAtSign,
        MixedConstants.ROOT_DOMAIN,
        MixedConstants.ROOT_PORT);
    await GroupService().fetchGroupsAndContacts();

    print('group init done');
  }

  static getTransferData() async {
    HistoryProvider historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext,
        listen: false);
    await historyProvider.getSentHistory();
    await historyProvider.getReceivedHistory();
  }
}
