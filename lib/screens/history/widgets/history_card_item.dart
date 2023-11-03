import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_card_header.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_list.dart';
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
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await isFilesPresent(widget.fileHistory.fileDetails!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        extentRatio: 0.35,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: buildDownloadButton(),
          ),
          SizedBox(width: 12),
          buildTransferButton(),
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
              type: widget.fileHistory.type,
              sender: widget.fileHistory.fileDetails?.sender,
              groupName: widget.fileHistory.groupName,
              sharedWith: widget.fileHistory.sharedWith ?? [],
              note: widget.fileHistory.fileDetails?.notes ?? '',
              date: widget.fileHistory.fileDetails!.date!,
              fileNameList: widget.fileHistory.fileDetails!.files!
                  .map((e) => e.name ?? '')
                  .toList(),
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
            : isDownloaded
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

  Widget buildTransferButton() {
    return isDownloaded
        ? buildIconButton(
            onTap: () {
              Provider.of<FileTransferProvider>(context, listen: false)
                  .selectedFiles
                  .addAll(widget.fileHistory.fileDetails!.files!
                      .map(
                        (e) => PlatformFile(
                          name: e.name ?? '',
                          size: e.size ?? 0,
                          path: getFilePath(e.name ?? ''),
                        ),
                      )
                      .toList());
              Provider.of<FileTransferProvider>(context, listen: false)
                  .notify();
              Provider.of<WelcomeScreenProvider>(context, listen: false)
                  .changeBottomNavigationIndex(0);
            },
            icon: AppVectors.icSendFile,
          )
        : SizedBox();
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
              isDownloaded = false;
            });
            await isFilesPresent(widget.fileHistory.fileDetails!);
            return;
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        isDownloading = false;

        isDownloaded = true;
      });
      await isFilesPresent(widget.fileHistory.fileDetails!);
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
    }
  }

  Future<void> isFilesPresent(FileTransfer files) async {
    isDownloaded = true;
    for (FileData i in files.files ?? []) {
      final bool isExist = await checkFileExist(data: i);
      if (!isExist) {
        isDownloaded = false;
      }
    }
    if (context.read<HistoryProvider>().isDownloadDone) {
      context.read<HistoryProvider>().resetIsDownloadDone();
    }
    setState(() {});
  }

  Future<bool> checkFileExist({required FileData data}) async {
    String filePath = getFilePath(data.name ?? '');

    File file = File(filePath);
    return await file.exists();
  }

  String getFilePath(String name) {
    return BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        name;
  }
}
