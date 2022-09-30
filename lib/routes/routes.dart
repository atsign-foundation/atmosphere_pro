import 'package:at_contacts_flutter/screens/blocked_screen.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/screens/list/group_list.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/contacts/contacts_screen.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/home/home.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/trusted_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => Home(),
      Routes.WEBSITE_SCREEN: (context) {
        Map<String, dynamic> args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return WebsiteScreen(title: args["title"], url: args["url"]);
      },
      Routes.WELCOME_SCREEN: (context) => WelcomeScreen(),
      Routes.FAQ_SCREEN: (context) => WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          ),
      Routes.MY_FILES: (context) => MyFiles(),
      Routes.HISTORY: (context) => HistoryScreen(tabIndex: 1),
      Routes.BLOCKED_USERS: (context) => BlockedScreen(),
      Routes.CONTACT_SCREEN: (context) {
        return ContactsScreen();
        //   Map<String, dynamic> args =
        //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        //   return GroupContactView(
        //     asSelectionScreen: args['asSelectionScreen'],
        //     singleSelection: args['singleSelection'],
        //     showGroups: args['showGroups'],
        //     showContacts: args['showContacts'],
        //     selectedList: args['selectedList'],
        //     contactSelectedHistory: args['showSelectedData'],
        //   );
      },
      Routes.GROUPS: (context) {
        Map<String, dynamic>? args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return GroupList();
      },
      Routes.TRUSTED_CONTACTS: (context) => TrustedContacts(),
    };
  }
}
