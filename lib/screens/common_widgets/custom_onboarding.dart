import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/loading_widget.dart';
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
      {String atSign,
      atClientPrefernce,
      Function showLoader,
      bool isInit = false}) async {
    await Onboarding(
      atsign: atSign,
      context: NavService.navKey.currentContext,
      atClientPreference: atClientPrefernce,
      domain: MixedConstants.ROOT_DOMAIN,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (value, atsign) async {
        print('value $value');
        print('atsign $atsign');
        if (!isInit) {
          Navigator.pop(NavService.navKey.currentContext);
          await DesktopSetupRoutes.nested_pop();
        }

        if (showLoader != null) {
          // showLoader(true, atsign);
          LoadingDialog().showTextLoader('Initialising for $atsign');
        }

        await _backendService.startMonitor(atsign: atsign, value: value);
        print('monitor started from custom onboard');
        _backendService.initBackendService();
        await ContactProvider().initContactImpl();
        await initServices();
        await getTransferData();
        await initGroups();

        if (showLoader != null) {
          showLoader(false, '');
          LoadingDialog().hide();
        }

        await Navigator.pushNamed(
          NavService.navKey.currentContext,
          DesktopRoutes.DESKTOP_WELCOME,
        );
      },
      onError: (error) {
        print('Onboarding throws $error error');
      },
    );
  }

  static initServices() async {
    // initializeContactsService(
    //     rootDomain: MixedConstants.ROOT_DOMAIN);

    await ContactService().initContactsService(MixedConstants.ROOT_DOMAIN, 64);
  }

  static initGroups() async {
    // await GroupService().init(await BackendService.getInstance().getAtSign());
    await GroupService()
        .init(MixedConstants.ROOT_DOMAIN, MixedConstants.ROOT_PORT);
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
