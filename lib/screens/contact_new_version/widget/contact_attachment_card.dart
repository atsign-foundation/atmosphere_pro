import 'dart:convert';
import 'dart:io';

import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class ContactAttachmentCard extends StatefulWidget {
  final FileTransfer fileTransfer;
  final FileData singleFile;
  final bool isShowDate;
  final EdgeInsetsGeometry? margin;
  final Function()? onAction;
  final bool fromContact;

  const ContactAttachmentCard({
    Key? key,
    required this.fileTransfer,
    required this.singleFile,
    this.isShowDate = true,
    this.margin,
    this.fromContact = false,
    this.onAction,
  });

  @override
  State<ContactAttachmentCard> createState() => _ContactAttachmentCardState();
}

class _ContactAttachmentCardState extends State<ContactAttachmentCard>
    with TickerProviderStateMixin {
  bool isDownloaded = false;
  bool isDownloading = false;

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
    return InkWell(
      onTap: isDownloading
          ? null
          : () async {
              bool isExist = await isFilePresent(widget.singleFile.name ?? '');
              if (isExist) {
                await openPreview().whenComplete(() => widget.onAction?.call());
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
                          print(fileTransferProgress?.percent);
                          if (fileTransferProgress?.percent == null &&
                              fileTransferProgress?.fileName ==
                                  widget.singleFile.name) {
                             isDownloaded = true;
                          }

                          return CommonUtilityFunctions()
                                  .checkForDownloadAvailability(
                            widget.fileTransfer,
                          )
                              ? fileTransferProgress?.fileName ==
                                          widget.singleFile.name &&
                                      fileTransferProgress != null
                                  ? Stack(
                                      children: [
                                        SvgPicture.asset(
                                          AppVectors.icCloudDownloading,
                                        ),
                                        Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              value: (fileTransferProgress
                                                          .percent ??
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
                      isDownloaded
                          ? GestureDetector(
                              onTap: () async {
                                if (widget.fromContact) {
                                  Navigator.pop(context);
                                }
                                await FileUtils.moveToSendFile(
                                    BackendService.getInstance()
                                            .downloadDirectory!
                                            .path +
                                        Platform.pathSeparator +
                                        widget.singleFile.name!);
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

  Future<void> downloadFiles(
    FileTransfer? file, {
    String? fileName,
    bool isPreview = false,
  }) async {
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
          if (!isPreview) isDownloading = false;
          isDownloaded = true;
        });
      }
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .saveNewDataInMyFiles(file);
      print(file.url);
      widget.onAction?.call();
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
          if (!isPreview) isDownloading = false;
          isDownloaded = false;
        });
      }
    }
  }

  Future<void> openPreview() async {
    if (FileTypes.IMAGE_TYPES
        .contains(widget.singleFile.name?.split(".").last)) {
      String nickname = "";
      String filePath = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          widget.singleFile.name!;
      Uint8List imageBytes = base64Decode(await imageToBase64(filePath));
      final date = (widget.fileTransfer.date ?? DateTime.now()).toLocal();
      final shortDate = DateFormat('dd/MM/yy').format(date);
      final time = DateFormat('HH:mm').format(date);
      for (var contact in GroupService().allContacts) {
        if (contact?.contact?.atSign == widget.fileTransfer.sender) {
          nickname = contact?.contact?.tags?["nickname"] ?? "";
          break;
        }
      }
      await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (_) => Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(NavService.navKey.currentContext!);
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  // height: double.infinity,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 33),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: MemoryImage(
                        imageBytes,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: SvgPicture.asset(
                      AppVectors.icCloudDownloaded,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.fromContact) {
                          Navigator.pop(context);
                        }
                        Navigator.pop(context);
                        await FileUtils.moveToSendFile(
                            BackendService.getInstance()
                                    .downloadDirectory!
                                    .path +
                                Platform.pathSeparator +
                                widget.singleFile.name!);
                      },
                      child: SvgPicture.asset(
                        AppVectors.icSendFile,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () async {
                        await FileUtils.deleteFile(
                          filePath,
                          fileTransferId: widget.fileTransfer.key,
                          onComplete: () {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ).then((value) {
                          setState(() {
                            isDownloaded = false;
                          });
                        });
                      },
                      child: SvgPicture.asset(
                        AppVectors.icDeleteFile,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "$shortDate",
                              style: TextStyle(
                                fontSize: 10,
                                color: ColorConstants.oldSliver,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 8,
                              color: Color(0xFFD7D7D7),
                              margin: EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                            ),
                            Text(
                              "$time",
                              style: TextStyle(
                                fontSize: 10,
                                color: ColorConstants.oldSliver,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        (widget.singleFile.name ?? ''),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        double.parse(widget.singleFile.size.toString()) <= 1024
                            ? '${widget.singleFile.size} ' + TextStrings().kb
                            : '${(widget.singleFile.size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                                TextStrings().mb,
                        style: TextStyle(
                          color: ColorConstants.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      nickname.isNotEmpty
                          ? Text(
                              nickname,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        widget.fileTransfer.sender ?? '',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 10),
                      // fileDetail.message.isNotNull
                      //     ?
                      Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      // : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        widget.fileTransfer.notes ?? "",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      await OpenFile.open(BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          (widget.singleFile.name ?? ''));
    }
  }

  Future<String> imageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}
