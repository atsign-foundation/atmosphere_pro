import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/widgets/detail_history_card.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_received_card_header.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_received_card_body.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_sent_card_body.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_sent_card_header.dart';
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
    widget.fileHistory.fileDetails?.files?.forEach(
      (e) => e.path = getFilePath(
        name: e.name ?? '',
        type: HistoryType.received,
      ),
    );
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
      child: InkWell(
        onTap: () {
          if (widget.fileHistory.type == HistoryType.send) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.95,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return DetailHistoryCard(
                  onPop: () {},
                  fileHistory: widget.fileHistory,
                  isMobile: true,
                );
              },
            );
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.fileHistory.type == HistoryType.received
                  ? HistoryReceivedCardHeader(fileHistory: widget.fileHistory)
                  : HistorySentCardHeader(fileHistory: widget.fileHistory),
              SizedBox(height: 12),
              Flexible(
                child: widget.fileHistory.type == HistoryType.received
                    ? HistoryReceivedCardBody(fileHistory: widget.fileHistory)
                    : HistorySentCardBody(fileHistory: widget.fileHistory),
              ),
            ],
          ),
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
                    path: getFilePath(
                      name: e.name ?? '',
                      type: widget.fileHistory.type,
                    ),
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
                await File(getFilePath(
                  name: e.name ?? '',
                  type: widget.fileHistory.type,
                )).delete();
                await Provider.of<MyFilesProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .removeParticularFile(
                  widget.fileHistory.fileDetails?.key ?? '',
                  getFilePath(
                    name: e.name ?? '',
                    type: widget.fileHistory.type,
                  ).split(Platform.pathSeparator).last,
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
    bool fileExists = false;
    String sentFilePath = getSentFilePath(data.name ?? '');
    String receivedFilePath = getFilePath(
      name: data.name ?? '',
      type: HistoryType.received,
    );

    /// for sent file directory
    if (widget.fileHistory.type == HistoryType.send) {
      File file = File(sentFilePath);
      if (file.existsSync()) {
        return true;
      }
    }

    File file = File(receivedFilePath);
    fileExists = file.existsSync();
    return fileExists;
  }

  String getFilePath({
    required String name,
    required HistoryType? type,
  }) {
    if (type == HistoryType.send) {
      String sentFilePath = getSentFilePath(name);
      File file = File(sentFilePath);
      if (file.existsSync()) {
        return file.path;
      }
    }

    return BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        name;
  }

  String getSentFilePath(String name) {
    return BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        'sent-files' +
        Platform.pathSeparator +
        name;
  }
}
