import 'dart:convert';
import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
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

  Future<String> imageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future<void> openPreview() async {
    if (FileTypes.IMAGE_TYPES.contains(widget.data.name?.split(".").last)) {
      String nickname = "";
      String filePath = path;
      Uint8List imageBytes = base64Decode(await imageToBase64(filePath));
      final date = (widget.fileTransfer?.date ?? DateTime.now()).toLocal();
      final shortDate = DateFormat('dd/MM/yy').format(date);
      final time = DateFormat('HH:mm').format(date);
      for (var contact in GroupService().allContacts) {
        if (contact?.contact?.atSign == widget.fileTransfer?.sender) {
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
                child: InkWell(
                  onTap: () async {
                    await OpenFile.open(
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          (widget.data.name ?? ''),
                    );
                  },
                  child: Container(
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
                        Navigator.pop(context);
                        await FileUtils.moveToSendFile(
                            BackendService.getInstance()
                                    .downloadDirectory!
                                    .path +
                                Platform.pathSeparator +
                                widget.data.name!);
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
                          fileTransferId: widget.fileTransfer?.key,
                          onComplete: () {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
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
                                fontSize: 11,
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
                                fontSize: 11,
                                color: ColorConstants.oldSliver,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        (widget.data.name ?? ''),
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        double.parse(widget.data.size.toString()) <= 1024
                            ? '${widget.data.size} ' + TextStrings().kb
                            : '${(widget.data.size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                                TextStrings().mb,
                        style: TextStyle(
                          color: ColorConstants.grey,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      nickname.isNotEmpty
                          ? Text(
                              nickname,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        widget.fileTransfer?.sender ?? '',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 10),
                      // fileDetail.message.isNotNull
                      //     ?
                      if ((widget.fileTransfer?.notes ?? '').isNotEmpty) ...[
                        Text(
                          "Message",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        // : SizedBox(),
                        SizedBox(height: 5),
                        Text(
                          widget.fileTransfer?.notes ?? "",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ]
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
          (widget.data.name ?? ''));
    }
  }

  void showNoFileDialog(double deviceTextFactor) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              height: 200.0.toHeight,
              width: 300.0.toWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Text(
                    TextStrings().fileNotDownload,
                    style: CustomTextStyles.primaryBold17,
                  ),
                  Padding(padding: EdgeInsets.only(top: 30.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        height: 50.toHeight * deviceTextFactor,
                        isInverted: false,
                        buttonText: TextStrings().buttonClose,
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
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
                  await openPreview();
                } else {
                  showNoFileDialog(MediaQuery.of(context).textScaleFactor);
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
                                          style: CustomTextStyles.blackW60011,
                                        ),
                                        TextSpan(
                                          text: fileFormat,
                                          style: CustomTextStyles.blackW40011,
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
            SnackbarService().showSnackbar(
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
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );
      // send download acknowledgement
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(widget.fileTransfer!);
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
      }
    }
  }

  Future<bool> checkFileExist() async {
    String filePath = path;

    File file = File(filePath);
    return await file.exists();
  }
}
