import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_file_function_list.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopHistoryFileItem extends StatefulWidget {
  final FileData data;
  final FileTransfer fileTransfer;
  final int index;
  final HistoryType type;

  const DesktopHistoryFileItem({
    Key? key,
    required this.data,
    required this.fileTransfer,
    required this.index,
    required this.type,
  });

  @override
  State<DesktopHistoryFileItem> createState() => _DesktopHistoryFileItemState();
}

class _DesktopHistoryFileItemState extends State<DesktopHistoryFileItem> {
  String filePath = '';
  late String fileFormat;
  bool isDownloading = false;
  late bool isDownloaded = File(filePath).existsSync();

  @override
  void initState() {
    super.initState();
    fileFormat = '.${widget.data.name?.split('.').last}';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getFilePath();
    });
  }

  Future<void> getFilePath() async {
    final result = widget.type == HistoryType.received
        ? await MixedConstants.getFileDownloadLocation(
            sharedBy: widget.fileTransfer.sender)
        : await MixedConstants.getFileSentLocation();
    setState(() {
      filePath = result + Platform.pathSeparator + (widget.data.name ?? "");
    });
  }

  Future<void> downloadFiles(FileData file) async {
    if (isDownloading) {
      SnackbarService().showSnackbar(
        context,
        'File is downloading!',
        bgColor: ColorConstants.orange,
      );
      return;
    }
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
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            File test = File(filePath);
            bool fileExists = await test.exists();
            fileExists
                ? await OpenFile.open(filePath)
                : CommonUtilityFunctions()
                        .checkForDownloadAvailability(widget.fileTransfer)
                    ? await downloadFiles(widget.data)
                    : CommonUtilityFunctions().showFileHasExpiredDialog(
                        MediaQuery.textScaleFactorOf(context),
                      );
          },
          child: buildFileCard(),
        ),
        if (File(filePath).existsSync()) buildMarkRead(),
      ],
    );
  }

  Widget buildFileCard() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          constraints: BoxConstraints(minHeight: 52),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorConstants.fileItemColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 50),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: buildContent(),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 8,
          bottom: 8,
          left: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(7),
            ),
            child: SizedBox(
              width: 50,
              child: thumbnail(
                fileFormat.substring(1),
                filePath,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.data.name?.replaceAll(fileFormat, ''),
                      style: CustomTextStyles.blackW60010,
                    ),
                    TextSpan(
                      text: fileFormat,
                      style: CustomTextStyles.blackW40010,
                    )
                  ],
                ),
              ),
              if (widget.type != HistoryType.send) buildSizeText(),
            ],
          ),
        ),
        SizedBox(width: 4),
        widget.type == HistoryType.send
            ? buildSizeText()
            : DesktopFileFunctionList(
                filePath: filePath,
                date: widget.fileTransfer.date ?? DateTime.now(),
                idKey: widget.fileTransfer.key,
                name: widget.data.name ?? '',
                size: widget.data.size ?? 0,
                isDownloaded: isDownloaded,
                isDownloading: isDownloading,
              ),
      ],
    );
  }

  Widget buildSizeText() {
    return Text(
      '${(widget.data.size! / (1024 * 1024)).toStringAsFixed(2)} Mb',
      style: CustomTextStyles.oldSliverW400S10,
    );
  }

  Widget buildMarkRead() {
    return Positioned(
      top: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: ColorConstants.lightGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: ColorConstants.shadowGreen,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      blurStyle: BlurStyle.normal)
                ]),
            child: Icon(
              Icons.done_all,
              size: 16,
              color: ColorConstants.textGreen,
            ),
          ),
        ],
      ),
    );
  }
}
