import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_list.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/widgets/download_all_button.dart';
import 'package:atsign_atmosphere_pro/widgets/download_all_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopHistoryReceivedCardBody extends StatefulWidget {
  final FileTransfer fileTransfer;
  final HistoryType type;

  const DesktopHistoryReceivedCardBody({
    required this.fileTransfer,
    required this.type,
  });

  @override
  State<DesktopHistoryReceivedCardBody> createState() =>
      _DesktopHistoryReceivedCardBodyState();
}

class _DesktopHistoryReceivedCardBodyState
    extends State<DesktopHistoryReceivedCardBody> {
  late HistoryProvider historyProvider =
      Provider.of<HistoryProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.culturedColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.listFileShadowColor.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 9,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: (widget.fileTransfer.files ?? [])
              .every((element) => !(File(element.path ?? '').existsSync()))
          ? buildUnDownloadedFileWidget
          : DesktopHistoryFileList(
              fileTransfer: widget.fileTransfer,
              type: widget.type,
            ),
    );
  }

  Widget get buildUnDownloadedFileWidget {
    final int numberOfFiles = widget.fileTransfer.files?.length ?? 0;
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$numberOfFiles ${numberOfFiles > 1 ? 'Files' : 'File'} Attached',
            style: CustomTextStyles.spanishGrayW50012,
          ),
          buildSaveButton(),
        ],
      ),
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
            ? DownloadAllProgressIndicator(
                progress: (fileTransferProgress.percent ?? 0) / 100,
              )
            : !(widget.fileTransfer.files ?? []).every(
                    (element) => !(File(element.path ?? '').existsSync()))
                ? SvgPicture.asset(
                    AppVectors.icCloudDownloaded,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  )
                : historyProvider.downloadingFilesList
                        .contains(widget.fileTransfer.key)
                    ? SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          await downloadFiles(widget.fileTransfer);
                        },
                        child: DownloadAllButton(),
                      );
      },
    );
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
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings.noInternetMsg,
        bgColor: ColorConstants.redAlert,
      );
      return;
    }

    for (FileData i in file.files ?? []) {
      if (!(File(i.path ?? '').existsSync())) {
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
          SnackbarService().showSnackbar(
            NavService.navKey.currentContext!,
            TextStrings().downloadFailed,
            bgColor: ColorConstants.redAlert,
          );

          return;
        }
      }
    }
    historyProvider.removeDownloadingState(file.key);
    SnackbarService().showSnackbar(
      NavService.navKey.currentContext!,
      TextStrings().fileDownloadd,
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
