import 'package:at_contacts_flutter/screens/blocked_screen.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/screens/list/group_list.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/file_picker/file_picker.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/home/home.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files.dart';
import 'package:atsign_atmosphere_pro/screens/private_key_qrcode_generator.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/trusted_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
// import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';
import 'package:flutter/material.dart';
import '../screens/terms_conditions/terms_conditions_screen.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => Home(),
      Routes.WEBSITE_SCREEN: (context) {
        Map<String, dynamic> args =
            ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
        return WebsiteScreen(title: args["title"], url: args["url"]);
      },
      Routes.WELCOME_SCREEN: (context) => WelcomeScreen(),
      Routes.FAQ_SCREEN: (context) => WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          ),
      Routes.TERMS_CONDITIONS: (context) => TermsConditions(),
      Routes.MY_FILES: (context) => MyFiles(),
      Routes.HISTORY: (context) => HistoryScreen(),
      Routes.BLOCKED_USERS: (context) => BlockedScreen(),
      Routes.CONTACT_SCREEN: (context) {
        Map<String, dynamic> args =
            ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
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
        Map<String, dynamic> args =
            ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
        return GroupList();
      },
      Routes.FILE_PICKER: (context) => FilePickerScreen(),
      // Routes.SCAN_QR_SCREEN: (context) {
      //   Map<String, dynamic> args =
      //       ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      //   return ScanQrScreen(
      //     atClientPreference: args['atClientPreference'],
      //     atClientServiceInstance: args['atClientServiceInstance'],
      //     nextScreen: args['nextScreen'],
      //   );
      // },
      Routes.PRIVATE_KEY_GEN_SCREEN: (context) => PrivateKeyQRCodeGenScreen(),
      Routes.TRUSTED_CONTACTS: (context) => TrustedContacts(),
    };
  }
}
