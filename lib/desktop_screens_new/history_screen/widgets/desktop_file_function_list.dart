import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopFileFunctionList extends StatefulWidget {
  final String filePath;
  final FileTransfer fileTransfer;
  final FileData data;

  const DesktopFileFunctionList({
    required this.filePath,
    required this.fileTransfer,
    required this.data,
  });

  @override
  State<DesktopFileFunctionList> createState() =>
      _DesktopFileFunctionListState();
}

class _DesktopFileFunctionListState extends State<DesktopFileFunctionList> {
  bool isDownloading = false;
  late bool isDownloaded;

  @override
  void initState() {
    isDownloaded = File(widget.filePath).existsSync();
    super.initState();
  }

  Future<void> downloadFiles(FileData file) async {
    setState(() {
      isDownloading = true;
    });

    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[widget.fileTransfer.key];

    if (fileTransferProgress != null) {
      return; //returning because download is still in progress
    }

    await Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .checkConnectivity();

    var isConnected = Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .isInternetAvailable;

    if (!isConnected) {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings.noInternetMsg,
        bgColor: ColorConstants.redAlert,
      );
      return;
    }
    var result = await Provider.of<HistoryProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .downloadSingleFile(
      widget.fileTransfer.key,
      widget.fileTransfer.sender ?? '',
      false,
      file.name ?? '',
    );
    if (result is bool && result) {
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(widget.fileTransfer);
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(widget.fileTransfer);
      if (mounted) {
        setState(() {
          isDownloading = false;

          isDownloaded = true;
        });
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          TextStrings().fileDownloadd,
          bgColor: ColorConstants.successGreen,
        );
      }
    } else if (result is bool && !result) {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().downloadFailed,
        bgColor: ColorConstants.redAlert,
      );
      if (mounted) {
        setState(() {
          isDownloading = false;
          isDownloaded = false;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return File(widget.filePath).existsSync()
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              buildOptionButton(
                onTap: () async {
                  FileTransferProvider.appClosedSharedFiles.add(PlatformFile(
                    name: widget.data.name ?? '',
                    size: widget.data.size ?? 0,
                    path: widget.filePath,
                    bytes: File(widget.filePath).readAsBytesSync(),
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
                  File(widget.filePath).deleteSync();
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
                icon: AppVectors.icDeleteFile,
              ),
            ],
          )
        : buildSaveButton();
  }

  Widget buildSaveButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileTransfer.key];
        return fileTransferProgress != null &&
                fileTransferProgress.fileName == widget.data.name
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
                ? SizedBox()
                : isDownloading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          await downloadFiles(widget.data);
                        },
                        child: SvgPicture.asset(
                          AppVectors.icDownloadFile,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      );
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
