import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/data_models/version.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionService {
  VersionService._();
  static VersionService _internal = VersionService._();
  factory VersionService.getInstance() {
    return _internal;
  }

  AppVersion appVersion = AppVersion();
  late Version? version;
  late PackageInfo packageInfo;
  bool isBackwardCompatible = true, isNewVersionAvailable = false;

  init() async {
    await getVersion();
    compareVersions();
    showVersionUpgradeDialog();
  }

// setting versions in atKey
  setVersion() async {
    var version = Version(
      latestVersion: '2.1.0',
      minVersion: '1.0.1',
      buildNumber: '20',
      minBuildNumber: '18',
      isBackwardCompatible: false,
    );
    var appVersion = AppVersion(
      android: version,
      ios: version,
      macOs: version,
      windows: version,
      linux: version,
    );

    AtKey atKey = getAtKey();
    var res = await AtClientManager.getInstance().atClient.put(
          atKey,
          json.encode(appVersion.toJson()),
        );

    print('res : ${res}  : ${json.encode(appVersion.toJson())}');
  }

  getVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    print(
      'info : ${packageInfo.version}, build no: ${packageInfo.buildNumber}',
    );

    AtKey atKey = getAtKey();
    var atvalue =
        await AtClientManager.getInstance().atClient.get(atKey).catchError((e) {
      print('error in verison get : ${e}');
      return AtValue();
    });

    if (atvalue.value != null) {
      try {
        appVersion = AppVersion.fromJson(jsonDecode(atvalue.value));
      } catch (e) {
        appVersion = AppVersion();
      }
    }

    print('appVersion : ${appVersion.toJson()}');

    if (Platform.isIOS) {
      version = appVersion.ios;
    } else if (Platform.isAndroid) {
      version = appVersion.android;
    } else if (Platform.isMacOS) {
      version = appVersion.macOs;
    } else if (Platform.isWindows) {
      version = appVersion.windows;
    } else if (Platform.isLinux) {
      version = appVersion.linux;
    }
  }

  AtKey getAtKey() {
    return AtKey()
      ..key = 'app_version'
      ..metadata = Metadata()
      ..metadata!.ccd = true
      ..metadata!.isPublic = true
      ..metadata!.ttl = 172800000 // two days
      // ..sharedBy = BackendService.getInstance().currentAtSign;
      ..sharedBy = '@significantredpanda';
  }

  showVersionUpgradeDialog() async {
    if (Platform.isIOS) {
      mobileUpgradedDialog();
    } else if (Platform.isAndroid) {
      mobileUpgradedDialog();
    } else if (Platform.isMacOS) {
      desktopUpgradeDialog();
    } else if (Platform.isWindows) {
      desktopUpgradeDialog();
    } else if (Platform.isLinux) {
      desktopUpgradeDialog();
    }
  }

  desktopUpgradeDialog() {
    if (isNewVersionAvailable) {
      showDialog(
          context: NavService.navKey.currentContext!,
          barrierDismissible: isBackwardCompatible ? true : false,
          builder: (BuildContext _context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content: Container(
                width: 300.toWidth,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(
                          'You can update this app from ${packageInfo.version} to ${version!.latestVersion}')
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: desktopUpdateHandler,
                  child: Text('Update'),
                ),
                isBackwardCompatible
                    ? TextButton(
                        onPressed: () {
                          if (Navigator.of(NavService.navKey.currentContext!)
                              .canPop()) {
                            Navigator.of(NavService.navKey.currentContext!)
                                .pop();
                          }
                        },
                        child: Text('Maybe later'),
                      )
                    : SizedBox()
              ],
            );
          });
    }
  }

  compareVersions() {
    if (version == null) {
      return;
    }

    try {
      List<String> currentPackageNumbers = packageInfo.version.split('.');
      List<String> latestPackageNumbers = version!.latestVersion.split('.');

      print('currentPackageNumbers : ${currentPackageNumbers}');
      print('latestPackageNumbers : ${latestPackageNumbers}');

      if (int.parse(latestPackageNumbers[0]) >
          int.parse(currentPackageNumbers[0])) {
        isNewVersionAvailable = true;
      } else if (int.parse(latestPackageNumbers[1]) >
          int.parse(currentPackageNumbers[1])) {
        isNewVersionAvailable = true;
      } else if (int.parse(latestPackageNumbers[2]) >
          int.parse(currentPackageNumbers[2])) {
        isNewVersionAvailable = true;
      } else if (int.parse(version!.buildNumber) >
          int.parse(packageInfo.buildNumber)) {
        isNewVersionAvailable = true;
      }

      isBackwardCompatible = version!.isBackwardCompatible;
      print(
        'isNewVersionAvailable : ${isNewVersionAvailable}, isback: ${isBackwardCompatible}',
      );
    } catch (e) {
      print('error in comparing versions');
    }
  }

  mobileUpgradedDialog() async {
    final newVersion = NewVersion();
    final status = await newVersion.getVersionStatus();

    // for forced version update
    if (!isBackwardCompatible && status != null) {
      newVersion.showUpdateDialog(
        context: NavService.navKey.currentContext!,
        versionStatus: status,
        allowDismissal: false,
      );
    } else {
      newVersion.showAlertIfNecessary(
          context: NavService.navKey.currentContext!);
    }
  }

  desktopUpdateHandler() async {
    late String url;
    if (Platform.isMacOS) {
      url = MixedConstants.MACOS_STORE_LINK;
    } else if (Platform.isWindows) {
      url = MixedConstants.WINDOWS_STORE_LINK;
    } else if (Platform.isLinux) {
      url = MixedConstants.LINUX_STORE_LINK;
    }

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    }
  }
}
