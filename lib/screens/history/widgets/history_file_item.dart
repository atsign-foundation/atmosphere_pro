import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recent.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
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

class HistoryFileItem extends StatefulWidget {
  final FileTransfer? fileTransfer;
  final HistoryType? type;
  final FileData data;

  const HistoryFileItem({
    Key? key,
    required this.type,
    required this.fileTransfer,
    required this.data,
  });

  @override
  State<HistoryFileItem> createState() => _HistoryFileItemState();
}

class _HistoryFileItemState extends State<HistoryFileItem> {
  String path = '';
  bool isDownloading = false;
  late bool canDownload = CommonUtilityFunctions()
      .isFileDownloadAvailable(widget.fileTransfer?.date ?? DateTime.now());

  @override
  void initState() {
    getFilePath();
    super.initState();
  }

  void getFilePath() async {
    path = widget.type == HistoryType.received
        ? BackendService.getInstance().downloadDirectory!.path +
            Platform.pathSeparator +
            (widget.data.name ?? '')
        : await MixedConstants.getFileSentLocation() +
            Platform.pathSeparator +
            (widget.data.name ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String fileFormat = '.${widget.data.name?.split('.').last}';
    return Slidable(
      endActionPane: canDownload || File(path).existsSync()
          ? ActionPane(
              motion: ScrollMotion(),
              extentRatio: 0.4,
              children: [
                if (!File(path).existsSync()) ...[
                  SizedBox(width: 4),
                  widget.type == HistoryType.received
                      ? buildDownloadButton()
                      : SizedBox.shrink(),
                ],
                if (File(path).existsSync()) ...[
                  SizedBox(width: 4),
                  buildTransferButton(),
                  SizedBox(width: 4),
                  buildDeleteButton(),
                ]
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                if (File(path).existsSync()) {
                  await CommonUtilityFunctions().openPreview(
                    context: context,
                    date: widget.fileTransfer?.date ?? DateTime.now(),
                    fileName: widget.data.name ?? '',
                    filePath: path,
                    key: widget.fileTransfer?.key ?? '',
                    note: widget.fileTransfer?.notes ?? '',
                    sender: widget.fileTransfer?.sender ?? '',
                    size: widget.data.size ?? 0,
                  );
                } else {
                  CommonUtilityFunctions().showNoFileDialog(
                    deviceTextFactor: MediaQuery.of(context).textScaleFactor,
                    isFileNotFound: false,
                  );
                }
              },
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(minHeight: 52),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: ColorConstants.fileItemColor,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 44),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 12, 12, 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.data.name
                                              ?.replaceAll(fileFormat, ''),
                                          style: CustomTextStyles.blackW60012,
                                        ),
                                        TextSpan(
                                          text: fileFormat,
                                          style: CustomTextStyles.blackW40012,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${(widget.data.size! / (1024 * 1024)).toStringAsFixed(2)} Mb',
                                  style: CustomTextStyles.oldSliverW400S12,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                      child: SizedBox(
                        width: 44,
                        child: thumbnail(
                          fileFormat.substring(1),
                          path,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: File(path).existsSync() ? 8 : 12),
          if (File(path).existsSync())
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstants.lightGreen,
              ),
              child: Center(
                child: Icon(
                  Icons.done_all,
                  size: 20,
                  color: ColorConstants.textGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget thumbnail(String? extension, String path) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? File(path).existsSync()
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _context, _, __) {
                  return Container(
                    child: Icon(
                      Icons.image,
                    ),
                  );
                },
              )
            : Icon(
                Icons.image,
              )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => snapshot.data == null
                    ? Center(
                        child: Image.asset(
                          ImageConstants.videoLogo,
                          width: 24,
                          height: 24,
                          color: Colors.black,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.memory(
                        videoThumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext _context, _, __) {
                          return Icon(
                            Icons.image,
                          );
                        },
                      ),
              )
            : Image.asset(
                FileTypes.PDF_TYPES.contains(extension)
                    ? ImageConstants.pdfLogo
                    : FileTypes.AUDIO_TYPES.contains(extension)
                        ? ImageConstants.musicLogo
                        : FileTypes.WORD_TYPES.contains(extension)
                            ? ImageConstants.wordLogo
                            : FileTypes.EXEL_TYPES.contains(extension)
                                ? ImageConstants.exelLogo
                                : FileTypes.TEXT_TYPES.contains(extension)
                                    ? ImageConstants.txtLogo
                                    : ImageConstants.unknownLogo,
                fit: BoxFit.cover,
              );
  }

  Widget buildDownloadButton() {
    return Consumer<FileProgressProvider>(
      builder: (context, provider, child) {
        var fileTransferProgress =
            provider.receivedFileProgress[widget.fileTransfer?.key];
        return fileTransferProgress != null &&
                fileTransferProgress.fileName == widget.data.name
            ? Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: SvgPicture.asset(
                        AppVectors.icCloudDownloading,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: (fileTransferProgress.percent ?? 0) / 100,
                        strokeWidth: 1,
                        color: ColorConstants.downloadIndicatorColor,
                      ),
                    ),
                  ),
                ],
              )
            : File(path).existsSync()
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
                    : buildIconButton(
                        onTap: () async {
                          await downloadFiles();
                        },
                        icon: AppVectors.icDownloadFile,
                      );
      },
    );
  }

  Widget buildTransferButton() {
    return buildIconButton(
      onTap: () {
        Provider.of<FileTransferProvider>(context, listen: false)
            .selectedFiles
            .add(PlatformFile(
              name: widget.data.name ?? '',
              size: widget.data.size ?? 0,
              path: path,
            ));
        Provider.of<FileTransferProvider>(context, listen: false).notify();
        Provider.of<WelcomeScreenProvider>(context, listen: false)
            .changeBottomNavigationIndex(0);
      },
      icon: AppVectors.icSendFile,
    );
  }

  Widget buildDeleteButton() {
    return buildIconButton(
      onTap: () {
        CommonUtilityFunctions().showConfirmationDialog(
          () {
            File(path).deleteSync();
            SnackBarService().showSnackBar(
              context,
              "Successfully deleted the file",
              bgColor: ColorConstants.successColor,
            );
            Provider.of<HistoryProvider>(context, listen: false).notify();
          },
          'Are you sure you want to delete ${widget.data.name}?',
        );
      },
      icon: AppVectors.icDeleteFile,
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
        width: 32,
        height: 32,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> downloadFiles() async {
    setState(() {
      isDownloading = true;
    });
    var fileTransferProgress = Provider.of<FileProgressProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .receivedFileProgress[widget.fileTransfer?.key];

    if (fileTransferProgress != null) {
      return; //returning because download is still in progress
    }
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
      setState(() {
        isDownloading = false;
      });
      return;
    }

    var result;
    if (widget.data.name != null) {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadSingleFile(
        widget.fileTransfer?.key ?? '',
        widget.fileTransfer?.sender,
        true,
        widget.data.name ?? '',
      );
    } else {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadFiles(
        widget.fileTransfer?.key ?? '',
        widget.fileTransfer?.sender ?? '',
        true,
      );
    }

    if (result is bool && result) {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(widget.fileTransfer!);
      Provider.of<HistoryProvider>(context, listen: false).notify();
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownload,
        bgColor: ColorConstants.successGreen,
      );
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(widget.fileTransfer!);
    } else if (result is bool && !result) {
      SnackBarService().showSnackBar(
        NavService.navKey.currentContext!,
        TextStrings().downloadFailed,
        bgColor: ColorConstants.redAlert,
      );
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  Future<bool> checkFileExist() async {
    String filePath = path;

    File file = File(filePath);
    return await file.exists();
  }
}
