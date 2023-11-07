import 'package:at_contacts_flutter/screens/blocked_screen.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/screens/list/group_list.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/history/transfer_history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/home/home.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files_screen.dart';
import 'package:atsign_atmosphere_pro/screens/settings/settings_screen.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/trusted_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => const Home(),
      Routes.WEBSITE_SCREEN: (context) {
        Map<String, dynamic> args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return WebsiteScreen(title: args["title"], url: args["url"]);
      },
      Routes.WELCOME_SCREEN: (context) {
        Map<String, dynamic> args =
            (ModalRoute.of(context)!.settings.arguments ?? <String, dynamic>{})
                as Map<String, dynamic>;

        return WelcomeScreen(
          indexBottomBarSelected: args['indexBottomBarSelected'],
        );
      },
      Routes.FAQ_SCREEN: (context) => const WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          ),
      Routes.MY_FILES: (context) => const MyFiles(),
      Routes.MY_FILES_SCREEN: (context) => const MyFilesScreen(),
      Routes.HISTORY: (context) => const HistoryScreen(tabIndex: 1),
      Routes.HISTORY_SCREEN: (context) => const TransferHistoryScreen(),
      Routes.BLOCKED_USERS: (context) => const BlockedScreen(),
      Routes.CONTACT_SCREEN: (context) {
        Map<String, dynamic> args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return GroupContactView(
          asSelectionScreen: args['asSelectionScreen'],
          singleSelection: args['singleSelection'],
          showGroups: args['showGroups'],
          showContacts: args['showContacts'],
          selectedList: args['selectedList'],
          contactSelectedHistory: args['showSelectedData'],
        );
      },
      Routes.GROUPS: (context) {
        return const GroupList();
      },
      Routes.TRUSTED_CONTACTS: (context) => const TrustedContacts(),
      Routes.SETTINGS: (context) => const SettingsScreen()
    };
  }
}
