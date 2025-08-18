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
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/widgets/download_all_button.dart';
import 'package:atsign_atmosphere_pro/widgets/download_all_progress_indicator.dart';
import 'package:atsign_atmosphere_pro/widgets/expired_notice_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopHistoryReceivedCardBody extends StatefulWidget {
  final FileTransfer fileTransfer;
  final HistoryType type;

  const DesktopHistoryReceivedCardBody({
    Key? key,
    required this.fileTransfer,
    required this.type,
  }) : super(key: key);

  @override
  State<DesktopHistoryReceivedCardBody> createState() =>
      _DesktopHistoryReceivedCardBodyState();
}

class _DesktopHistoryReceivedCardBodyState
    extends State<DesktopHistoryReceivedCardBody> {
  late HistoryProvider historyProvider =
      Provider.of<HistoryProvider>(context, listen: false);
  late bool isDownloaded;

  @override
  void initState() {
    isDownloaded = isFilesPresent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
          child: Selector<HistoryProvider, bool>(
            builder: (context, value, child) {
              return isDownloaded || value
                  ? buildUnDownloadedFileWidget
                  : DesktopHistoryFileList(
                      fileTransfer: widget.fileTransfer,
                      type: widget.type,
                    );
            },
            selector: (_, p) =>
                p.downloadingFilesList.contains(widget.fileTransfer.key),
          ),
        ),
        SizedBox(height: 12),
        if (!CommonUtilityFunctions().isFileDownloadAvailable(
                widget.fileTransfer.date ?? DateTime.now()) &&
            (widget.fileTransfer.files ?? [])
                .every((element) => !(File(element.path ?? '').existsSync())))
          ExpiredNoticeWidget(),
      ],
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
        return fileTransferProgress != null
            ? DownloadAllProgressIndicator(
                progress: (fileTransferProgress.percent ?? 0) / 100,
              )
            : Selector<HistoryProvider, bool>(
                builder: (context, value, child) {
                  return value
                      ? SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: ColorConstants.downloadIndicatorColor,
                          ),
                        )
                      : CommonUtilityFunctions().isFileDownloadAvailable(
                              widget.fileTransfer.date ?? DateTime.now())
                          ? InkWell(
                              onTap: () async {
                                await downloadFiles(widget.fileTransfer);
                              },
                              child: DownloadAllButton(),
                            )
                          : DownloadAllButton(enable: false);
                },
                selector: (_, p) =>
                    p.downloadingFilesList.contains(widget.fileTransfer.key),
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
      listen: false,
    ).checkConnectivity();

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
      var result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadSingleFile(
        file.key,
        file.sender,
        false,
        i.name ?? '',
      );
      if (result is bool && result) {
        await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                listen: false)
            .saveNewDataInMyFiles(file);
        print(file.url);
        // send download acknowledgement
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .sendFileDownloadAcknowledgement(file);
      } else if (result is bool && !result) {
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          TextStrings().downloadFailed,
          bgColor: ColorConstants.redAlert,
        );
        historyProvider.removeDownloadingState(file.key);
        if (mounted) {
          setState(() {
            isDownloaded = isFilesPresent;
          });
        }
        return;
      }
    }
    historyProvider.removeDownloadingState(file.key);
    if (mounted) {
      setState(() {
        isDownloaded = isFilesPresent;
      });
    }
    SnackbarService().showSnackbar(
      NavService.navKey.currentContext!,
      TextStrings().fileDownloadd,
      bgColor: ColorConstants.successGreen,
    );
  }

  bool get isFilesPresent {
    return (widget.fileTransfer.files ?? [])
        .every((element) => !(File(element.path ?? '').existsSync()));
  }
}
