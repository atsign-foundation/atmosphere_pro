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
    isBackwardCompatible = true;
    isNewVersionAvailable = false;
    appVersion = AppVersion();
    await getVersion();
    compareVersions();
    showVersionUpgradeDialog();
  }

  /// [setVersion] is used to update version data in key
  /// should only be updated by [@significantredpanda]
  setVersion() async {
    var androidVersion = Version(
      latestVersion: '1.0.3',
      minVersion: '1.0.3',
      buildNumber: '27',
      minBuildNumber: '27',
      isBackwardCompatible: true,
    );
    var iosVersion = Version(
      latestVersion: '1.0.2',
      minVersion: '1.0.2',
      buildNumber: '26',
      minBuildNumber: '26',
      isBackwardCompatible: true,
    );
    var macosVersion = Version(
      latestVersion: '1.0.0',
      minVersion: '1.0.0',
      buildNumber: '13',
      minBuildNumber: '13',
      isBackwardCompatible: true,
    );
    var windowsVersion = Version(
      latestVersion: '1.0.1',
      minVersion: '1.0.1',
      buildNumber: '0',
      minBuildNumber: '0',
      isBackwardCompatible: true,
    );
    var linuxVersion = Version(
      latestVersion: '1.0.0',
      minVersion: '1.0.0',
      buildNumber: '0',
      minBuildNumber: '0',
      isBackwardCompatible: true,
    );

    var appVersion = AppVersion(
      android: androidVersion,
      ios: iosVersion,
      macOs: macosVersion,
      windows: windowsVersion,
      linux: linuxVersion,
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
      ..key = 'app_versions'
      ..metadata = Metadata()
      ..metadata!.isPublic = true
      ..sharedBy = '@significantredpanda';
  }

  showVersionUpgradeDialog() async {
    if (Platform.isIOS || Platform.isAndroid) {
      mobileUpgradedDialog();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
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
      List<String> minPackageNumbers = version!.minVersion.split('.');

      // checking for new version
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

      // checking for backward compatibility
      if (int.parse(minPackageNumbers[0]) >
          int.parse(currentPackageNumbers[0])) {
        isBackwardCompatible = false;
      } else if (int.parse(minPackageNumbers[1]) >
          int.parse(currentPackageNumbers[1])) {
        isBackwardCompatible = false;
      } else if (int.parse(minPackageNumbers[2]) >
          int.parse(currentPackageNumbers[2])) {
        isBackwardCompatible = false;
      } else if (int.parse(version!.minBuildNumber) >
          int.parse(packageInfo.buildNumber)) {
        isBackwardCompatible = false;
      }

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
