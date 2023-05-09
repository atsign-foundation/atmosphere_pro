import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../my_files/widgets/downloads_folders.dart';

class ContactAttachmentCard extends StatefulWidget {
  final FileTransfer fileTransfer;
  final FileData singleFile;
  final bool isShowDate;
  final EdgeInsetsGeometry? margin;

  const ContactAttachmentCard({
    Key? key,
    required this.fileTransfer,
    required this.singleFile,
    this.isShowDate = true,
    this.margin,
  }) : super(key: key);

  @override
  State<ContactAttachmentCard> createState() => _ContactAttachmentCardState();
}

class _ContactAttachmentCardState extends State<ContactAttachmentCard> {
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();
    initDownloads();
  }

  void initDownloads() async {
    isDownloaded = await isFilePresent(widget.singleFile.name ?? "");
    setState(() {
      isDownloaded;
    });
  }

  Future<bool> isFilePresent(String fileName) async {
    String filePath = BackendService.getInstance().downloadDirectory!.path +
        Platform.pathSeparator +
        fileName;

    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: widget.margin ??
          EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 5,
          ),
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.MILD_GREY,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: thumbnail(
                widget.singleFile.name?.split(".").last,
                BackendService.getInstance().downloadDirectory!.path +
                    Platform.pathSeparator +
                    widget.singleFile.name!,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.singleFile.name ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.isShowDate,
                      child: Text(
                        CommonUtilityFunctions()
                            .formatDateTime(widget.fileTransfer.date!),
                        style: TextStyle(
                          color: ColorConstants.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Consumer<FileProgressProvider>(
                      builder: (_c, provider, _) {
                        var fileTransferProgress = provider
                            .receivedFileProgress[widget.fileTransfer.key];

                        return CommonUtilityFunctions()
                                .checkForDownloadAvailability(
                          widget.fileTransfer,
                        )
                            ? fileTransferProgress != null
                                ? Image.asset(
                                    ImageConstants.icCloudDownloading,
                                  )
                                : isDownloaded
                                    ? SvgPicture.asset(
                                        AppVectors.icCloudDownloaded,
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          await downloadFiles(
                                            widget.fileTransfer,
                                            fileName: widget.singleFile.name,
                                          );
                                        },
                                        child: SvgPicture.asset(
                                          AppVectors.icDownloadFile,
                                        ),
                                      )
                            : SizedBox();
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await openFilePath(BackendService.getInstance()
                                .downloadDirectory!
                                .path +
                            Platform.pathSeparator +
                            widget.singleFile.name!);
                      },
                      child: SvgPicture.asset(
                        AppVectors.icSendFile,
                      ),
                    ),
                    Spacer(),
                    Text(
                      double.parse(widget.singleFile.size.toString()) <= 1024
                          ? '${widget.singleFile.size} ' + TextStrings().kb
                          : '${(widget.singleFile.size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                              TextStrings().mb,
                      style: TextStyle(
                        color: ColorConstants.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget thumbnail(String? extension, String path,
      {bool? isFilePresent = true}) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 50,
              width: 50,
              child: isFilePresent!
                  ? Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext _context, _, __) {
                        return Container(
                          child: Icon(
                            Icons.image,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.image,
                      size: 30,
                    ),
            ),
          )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: (snapshot.data == null)
                        ? Image.asset(
                            ImageConstants.videoLogo,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            videoThumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext _context, _, __) {
                              return Container(
                                child: Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Image.asset(
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
                    ),
                  ),
                ),
              );
  }

  Future<void> downloadFiles(
    FileTransfer? file, {
    String? fileName,
  }) async {
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
      return;
    }

    var result;
    if (fileName != null) {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadSingleFile(
        file.key,
        file.sender,
        false,
        fileName,
      );
    } else {
      result = await Provider.of<HistoryProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .downloadFiles(
        file.key,
        file.sender!,
        false,
      );
    }

    if (result is bool && result) {
      if (mounted) {
        setState(() {
          isDownloaded = true;
        });
      }
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(file);

      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
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
          isDownloaded = false;
        });
      }
    }
  }
}
