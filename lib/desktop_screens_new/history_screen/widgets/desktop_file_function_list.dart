import 'dart:io';

import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopFileFunctionList extends StatelessWidget {
  final String filePath;
  final String idKey;
  final DateTime date;
  final String name;
  final int size;
  final bool isDownloading;
  final bool isDownloaded;

  const DesktopFileFunctionList({
    required this.filePath,
    required this.date,
    required this.name,
    required this.size,
    required this.isDownloading,
    required this.isDownloaded,
    required this.idKey,
  });

  @override
  Widget build(BuildContext context) {
    return File(filePath).existsSync()
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              buildOptionButton(
                onTap: () async {
                  FileTransferProvider.appClosedSharedFiles.add(PlatformFile(
                    name: name,
                    size: size,
                    path: filePath,
                    bytes: File(filePath).readAsBytesSync(),
                  ));

                  Provider.of<FileTransferProvider>(context, listen: false)
                      .setFiles();
                  await DesktopSetupRoutes.nested_pop();
                },
                icon: AppVectors.icSendFile,
              ),
              SizedBox(width: 4),
              buildOptionButton(
                onTap: () {
                  CommonUtilityFunctions().showConfirmationDialog(
                    () async {
                      await File(filePath).delete();
                      await Provider.of<MyFilesProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .removeParticularFile(
                        idKey,
                        filePath.split(Platform.pathSeparator).last,
                      );

                      await Provider.of<MyFilesProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .getAllFiles();
                      SnackbarService().showSnackbar(
                        context,
                        "Successfully deleted the file",
                        bgColor: ColorConstants.successColor,
                      );
                      Provider.of<HistoryProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .notify();
                    },
                    'Are you sure you want to delete the file(s)?',
                  );
                },
                icon: AppVectors.icDeleteFile,
              ),
            ],
          )
        : buildSaveButton();
  }

  Widget buildSaveButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress = provider.receivedFileProgress[idKey];
        return fileTransferProgress != null &&
                fileTransferProgress.fileName == name
            ? Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppVectors.icCloudDownloading,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: (fileTransferProgress.percent ?? 0) / 100,
                        strokeWidth: 1,
                        color: ColorConstants.downloadIndicatorColor,
                      ),
                    ),
                  ),
                ],
              )
            : isDownloaded
                ? SizedBox.shrink()
                : isDownloading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : (CommonUtilityFunctions().isFileDownloadAvailable(
                        date,
                      ))
                        ? SvgPicture.asset(
                            AppVectors.icDownloadFile,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          )
                        : SizedBox.shrink();
      },
    );
  }

  Widget buildOptionButton({
    required Function() onTap,
    required String icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
      ),
    );
  }
}
