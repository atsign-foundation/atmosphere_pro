import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_card_header.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_list.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
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
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistoryCardItem extends StatefulWidget {
  final FileHistory fileHistory;

  const HistoryCardItem({
    Key? key,
    required this.fileHistory,
  });

  @override
  State<HistoryCardItem> createState() => _HistoryCardItemState();
}

class _HistoryCardItemState extends State<HistoryCardItem> {
  bool isDownloading = false;

  late bool canDownload = CommonUtilityFunctions()
      .isFileDownloadAvailable(widget.fileHistory.fileTransferObject!.date!);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        extentRatio: 0.6,
        children: [
          SizedBox(width: 12),
          buildDownloadButton(),
          SizedBox(width: 12),
          buildTransferButton(),
          SizedBox(width: 12),
          buildDeleteButton(),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HistoryCardHeader(
              fileHistory: widget.fileHistory,
            ),
            SizedBox(height: 12),
            Flexible(
              child: HistoryFileList(
                type: widget.fileHistory.type,
                fileTransfer: widget.fileHistory.fileDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            : isAnyFilesPresent(widget.fileHistory.fileDetails!)
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
                        onDisableTap: () {
                          CommonUtilityFunctions().showFileHasExpiredDialog(
                            MediaQuery.textScaleFactorOf(context),
                          );
                        },
                        activeIcon: AppVectors.icDownloadFile,
                        disableIcon: AppVectors.icDownloadDisable,
                        isActive: canDownload,
                      );
      },
    );
  }

  Widget buildTransferButton() {
    return buildIconButton(
      onTap: () {
        Provider.of<FileTransferProvider>(context, listen: false)
            .selectedFiles
            .addAll(widget.fileHistory.fileDetails!.files!
                .where((e) => checkFileExist(data: e))
                .map(
                  (e) => PlatformFile(
                    name: e.name ?? '',
                    size: e.size ?? 0,
                    path: getFilePath(e.name ?? ''),
                  ),
                )
                .toList());
        Provider.of<FileTransferProvider>(context, listen: false).notify();
        Provider.of<WelcomeScreenProvider>(context, listen: false)
            .changeBottomNavigationIndex(0);
      },
      activeIcon: AppVectors.icSendFile,
      disableIcon: AppVectors.icSendDisable,
      isActive: isAnyFilesPresent(widget.fileHistory.fileDetails!),
    );
  }

  Widget buildDeleteButton() {
    return buildIconButton(
      onTap: () {
        CommonUtilityFunctions().showConfirmationDialog(
          () {
            widget.fileHistory.fileDetails!.files!.forEach((e) async {
              if (checkFileExist(data: e)) {
                await File(getFilePath(e.name ?? '')).delete();
                await Provider.of<MyFilesProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .removeParticularFile(
                  widget.fileHistory.fileDetails?.key ?? '',
                  getFilePath(e.name ?? '').split(Platform.pathSeparator).last,
                );

                await Provider.of<MyFilesProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .getAllFiles();
              }
            });
            SnackbarService().showSnackbar(
              context,
              "Successfully deleted the file",
              bgColor: ColorConstants.successColor,
            );
            Provider.of<HistoryProvider>(context, listen: false).notify();
          },
          'Are you sure you want to delete the file(s)?',
        );
      },
      activeIcon: AppVectors.icDeleteFile,
      disableIcon: AppVectors.icDeleteDisable,
      isActive: isAnyFilesPresent(widget.fileHistory.fileDetails!),
    );
  }

  Widget buildIconButton({
    required Function() onTap,
    required String activeIcon,
    required String disableIcon,
    required bool isActive,
    Function()? onDisableTap,
  }) {
    return InkWell(
      onTap: isActive ? onTap : onDisableTap,
      child: SvgPicture.asset(
        isActive ? activeIcon : disableIcon,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
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
            isAnyFilesPresent(widget.fileHistory.fileDetails!);
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
      isAnyFilesPresent(widget.fileHistory.fileDetails!);
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
    }
  }

  bool isAnyFilesPresent(FileTransfer files) {
    bool isPresented = (files.files ?? []).any((element) {
      final bool isExist = checkFileExist(data: element);
      return isExist;
    });
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
}
