import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
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

class DesktopCardFunctionList extends StatefulWidget {
  final FileTransfer fileTransfer;

  const DesktopCardFunctionList({
    required this.fileTransfer,
  });

  @override
  State<DesktopCardFunctionList> createState() =>
      _DesktopCardFunctionListState();
}

class _DesktopCardFunctionListState extends State<DesktopCardFunctionList> {
  late bool isDownloaded;
  late HistoryProvider historyProvider;

  @override
  void initState() {
    historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    isDownloaded = widget.fileTransfer.files!.every(
      (element) => File(getFilePath(name: element.name ?? '')).existsSync(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildSaveButton(),
        if (isDownloaded) ...[
          SizedBox(width: 12),
          buildOptionButton(
            onTap: () async {
              List<PlatformFile> data = widget.fileTransfer.files!
                  .map((e) => PlatformFile(
                        name: e.name ?? '',
                        size: e.size ?? 0,
                        path: getFilePath(name: e.name ?? ''),
                        bytes: File(getFilePath(name: e.name ?? ''))
                            .readAsBytesSync(),
                      ))
                  .toList();
              FileTransferProvider.appClosedSharedFiles.addAll(data);

              Provider.of<FileTransferProvider>(context, listen: false)
                  .setFiles();
              await DesktopSetupRoutes.nested_pop();
            },
            icon: AppVectors.icSendFile,
          ),
          SizedBox(width: 12),
          buildOptionButton(
            onTap: () {
              CommonUtilityFunctions().showConfirmationDialog(
                () {
                  widget.fileTransfer.files!.forEach((e) {
                    File(getFilePath(name: e.name ?? '')).deleteSync();
                  });
                  SnackBarService().showSnackBar(
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
          )
        ]
      ],
    );
  }

  Widget buildSaveButton() {
    /// check if download expired
    if (!CommonUtilityFunctions()
        .isFileDownloadAvailable(widget.fileTransfer.date!)) {
      return SizedBox.shrink();
    }
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileTransfer.key];
        return fileTransferProgress != null &&
                historyProvider.downloadingFilesList
                    .contains(widget.fileTransfer.key)
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
                ? SvgPicture.asset(
                    AppVectors.icCloudDownloaded,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  )
                : historyProvider.downloadingFilesList
                        .contains(widget.fileTransfer.key)
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
                          await downloadFiles(widget.fileTransfer);
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

  String getFilePath({required String name}) {
    final result = MixedConstants.getFileDownloadLocationSync(
      sharedBy: widget.fileTransfer.sender ?? '',
    );

    return result + Platform.pathSeparator + name;
  }

  Future<void> downloadFiles(FileTransfer file) async {
    historyProvider.addDownloadingState(file.key);

    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[file.key];

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
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings.noInternetMsg,
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

    for (FileData i in file.files ?? []) {
      if (!(File(getFilePath(name: i.name ?? '')).existsSync())) {
        var result = await Provider.of<HistoryProvider>(
                NavService.navKey.currentContext!,
                listen: false)
            .downloadSingleFile(
          file.key,
          file.sender,
          false,
          i.name ?? '',
        );
        if (result is bool && !result) {
          historyProvider.removeDownloadingState(file.key);
          SnackBarService().showSnackBar(
            NavService.navKey.currentContext!,
            TextStrings().downloadFailed,
            bgColor: ColorConstants.redAlert,
          );

          return;
        }
      }
    }
    historyProvider.removeDownloadingState(file.key);
    SnackBarService().showSnackBar(
      NavService.navKey.currentContext!,
      TextStrings().fileDownload,
      bgColor: ColorConstants.successGreen,
    );
    await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
            listen: false)
        .saveNewDataInMyFiles(file);
    print(file.url);
    // send download acknowledgement
    await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .sendFileDownloadAcknowledgement(file);
  }
}
