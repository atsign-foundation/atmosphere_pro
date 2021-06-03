import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/desktop_welcome_screen.dart';
import 'package:flutter/material.dart';

class DesktopSetupRoutes {
  static String initialRoute = DesktopRoutes.DESKTOP_HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      DesktopRoutes.DESKTOP_HOME: (context) => DesktopWelcomeScreen(),
    };
  }
}
