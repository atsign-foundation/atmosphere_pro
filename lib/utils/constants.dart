import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MixedConstants {
  // static const String WEBSITE_URL = 'https://staging.atsign.wtf/';
  static const String WEBSITE_URL = 'https://atsign.com/';

  // for local server
  // static const String ROOT_DOMAIN = 'vip.ve.atsign.zone';

  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  static const String ROOT_DOMAIN = 'root.atsign.org';

  static const int ROOT_PORT = 64;

  static const String TERMS_CONDITIONS = 'https://atsign.com/terms-conditions/';

  static const String FILEBIN_URL = 'https://filebin2.aws.atsign.cloud/';
  // static const String PRIVACY_POLICY = 'https://atsign.com/privacy-policy/';
  static const String PRIVACY_POLICY =
      "https://atsign.com/apps/atmosphere/atmosphere-privacy/";
  static const String FAQ = "https://atsign.com/faqs/";

  static const MACOS_STORE_LINK = 'https://apps.apple.com/app/id1550936444';

  static const WINDOWS_STORE_LINK =
      'https://www.microsoft.com/en-in/p/mospherepro/9nk4dhfxdnm1?cid=msft_web_chart&activetab=pivot:overviewtab';

  static const RELEASE_TAG_API =
      'https://atsign-foundation.github.io/atmosphere-pro/version.html';

  static const LINUX_STORE_LINK = 'https://atsign.com/apps/';

  // the time to await for file transfer acknowledgement in milliseconds
  static const int TIME_OUT = 60000;

  // Hive Constants
  static const String HISTORY_KEY = 'historyKey';
  static const String HISTORY_BOX = 'historyBox';

  static String appNamespace = 'mospherepro';
  static String regex =
      '(.$appNamespace|atconnections|[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})';

  static const String AUTO_ACCEPT_TOGGLE_BOX = 'autoAcceptBox';
  static const String AUTO_ACCEPT_TOGGLE_KEY = 'autoAcceptKey';
  static const String FILE_TRANSFER_KEY = 'file_transfer_';
  static const String FILE_TRANSFER_ACKNOWLEDGEMENT = 'file_download_ack_';
  static const String RECEIVED_FILE_HISTORY = 'receivedHistory_v2';
  static const String SENT_FILE_HISTORY = 'sentHistory_v2';

  /// Currently set to 60 days
  static const int FILE_TRANSFER_TTL = 60000 * 60 * 24 * 60;

  static String? ApplicationDocumentsDirectory = '';

  /// Sibebar width
  static double SIDEBAR_WIDTH = 70;

  /// Appbar height
  static const double APPBAR_HEIGHT = 80;

  /// we change the directory after successful login
  static setNewApplicationDocumentsDirectory(String? _atsign) async {
    late var _dir;
    if (Platform.isMacOS || Platform.isWindows) {
      _dir = await getApplicationDocumentsDirectory();
    }
    final path = Directory(_dir.path +
        Platform.pathSeparator +
        '@mosphere-pro' +
        Platform.pathSeparator +
        (_atsign ?? ''));

    /// we create directory if it does not exist
    if (!(await path.exists())) {
      await path.create();
    }

    ApplicationDocumentsDirectory = path.path;
  }

  static String get RECEIVED_FILE_DIRECTORY {
    return '$ApplicationDocumentsDirectory';
  }

  // temp
  // static String path = '/Users/apple/Desktop/';
  // static String path = '/Users/apple/temp_atmosphere/';

  static String DESKTOP_SENT_DIR = (ApplicationDocumentsDirectory ?? '') +
      Platform.pathSeparator +
      'sent-files' +
      Platform.pathSeparator;

  static String get SENT_FILE_DIRECTORY =>
      (ApplicationDocumentsDirectory ?? '') +
      Platform.pathSeparator +
      'sent-files' +
      Platform.pathSeparator;

  // Onboarding API key - requires different key for production
  static String ONBOARD_API_KEY = '477b-876u-bcez-c42z-6a3d';
}
