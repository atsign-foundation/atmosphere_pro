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

        version = Version(
          latestVersion: decodedResponse['latestVersion'],
          minVersion: decodedResponse['minimumVersion'],
        );
      } else {
        SnackBarService().showSnackBar(
          NavService.navKey.currentContext!,
          TextStrings.appVersionFetchError,
        );
      }
    } catch (e) {
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings.releaseTagError,
      );
    }
  }

  showVersionUpgradeDialog() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        mobileUpgradedDialog();
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        desktopUpgradeDialog();
      }
    } catch (e) {
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings.upgradeDialogShowError,
      );
    }
  }

  desktopUpgradeDialog() {
    if (isNewVersionAvailable && version != null) {
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

    if (status != null && isNewVersionAvailable && version != null) {
      newVersion.showUpdateDialog(
          context: NavService.navKey.currentContext!,
          versionStatus: status,
          allowDismissal: isBackwardCompatible ? true : false,
          dialogText:
              'You can now update this app from ${packageInfo.version}.${packageInfo.buildNumber} to ${version!.latestVersion}');
    }
  }

  desktopUpdateHandler() async {
    late String path;
    if (Platform.isMacOS) {
      path = MixedConstants.MACOS_STORE_LINK;
    } else if (Platform.isWindows) {
      path = MixedConstants.WINDOWS_STORE_LINK;
    } else if (Platform.isLinux) {
      path = MixedConstants.LINUX_STORE_LINK;
    }
    final url = Uri.parse(path);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
      );
    }
  }
}
