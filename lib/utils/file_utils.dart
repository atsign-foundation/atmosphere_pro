import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' show basename;

class FileUtils {
  static Future<void> deleteFile(
    String filePath, {
    String? fileTransferId,
    Function()? onComplete,
  }) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(
        onConfirmation: () async {
          var file = File(filePath);
          if (await file.exists()) {
            file.deleteSync();
          }
          if (fileTransferId != null) {
            await Provider.of<MyFilesProvider>(
                    NavService.navKey.currentContext!,
                    listen: false)
                .removeParticularFile(fileTransferId,
                    filePath.split(Platform.pathSeparator).last);

            await Provider.of<MyFilesProvider>(
                    NavService.navKey.currentContext!,
                    listen: false)
                .getAllFiles();
          }
          onComplete;
        },
        deleteMessage: TextStrings.deleteFileConfirmationMsgMyFiles,
      ),
    );
  }

  static Future<void> moveToSendFile(String filePath) async {
    final file = File(filePath);
    final length = await file.length();
    FileTransferProvider.appClosedSharedFiles.add(
      PlatformFile(
          name: basename(file.path),
          path: file.path,
          size: length.round(),
          bytes: await file.readAsBytes()),
    );
    Provider.of<FileTransferProvider>(NavService.navKey.currentContext!,
            listen: false)
        .setFiles();
    Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
            listen: false)
        .changeBottomNavigationIndex(0);
  }
}
