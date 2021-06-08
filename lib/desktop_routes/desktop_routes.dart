import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/desktop_history.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/desktop_welcome_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/widgets/welcome_screen_home.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';

class DesktopSetupRoutes {
  static String initialRoute = DesktopRoutes.DESKTOP_HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      DesktopRoutes.DESKTOP_HOME: (context) => DesktopWelcomeScreenStart(),
    };
  }

  // ignore: missing_return
  static MaterialPageRoute<dynamic> nested_routes(name) {
    switch (name) {
      case DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL:
        return MaterialPageRoute(builder: (context) => DesktopWelcomeScreen());
      case DesktopRoutes.DESKTOP_HISTORY:
        return MaterialPageRoute(builder: (context) => DesktopHistoryScreen());
    }
  }

  static Map<String, WidgetBuilder> routeBuilders(BuildContext context) {
    return {
      DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL: (context) => WelcomeScreenHome(),
      DesktopRoutes.DESKTOP_HISTORY: (context) => DesktopHistoryScreen(),
    };
  }

  static Future nested_push(String value,
      {Object arguments, Function callbackAfterNavigation}) {
    return Navigator.of(NavService.nestedNavKey.currentContext)
        .pushNamed(value, arguments: arguments)
        .then((response) {
      if (callbackAfterNavigation != null) {
        callbackAfterNavigation();
      }
    });
  }
}
