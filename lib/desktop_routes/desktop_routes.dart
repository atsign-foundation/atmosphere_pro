import 'package:at_contacts_flutter/desktop_screens/desktop_contacts_screen.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_routes.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_group_initial_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_download_all_files/desktop_download_all_file.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/desktop_history.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_home/desktop_home.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/desktop_my_files.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/trusted_sender/desktop_empty_trusted_sender.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/trusted_sender/desktop_trusted_sender.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/desktop_welcome_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/widgets/welcome_screen_home.dart';
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
      DesktopRoutes.DESKTOP_WELCOME: (context) => DesktopWelcomeScreenStart(),
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
          WelcomeScreenHome(),
      DesktopRoutes.DESKTOP_HISTORY: (context) =>
          DesktopHistoryScreen(tabIndex: 1),
      DesktopRoutes.DEKSTOP_MYFILES: (context) => DesktopMyFiles(),
      DesktopRoutes.DEKSTOP_CONTACTS_SCREEN: (context) {
        return DesktopContactsScreen(
          () {
            DesktopSetupRoutes.nested_pop();
          },
          showBackButton: false,
        );
      },
      DesktopRoutes.DESKTOP_DOWNLOAD_ALL: (context) {
        return DesktopDownloadAllFiles();
      },
      DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN: (context) {
        Map<String, dynamic> args =
            routeSettings.arguments as Map<String, dynamic>;
        return DesktopContactsScreen(
          () {
            DesktopSetupRoutes.nested_pop();
          },
          isBlockedScreen: args['isBlockedScreen'],
          showBackButton: false,
        );
      },
      DesktopRoutes.DESKTOP_TRUSTED_SENDER: (context) => DesktopTrustedSender(),
      DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER: (context) =>
          DesktopEmptySender(),
      DesktopRoutes.DESKTOP_GROUP: (context) {
        // Map<String, dynamic>? args =
        //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        DesktopGroupSetupRoutes.setExitFunction(() {
          DesktopSetupRoutes.nested_pop();
        });
        return DesktopGroupInitialScreen(showBackButton: false);
      },
      // =>  DesktopEmptyGroup(),

      DesktopRoutes.DESKT_FAQ: (context) => WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          )
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
