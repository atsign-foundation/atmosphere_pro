import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_download_all_files/desktop_download_all_file.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_home/desktop_home.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/trusted_sender/desktop_empty_trusted_sender.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/desktop_contact_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/desktop_add_or_remove_contacts_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/desktop_groups_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/blocked_contacts.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/settings_screen/settings_desktop.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/desktop_myfiles.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/widgets/category_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/history_desktop.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/trusted_senders_screen/desktop_trusted.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/file_transfer_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/desktop_home_screen.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/website_webview.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';

class DesktopSetupRoutes {
  static String initialRoute = DesktopRoutes.DESKTOP_HOME;

  // static String initialRoute = DesktopRoutes.DESKTOP_WELCOME;
  static var _provider = Provider.of<NestedRouteProvider>(
      NavService.navKey.currentContext!,
      listen: false);

  static Map<String, WidgetBuilder> get routes {
    return {
      DesktopRoutes.DESKTOP_HOME: (context) => DesktopHome(),
      DesktopRoutes.DESKTOP_WELCOME: (context) => HomeScreenDesktop(),
    };
  }

  // // ignore: missing_return
  // static MaterialPageRoute<dynamic> nested_routes(name) {
  //   switch (name) {
  //     case DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL:
  //       return MaterialPageRoute(builder: (context) => DesktopWelcomeScreen());
  //     case DesktopRoutes.DESKTOP_HISTORY:
  //       return MaterialPageRoute(builder: (context) => DesktopHistoryScreen());
  //   }
  // }

  static Map<String, WidgetBuilder> routeBuilders(
      BuildContext context, RouteSettings routeSettings) {
    return {
      DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL: (context) =>
          FileTransferScreen(),
      DesktopRoutes.DEKSTOP_MYFILES: (context) => MyFilesDesktop(),
      DesktopRoutes.DESKTOP_CATEGORY_FILES: (context) {
        Map<String, dynamic> args =
            routeSettings.arguments as Map<String, dynamic>;

        return CategoryScreen(fileType: args['fileType']);
      },
      DesktopRoutes.DESKTOP_HISTORY: (context) {
        var arg = routeSettings.arguments;
        Map<String, dynamic>? args;
        if (arg != null) {
          args = routeSettings.arguments as Map<String, dynamic>;
        }

        return HistoryDesktopScreen(
            historyType: args?['historyType'] ?? HistoryType.received);
      },
      DesktopRoutes.DEKSTOP_CONTACTS_SCREEN: (context) {
        return DesktopContactScreen();
      },
      DesktopRoutes.DESKTOP_ADD_OR_REMOVE_CONTACTS: (context) {
        return DesktopAddOrRemoveContactsScreen();
      },
      DesktopRoutes.DESKTOP_DOWNLOAD_ALL: (context) {
        return DesktopDownloadAllFiles();
      },
      DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN: (context) {
        return DesktopBlockedContacts();
      },
      DesktopRoutes.DESKTOP_SETTINGS: (context) => SettingsScreenDesktop(),
      DesktopRoutes.DESKTOP_TRUSTED_SENDER: (context) => DesktopTrustedScreen(),
      DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER: (context) =>
          DesktopEmptySender(),
      DesktopRoutes.DESKTOP_GROUP: (context) => DesktopGroupsScreen(),
      // =>  DesktopEmptyGroup(),

      DesktopRoutes.DESKT_FAQ: (context) => WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          ),
    };
  }

  static Future nested_push(String? value,
      {Object? arguments, Function? callbackAfterNavigation}) async {
    GroupService().clearSelectedGroupContacts(
        context: NavService.nestedNavKey.currentContext!,
        onYesTap: () {
          if (_provider.current_route != null) {
            var _res = nested_push_replacement(value!, arguments: arguments);
            return _res;
          }
          _provider.update(value);
          return Navigator.of(NavService.nestedNavKey.currentContext!)
              .pushNamed(value!, arguments: arguments)
              .then((response) {
            if (callbackAfterNavigation != null) {
              callbackAfterNavigation();
            }
          });
        });
  }

  static Future nested_push_replacement(String value,
      {Object? arguments, Function? callbackAfterNavigation}) async {
    GroupService().clearSelectedGroupContacts(
        context: NavService.nestedNavKey.currentContext!,
        onYesTap: () {
          _provider.update(value);
          return Navigator.of(NavService.nestedNavKey.currentContext!)
              .pushReplacementNamed(value, arguments: arguments)
              .then((response) {
            if (callbackAfterNavigation != null) {
              callbackAfterNavigation();
            }
          });
        });
  }

  static Future nested_pop({bool checkGroupSelection = true}) async {
    if (checkGroupSelection) {
      GroupService().clearSelectedGroupContacts(
          context: NavService.nestedNavKey.currentContext!,
          onYesTap: () async {
            await _nested_pop();
          });
    } else {
      await _nested_pop();
    }
  }

  static Future _nested_pop() async {
    _provider.update(null);

    if ((NavService.nestedNavKey.currentState != null) &&
        (Navigator.canPop(NavService.nestedNavKey.currentContext!))) {
      Navigator.of(NavService.nestedNavKey.currentContext!).pop();
    }
  }
}

class NestedRouteProvider extends BaseModel {
  String Routes = 'routes';

  NestedRouteProvider();

  String? current_route;

  init() {
    setStatus(Routes, Status.Done);
  }

  update(String? value) {
    current_route = value;
    setStatus(Routes, Status.Done);
  }
}
