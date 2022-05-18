import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/labelled_circular_progress.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopReceivedFileDetails extends StatefulWidget {
  final FileTransfer? fileTransfer;
  final Key? key;
  DesktopReceivedFileDetails({this.fileTransfer, this.key});

  @override
  _DesktopReceivedFileDetailsState createState() =>
      _DesktopReceivedFileDetailsState();
}

class _DesktopReceivedFileDetailsState
    extends State<DesktopReceivedFileDetails> {
  int fileCount = 0, fileSize = 0;
  bool isDownloadAvailable = false,
      isDownloaded = false,
      isFilesAvailableOfline = true,
      isOverwrite = false;
  List<String?> existingFileNamesToOverwrite = [];
  Map<String?, Future> _futureBuilder = {};

  @override
  void initState() {
    super.initState();

    fileCount = widget.fileTransfer!.files!.length;
    widget.fileTransfer!.files!.forEach((element) {
      fileSize += element.size!;
    });

    var expiryDate = widget.fileTransfer!.date!.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    getFutureBuilders();
    isFilesAlreadyDownloaded();
  }

  String getDownloadDirectory(String name) {
    return MixedConstants.RECEIVED_FILE_DIRECTORY +
        Platform.pathSeparator +
        widget.fileTransfer!.sender! +
        Platform.pathSeparator +
        name;
  }

  getFutureBuilders() {
    widget.fileTransfer!.files!.forEach((element) {
      _futureBuilder[element.name] = CommonUtilityFunctions().isFilePresent(
        getDownloadDirectory(element.name!),
      );
    });
  }

  isFilesAlreadyDownloaded() async {
    widget.fileTransfer!.files!.forEach((element) async {
      String path = MixedConstants.RECEIVED_FILE_DIRECTORY +
          Platform.pathSeparator +
          (widget.fileTransfer!.sender ?? '') +
          Platform.pathSeparator +
          (element.name ?? '');
      File test = File(path);
      bool fileExists = await test.exists();
      if (fileExists == false) {
        if (mounted) {
          setState(() {
            isFilesAvailableOfline = false;
          });
        }
      } else {
        var fileLatsModified = await test.lastModified();
        if (fileLatsModified.isBefore(widget.fileTransfer!.date!)) {
          existingFileNamesToOverwrite.add(element.name);
          if (mounted) {
            setState(() {
              isOverwrite = true;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.selago,
      height: SizeConfig().screenHeight,
      width: SizeConfig().screenWidth * 0.45,
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextStrings().details,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        var _downloadPath =
                            (MixedConstants.ApplicationDocumentsDirectory ??
                                    '') +
                                Platform.pathSeparator +
                                (widget.fileTransfer!.sender ?? '');
                        BackendService.getInstance()
                            .doesDirectoryExist(path: _downloadPath);

                        await OpenFile.open(_downloadPath);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.save_alt_outlined, color: Colors.black),
                          SizedBox(width: 10),
                          Text(TextStrings().downloadsFolder,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    widget.fileTransfer!.isDownloading!
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Consumer<FileProgressProvider>(
                                builder: (_c, provider, _) {
                              var fileTransferProgress =
                                  provider.receivedFileProgress[
                                      widget.fileTransfer!.key!];

                              return getDownloadStatus(fileTransferProgress);
                            }),
                          )
                        : isDownloadAvailable
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: IconButton(
                                  icon: ((isDownloaded ||
                                              isFilesAvailableOfline) &&
                                          !isOverwrite)
                                      ? Icon(
                                          Icons.done,
                                          color: Color(0xFF08CB21),
                                          size: 25.toFont,
                                        )
                                      : Icon(
                                          Icons.download,
                                          color: Color(0xFF08CB21),
                                          size: 30,
                                        ),
                                  onPressed: () async {
                                    if (isOverwrite) {
                                      overwriteDialog();
                                      return;
                                    }

                                    downloadFiles();
                                  },
                                ),
                              )
                            : SizedBox(),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15.toHeight),
            Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 20.0,
                    children: List.generate(widget.fileTransfer!.files!.length,
                        (index) {
                      return Container(
                        width: 250,
                        child: ListTile(
                            title: Text(
                              widget.fileTransfer!.files![index].name!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.toFont,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              double.parse(widget
                                          .fileTransfer!.files![index].size
                                          .toString()) <=
                                      1024
                                  ? '${widget.fileTransfer!.files![index].size} ${TextStrings().kb}' +
                                      ' . ${widget.fileTransfer!.files![index].name!.split('.').last}'
                                  : '${(widget.fileTransfer!.files![index].size! / (1024 * 1024)).toStringAsFixed(2)} ${TextStrings().mb}' +
                                      ' . ${widget.fileTransfer!.files![index].name!.split('.').last}',
                              style: TextStyle(
                                color: ColorConstants.fadedText,
                                fontSize: 14.toFont,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            leading: FutureBuilder(
                                key: Key(
                                    widget.fileTransfer!.files![index].name!),
                                future: _futureBuilder[
                                    widget.fileTransfer!.files![index].name],
                                builder: (context, snapshot) {
                                  return snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.data != null
                                      ? InkWell(
                                          onTap: () {
                                            handleFileCLick(
                                              widget.fileTransfer!.files![index]
                                                  .name!,
                                            );
                                          },
                                          child: CommonUtilityFunctions()
                                              .thumbnail(
                                                  widget.fileTransfer!
                                                      .files![index].name
                                                      ?.split('.')
                                                      ?.last,
                                                  getDownloadDirectory(
                                                      widget.fileTransfer!
                                                          .files![index].name!),
                                                  isFilePresent: isOverwrite
                                                      ? false
                                                      : snapshot.data as bool),
                                        )
                                      : SizedBox();
                                }),
                            trailing: SizedBox()),
                      );
                    }),
                  ),
                )
              ],
            ),
            SizedBox(height: 15.toHeight),
            Row(
              children: <Widget>[
                Text(
                  '${fileCount} files . ',
                  style: CustomTextStyles.greyText15,
                ),
                fileSize > 1024
                    ? Text(
                        '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} ${TextStrings().mb}',
                        style: CustomTextStyles.greyText15)
                    : Text(
                        '${(fileSize).toStringAsFixed(2)} ${TextStrings().mb}',
                        style: CustomTextStyles.greyText15),
              ],
            ),
            SizedBox(height: 15.toHeight),
            Consumer<FileProgressProvider>(
              builder: (_context, provider, _widget) {
                var fileTransferProgress =
                    provider.receivedFileProgress[widget.fileTransfer!.key!];
                return RichText(
                  text: TextSpan(
                      text:
                          '${DateFormat("MM-dd-yyyy").format(widget.fileTransfer!.date!)}  |  ${DateFormat('kk: mm').format(widget.fileTransfer!.date!)}  | ',
                      style: CustomTextStyles.greyText15,
                      children: [
                        widget.fileTransfer!.isDownloading!
                            ? TextSpan(
                                text:
                                    '${getFileStateMessage(fileTransferProgress)}',
                                style: CustomTextStyles.blueRegular14)
                            : TextSpan(text: ''),
                      ]),
                );
              },
            ),
            SizedBox(height: 15.toHeight),
            SizedBox(height: 15.toHeight),
          ],
        ),
      ),
    );
  }

  overwriteDialog() {
    showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth),
            ),
            content: Container(
              width: 300.toWidth,
              padding: EdgeInsets.all(15.toFont),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: getOverwriteMessage(),
                      ),
                    ),
                    SizedBox(
                      height: 10.toHeight,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await downloadFiles();
                            },
                            child: Text(TextStrings().yes,
                                style: TextStyle(fontSize: 16.toFont))),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(TextStrings().buttonCancel,
                                style: TextStyle(
                                  fontSize: 16.toFont,
                                  fontWeight: FontWeight.normal,
                                )))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  handleFileCLick(String fileName) async {
    String filePath = getDownloadDirectory(fileName);
    File test = File(filePath);
    bool fileExists = await test.exists();
    if (fileExists) {
      await OpenFile.open(filePath);
    }
  }

  List<TextSpan> getOverwriteMessage() {
    List<TextSpan> textSpansMessage = [];
    if (existingFileNamesToOverwrite.length == 1) {
      textSpansMessage.add(
        TextSpan(
          children: [
            TextSpan(
                text: TextStrings().fileNamed,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                )),
            TextSpan(
                text: '${existingFileNamesToOverwrite[0]}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.bold)),
            TextSpan(
                text: TextStrings().alreadyExistsMsg,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                )),
          ],
        ),
      );
    } else if (existingFileNamesToOverwrite.length > 1) {
      textSpansMessage.add(TextSpan(
        text: TextStrings().fileExists,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.toFont,
          fontWeight: FontWeight.normal,
        ),
      ));

      existingFileNamesToOverwrite.forEach((element) {
        textSpansMessage.add(
          TextSpan(
            text: '\n$element',
            style: TextStyle(
                color: Colors.black,
                fontSize: 13.toFont,
                fontWeight: FontWeight.bold,
                height: 1.5),
          ),
        );
      });

      textSpansMessage.add(
        TextSpan(
            text: TextStrings().overWriteMsg,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.toFont,
              height: 2,
              fontWeight: FontWeight.normal,
            )),
      );
    }
    return textSpansMessage;
  }

  downloadFiles() async {
    var res = await Provider.of<HistoryProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .downloadFiles(
      widget.fileTransfer!.key!,
      widget.fileTransfer!.sender!,
      false,
    );

    if (res) {
      if (mounted) {
        getFutureBuilders();
        setState(() {
          isDownloaded = true;
          isOverwrite = false;
          isFilesAvailableOfline = true;
        });
      }

      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().fileDownloadd,
        bgColor: ColorConstants.successGreen,
      );

      await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .sendFileDownloadAcknowledgement(widget.fileTransfer!);
    } else {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings().downloadFailed,
        bgColor: ColorConstants.redAlert,
      );
    }
  }

  String getFileStateMessage(FileTransferProgress? fileTransferProgress) {
    if (fileTransferProgress == null) {
      return '';
    }

    var index = widget.fileTransfer!.files!
        .indexWhere((element) => element.name == fileTransferProgress.fileName);
    String fileState = '';
    if (fileTransferProgress.fileState == FileState.download) {
      fileState = 'Downloading';
    } else {
      fileState = 'Decrypting';
    }

    if (index != -1) {
      fileState =
          '${fileState} ${index + 1} of ${widget.fileTransfer!.files!.length} File(s)';
    }
    return fileState;
  }

  Widget getDownloadStatus(FileTransferProgress? fileTransferProgress) {
    Widget spinner = CircularProgressIndicator();

    if (fileTransferProgress == null) {
      return spinner;
    }

    if (fileTransferProgress.fileState == FileState.download &&
        fileTransferProgress.percent != null) {
      spinner = LabelledCircularProgressIndicator(
          value: (fileTransferProgress.percent! / 100));
    }

    return spinner;
  }
}
