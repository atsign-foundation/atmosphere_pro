import 'dart:io';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:intl/intl.dart';
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

  static const String TERMS_CONDITIONS = 'atsign.com/terms-conditions/';

  static const String FILEBIN_URL = 'https://ck6agzxiog6kmb.atsign.com/';

  // static const String PRIVACY_POLICY = 'https://atsign.com/privacy-policy/';
  static const String PRIVACY_POLICY =
      "https://atsign.com/apps/atmosphere/atmosphere-privacy/";
  static const String FAQ = "atsign.com/faqs/";

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
  static const String MY_FILES_KEY = 'my_files_';
  static const String FILE_TRANSFER_ACKNOWLEDGEMENT = 'file_download_ack_';
  static const String RECEIVED_FILE_HISTORY = 'receivedHistory_v2';
  static const String SENT_FILE_HISTORY = 'sentHistory_v2';

  /// Currently set to 60 days
  static const int FILE_TRANSFER_TTL = 60000 * 60 * 24 * 60;

  static String? ApplicationDocumentsDirectory = '';

  /// Sibebar width
  static double SIDEBAR_WIDTH_COLLAPSED = 148;
  static double SIDEBAR_WIDTH_EXPANDED = 280;

  /// Appbar height
  static const double APPBAR_HEIGHT = 80;

  ///Date labels
  static const List<String> DATE_LABELS = [
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
    'This Year',
    'Last Year'
  ];

  /// we change the directory after successful login
  static setNewApplicationDocumentsDirectory(String? _atsign) async {
    late var _dir;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
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

  ///returns file download location
  ///creates the directory if does not exists one
  static Future<String> getFileDownloadLocation({String? sharedBy}) async {
    String _downloadPath = '';
    if (Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux && sharedBy != null) {
      _downloadPath = (MixedConstants.ApplicationDocumentsDirectory ?? '') +
          Platform.pathSeparator +
          sharedBy!;
      await BackendService.getInstance()
          .doesDirectoryExist(path: _downloadPath);
      return _downloadPath;
    } else {
      return BackendService.getInstance().atClientPreference.downloadPath!;
    }
  }

  /// returns file download location
  /// does not create the directory if does not exists
  static String getFileDownloadLocationSync({String? sharedBy}) {
    String _downloadPath = '';
    if (Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux && sharedBy != null) {
      _downloadPath = (MixedConstants.ApplicationDocumentsDirectory ?? '') +
          Platform.pathSeparator +
          (sharedBy ?? '');

      return _downloadPath;
    } else {
      return BackendService.getInstance().atClientPreference.downloadPath!;
    }
  }

  /// returns sent-file location, creates one if does not exists
  static Future<String> getFileSentLocation() async {
    String _sentPath = '';
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      _sentPath = (MixedConstants.ApplicationDocumentsDirectory ?? '') +
          Platform.pathSeparator +
          'sent-files';
      await BackendService.getInstance().doesDirectoryExist(path: _sentPath);
      return _sentPath;
    } else {
      return BackendService.getInstance().atClientPreference.downloadPath!;
    }
  }

  /// returns sent-file location, creates one if does not exists
  /// does not create the directory if does not exists
  static String getFileSentLocationSync() {
    String _sentPath = '';
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      _sentPath = (MixedConstants.ApplicationDocumentsDirectory ?? '') +
          Platform.pathSeparator +
          'sent-files';
      return _sentPath;
    } else {
      return BackendService.getInstance().atClientPreference.downloadPath!;
    }
  }

  ///Return true, if date is yesterday
  static bool isToday(DateTime targetDate) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    String formattedDate = dateFormat.format(targetDate);
    String formattedToday = dateFormat.format(DateTime.now());
    return formattedDate == formattedToday;
  }

  ///Return true, if date is yesterday
  static bool isYesterday(DateTime targetDate) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    String formattedDate = dateFormat.format(targetDate);
    String formattedYesterday =
        dateFormat.format(DateTime.now().subtract(Duration(days: 1)));
    return formattedDate == formattedYesterday;
  }

  ///Return true, if date is in this week
  static bool isThisWeek(DateTime targetDate) {
    DateTime currentDate = DateTime.now();

    DateTime startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    return targetDate.isAfter(startOfWeek) && targetDate.isBefore(endOfWeek);
  }

  ///Return true, if date is in the last week
  static bool isLastWeek(DateTime targetDate) {
    DateTime currentDate = DateTime.now().subtract(Duration(days: 7));

    DateTime startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    return targetDate.isAfter(startOfWeek) && targetDate.isBefore(endOfWeek);
  }

  ///Return true, if date is in last month
  static bool isLastMonth(DateTime targetDate) {
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1);

    DateFormat dateFormat = DateFormat('yyyy-MM');

    String formattedDate = dateFormat.format(targetDate);
    String formattedLastMonth = dateFormat.format(lastMonth);

    return formattedDate == formattedLastMonth;
  }

  ///Return true, if date is in last month
  static bool isLastYear(DateTime targetDate) {
    DateTime now = DateTime.now();
    DateTime lastYear = DateTime(now.year - 1);

    DateFormat dateFormat = DateFormat('yyyy');

    String formattedDate = dateFormat.format(targetDate);
    String formattedLastYear = dateFormat.format(lastYear);

    return formattedDate == formattedLastYear;
  }
}
