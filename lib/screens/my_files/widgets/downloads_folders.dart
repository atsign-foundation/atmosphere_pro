import 'dart:io';

import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openDownloadsFolder(BuildContext context) async {
  if (Platform.isAndroid) {
    await FilesystemPicker.open(
      title: TextStrings().atmosphereDownloadFolder,
      context: context,
      rootDirectory: BackendService.getInstance().downloadDirectory!,
      fsType: FilesystemType.all,
      folderIconColor: Colors.teal,
      allowedExtensions: [],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      requestPermission: () async =>
          await Permission.storage.request().isGranted,
    );
  } else {
    final url =
        'shareddocuments://${BackendService.getInstance().atClientPreference.downloadPath!}';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

Future<void> openFilePath(String path) async {
  File test = File(path);
  bool fileExists = await test.exists();
  if (fileExists) {
    await OpenFile.open(path);
  } else {
    CommonUtilityFunctions().showNoFileDialog();
  }
}
