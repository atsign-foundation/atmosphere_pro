import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
}
