import 'dart:convert';
import 'dart:io';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/version.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class VersionService {
  VersionService._();
  static VersionService _internal = VersionService._();
  factory VersionService.getInstance() {
    return _internal;
  }

  Version? version;
  late PackageInfo packageInfo;
  bool isBackwardCompatible = true, isNewVersionAvailable = false;

  init() async {
    isBackwardCompatible = true;
    isNewVersionAvailable = false;
    await getVersion();
    compareVersions();
    showVersionUpgradeDialog();
  }

  getVersion() async {
    packageInfo = await PackageInfo.fromPlatform();

    try {
      var response = await http.get(Uri.parse(MixedConstants.RELEASE_TAG_API));

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        var body = decodedResponse['body'];
        var minVersion = body.substring(0, 27) + '}';
        minVersion = minVersion.replaceAll(
          "minimumVersion",
          '"minimumVersion"',
        );
        minVersion = minVersion.replaceAll("'", '"');

        var minVersionJson = jsonDecode(minVersion);

        version = Version(
          latestVersion: decodedResponse['name'],
          minVersion: minVersionJson['minimumVersion'],
        );

        print('version to json: ${version!.toJson()}');
        print(
            'packageInfo : ${packageInfo.version}.${packageInfo.buildNumber}');
      }
    } catch (e) {
      print('error in fetching release tag : $e');
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings.releaseTagError,
      );
    }
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
                          'You can now update this app from ${packageInfo.version}.${packageInfo.buildNumber} to ${version!.latestVersion}')
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: desktopUpdateHandler,
                  child: Text(TextStrings().update),
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
                        child: Text(TextStrings().mayBeLater),
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
      } else if (int.parse(latestPackageNumbers[3]) >
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
      } else if (int.parse(minPackageNumbers[3]) >
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
          dialogText:
              'You can now update this app from ${packageInfo.version}.${packageInfo.buildNumber} to ${version!.latestVersion}');
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
