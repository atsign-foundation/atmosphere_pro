import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/blocked_users/blocked_users.dart';
import 'package:atsign_atmosphere_app/screens/contact/add_contact.dart';
import 'package:atsign_atmosphere_app/screens/contact/contact.dart';
import 'package:atsign_atmosphere_app/screens/faqs/faqs.dart';
import 'package:atsign_atmosphere_app/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_app/screens/home/home.dart';
import 'package:atsign_atmosphere_app/screens/scan_qr/get_now.dart';
import 'package:atsign_atmosphere_app/screens/scan_qr/scan_qr.dart';
import 'package:atsign_atmosphere_app/screens/terms_conditions/terms_conditions_screen.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => Home(),
      Routes.Get_Now: (context) => GetNow(),
      Routes.WELCOME_SCREEN: (context) => WelcomeScreen(),
      Routes.FAQ_SCREEN: (context) => FaqsScreen(),
      Routes.TERMS_CONDITIONS: (context) => TermsConditions(),
      Routes.HISTORY: (context) => HistoryScreen(),
      Routes.BLOCKED_USERS: (context) {
        Map<String, List<dynamic>> args =
            ModalRoute.of(context).settings.arguments as Map<String, List<dynamic>>;
        print("ARGUMENTS $args");
        return BlockedUsers(
          blockedUserList: args['blockedUserList'],
        );
      },
      Routes.CONTACT_SCREEN: (context) => ContactScreen(),
      Routes.ADD_CONTACT_SCREEN: (context) => AddContactScreen(),
      Routes.SCAN_QR_SCREEN: (context) => ScanQrScreen(),
    };
  }
}
