import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recent.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ContactAttachmentCard extends StatefulWidget {
  final FileTransfer fileTransfer;
  final FileData singleFile;
  final bool isShowDate;
  final EdgeInsetsGeometry? margin;
  final bool fromContact;

  const ContactAttachmentCard({
    Key? key,
    required this.fileTransfer,
    required this.singleFile,
    this.isShowDate = true,
    this.margin,
    this.fromContact = false,
  });

  @override
  State<ContactAttachmentCard> createState() => _ContactAttachmentCardState();
}

class _ContactAttachmentCardState extends State<ContactAttachmentCard>
    with TickerProviderStateMixin {
  bool isDownloaded = false;
  bool isDownloading = false;
  String filePath = '';

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
    filePath = await MixedConstants.getFileDownloadLocation(
            sharedBy: widget.fileTransfer.sender) +
        Platform.pathSeparator +
        fileName;

    File file = File(filePath);
    bool fileExists = await file.exists();
    return fileExists;
  }

  Future<void> moveToTransferScreen() async {
    FileTransferProvider.appClosedSharedFiles.add(
      PlatformFile(
        name: widget.singleFile.name ?? '',
        size: widget.singleFile.size ?? 0,
        path: filePath,
        bytes: File(filePath).readAsBytesSync(),
      ),
    );

    Provider.of<FileTransferProvider>(context, listen: false).setFiles();
    await DesktopSetupRoutes.nested_pop();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDownloading
          ? null
          : () async {
              bool isExist = await isFilePresent(widget.singleFile.name ?? '');
              if (isExist) {
                await CommonUtilityFunctions().openPreview(
                  context: context,
                  size: widget.singleFile.size ?? 0,
                  sender: widget.fileTransfer.sender ?? '',
                  note: widget.fileTransfer.notes ?? '',
                  filePath: filePath,
                  fileName: widget.singleFile.name ?? '',
                  date: widget.fileTransfer.date ?? DateTime.now(),
                  key: widget.fileTransfer.key,
                );
              }
            },
      child: Container(
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: thumbnail(
                  widget.singleFile.name?.split(".").last,
                  filePath,
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
                          return fileTransferProgress != null &&
                                  fileTransferProgress.fileName ==
                                      widget.singleFile.name
                              ? Stack(
                                  children: [
                                    Center(
                                      child: SvgPicture.asset(
                                        AppVectors.icCloudDownloading,
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          value:
                                              (fileTransferProgress.percent ??
                                                      0) /
                                                  100,
                                          strokeWidth: 1,
                                          color: ColorConstants
                                              .downloadIndicatorColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : isDownloaded
                                  ? SvgPicture.asset(
                                      AppVectors.icCloudDownloaded,
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    )
                                  : isDownloading
                                      ? SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            color: ColorConstants
                                                .downloadIndicatorColor,
                                          ),
                                        )
                                      : (CommonUtilityFunctions()
                                              .isFileDownloadAvailable(
                                          widget.fileTransfer.date!,
                                        ))
                                          ? InkWell(
                                              onTap: () async {
                                                await downloadFiles();
                                              },
                                              child: SvgPicture.asset(
                                                AppVectors.icDownloadFile,
                                                width: 28,
                                                height: 28,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : SizedBox.shrink();
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      isDownloaded
                          ? GestureDetector(
                              onTap: () async {
                                await moveToTransferScreen();
                              },
                              child: SvgPicture.asset(
                                AppVectors.icSendFile,
                              ),
                            )
                          : SizedBox(),
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
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              ImageConstants.videoLogo,
                              fit: BoxFit.cover,
                            ),
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

  Future<void> downloadFiles() async {
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
      SnackBarService().showSnackBar(
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
      widget.singleFile.name ?? '',
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
        SnackBarService().showSnackBar(
          NavService.navKey.currentContext!,
          TextStrings().fileDownload,
          bgColor: ColorConstants.successGreen,
        );
      }
    } else if (result is bool && !result) {
      SnackBarService().showSnackBar(
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
}
