import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryStatusBadges extends StatefulWidget {
  final FileHistory fileHistory;

  const HistoryStatusBadges({
    Key? key,
    required this.fileHistory,
  });

  @override
  State<HistoryStatusBadges> createState() => _HistoryStatusBadgesState();
}

class _HistoryStatusBadgesState extends State<HistoryStatusBadges> {
  bool isDownloading = false;
  int get numberFileUnread {
    int result = 0;
    List<String> listFileName = (widget.fileHistory.fileDetails?.files ?? [])
        .map((e) => e.name ?? '')
        .toList();
    for (String i in listFileName) {
      final filePath = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          i;
      if (!(File(filePath).existsSync())) {
        result++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, value, child) {
        if (numberFileUnread != 0) {
          if (widget.fileHistory.type == HistoryType.received) {
            return buildDownloadButton();
          } else {
            return InkWell(
              onTap: () {
                openFileReceiptBottomSheet();
              },
              child: (widget.fileHistory.sharedWith ?? [])
                      .every((element) => element.isNotificationSend ?? false)
                  ? buildDeliveredBadge()
                  : buildErrorBadges(),
            );
          }
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildDeliveredBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(49.5),
        color: ColorConstants.deliveredBackgroundColor,
      ),
      child: Text(
        'Delivered',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: ColorConstants.deliveredColor,
        ),
      ),
    );
  }

  /// shows file read number
  // Widget buildReadAllBadges() {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 32,
  //         height: 32,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: ColorConstants.lightGreen,
  //         ),
  //         child: Center(
  //           child: Icon(
  //             Icons.done_all,
  //             size: 20,
  //             color: ColorConstants.textGreen,
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 4),
  //       Container(
  //         padding: EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(49.5),
  //           color: ColorConstants.lightGreen,
  //         ),
  //         child: Text(
  //           'Read',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.w500,
  //             color: ColorConstants.textGreen,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget buildDownloadButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileHistory.fileDetails?.key];
        return fileTransferProgress != null
            ? Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(
                        AppVectors.icCloudDownloading,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: (fileTransferProgress.percent ?? 0) / 100,
                        strokeWidth: 1,
                        color: ColorConstants.downloadIndicatorColor,
                      ),
                    ),
                  ),
                ],
              )
            : isFilesPresent(widget.fileHistory.fileDetails!)
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset(
                      AppVectors.icCloudDownloaded,
                    ),
                  )
                : isDownloading
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ColorConstants.downloadIndicatorColor,
                        ),
                      )
                    : buildIconButton(
                        onTap: () async {
                          await downloadFiles(widget.fileHistory.fileDetails);
                        },
                        icon: AppVectors.icDownloadFile,
                      );
      },
    );
  }

  bool isFilesPresent(FileTransfer files) {
    bool isPresented = true;
    for (FileData i in files.files ?? []) {
      final bool isExist = checkFileExist(data: i);
      if (!isExist) {
        isPresented = false;
      }
    }
    if (context.read<HistoryProvider>().isDownloadDone) {
      context.read<HistoryProvider>().resetIsDownloadDone();
    }
    return isPresented;
  }

  bool checkFileExist({required FileData data}) {
    String filePath = getFilePath(data.name ?? '');

    File file = File(filePath);
    return file.existsSync();
  }

  String getFilePath(String name) {
    return BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        name;
  }

  Widget buildErrorBadges() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.errorBackgroundColor,
          ),
          child: Center(
            child: Text(
              '!',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: ColorConstants.orangeColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(49.5),
            color: ColorConstants.errorBackgroundColor,
          ),
          child: Text(
            'Error',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColorConstants.orangeColor,
            ),
          ),
        ),
        SizedBox(width: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(49.5),
            color: ColorConstants.retryButtonColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Retry',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.iconHeaderColor,
                ),
              ),
              SizedBox(width: 4),
              SvgPicture.asset(
                AppVectors.icRefresh,
                width: 8,
                height: 8,
                color: ColorConstants.iconHeaderColor,
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildIconButton({
    required Function() onTap,
    required String icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }

  openFileReceiptBottomSheet({FileRecipientSection? fileRecipientSection}) {
    Provider.of<FileTransferProvider>(context, listen: false)
        .selectedFileHistory = widget.fileHistory;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (_context) {
          return Container(
            height: SizeConfig().screenHeight * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: FileRecipients(
              widget.fileHistory.sharedWith,
              fileRecipientSection: fileRecipientSection,
              key: UniqueKey(),
            ),
          );
        });
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
      if (!(await checkFileExist(data: i))) {
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
