import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_list.dart';
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
import 'package:atsign_atmosphere_pro/widgets/expired_notice_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryReceivedCardBody extends StatefulWidget {
  final FileHistory fileHistory;

  const HistoryReceivedCardBody({
    required this.fileHistory,
  });

  @override
  State<HistoryReceivedCardBody> createState() =>
      _HistoryReceivedCardBodyState();
}

class _HistoryReceivedCardBodyState extends State<HistoryReceivedCardBody> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return (widget.fileHistory.fileDetails?.files ?? [])
            .every((element) => !(File(element.path ?? '').existsSync()))
        ? buildUnDownloadedFileWidget
        : HistoryFileList(
            type: widget.fileHistory.type,
            fileTransfer: widget.fileHistory.fileDetails,
            isSent: false,
          );
  }

  Widget get buildUnDownloadedFileWidget {
    final int numberOfFiles =
        widget.fileHistory.fileDetails?.files?.length ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ColorConstants.culturedColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$numberOfFiles ${numberOfFiles > 1 ? 'Files' : 'File'} Attached',
                style: CustomTextStyles.spanishGrayW50012,
              ),
              buildDownloadButton(),
            ],
          ),
        ),
        if (!CommonUtilityFunctions().isFileDownloadAvailable(
            widget.fileHistory.fileDetails?.date ?? DateTime.now())) ...[
          SizedBox(height: 12),
          ExpiredNoticeWidget(),
        ]
      ],
    );
  }

  Widget buildDownloadButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileHistory.fileDetails?.key];
        return fileTransferProgress != null
            ? DownloadAllProgressIndicator(
                progress: (fileTransferProgress.percent ?? 0) / 100,
              )
            : isFilesPresent(widget.fileHistory.fileDetails!)
                ? SvgPicture.asset(
                    AppVectors.icCloudDownloaded,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  )
                : isDownloading
                    ? SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : CommonUtilityFunctions().isFileDownloadAvailable(
                            widget.fileHistory.fileDetails?.date ??
                                DateTime.now())
                        ? InkWell(
                            onTap: () async {
                              await downloadFiles(
                                widget.fileHistory.fileDetails,
                              );
                            },
                            child: DownloadAllButton(),
                          )
                        : DownloadAllButton(enable: false);
      },
    );
  }

  bool isFilesPresent(FileTransfer files) {
    bool isPresented = true;
    for (FileData i in files.files ?? []) {
      final bool isExist = File(i.path ?? '').existsSync();
      if (!isExist) {
        isPresented = false;
      }
    }
    if (context.read<HistoryProvider>().isDownloadDone) {
      context.read<HistoryProvider>().resetIsDownloadDone();
    }
    return isPresented;
  }

  Future<void> downloadFiles(FileTransfer? file) async {
    setState(() {
      isDownloading = true;
    });
    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[file!.key];

    if (fileTransferProgress != null) {
      return; //returning because download is still in progress
    }

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
      setState(() {
        isDownloading = false;
      });
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
        // setState(() {
        //   numberOfFinished++;
        // });
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
        if (mounted) {
          setState(() {
            isDownloading = false;
          });
          isFilesPresent(widget.fileHistory.fileDetails!);
          return;
        }
      }
    }
    if (mounted) {
      setState(() {
        isDownloading = false;
      });
      Provider.of<HistoryProvider>(context, listen: false).notify();
      isFilesPresent(widget.fileHistory.fileDetails!);
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
    }
  }
}
