import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopReceivedFileDetails extends StatefulWidget {
  final FileTransfer fileTransfer;
  final Key key;
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
  List<String> existingFileNamesToOverwrite = [];
  Map<String, Future> _futureBuilder = {};

  @override
  void initState() {
    super.initState();

    fileCount = widget.fileTransfer.files.length;
    widget.fileTransfer.files.forEach((element) {
      fileSize += element.size;
    });

    var expiryDate = widget.fileTransfer.date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    getFutureBuilders();
    isFilesAlreadyDownloaded();
  }

  String getDownloadDirectory(String name) {
    return MixedConstants.RECEIVED_FILE_DIRECTORY +
        Platform.pathSeparator +
        widget.fileTransfer.sender +
        Platform.pathSeparator +
        name;
  }

  getFutureBuilders() {
    widget.fileTransfer.files.forEach((element) {
      _futureBuilder[element.name] = CommonUtilityFunctions().isFilePresent(
        getDownloadDirectory(element.name),
      );
    });
  }

  isFilesAlreadyDownloaded() async {
    widget.fileTransfer.files.forEach((element) async {
      String path = MixedConstants.RECEIVED_FILE_DIRECTORY +
          Platform.pathSeparator +
          widget.fileTransfer.sender +
          Platform.pathSeparator +
          element.name;
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
        if (fileLatsModified.isBefore(widget.fileTransfer.date)) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Details',
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
                          '${MixedConstants.ApplicationDocumentsDirectory}/${widget.fileTransfer.sender}';
                      BackendService.getInstance()
                          .doesDirectoryExist(path: _downloadPath);

                      await OpenFile.open(_downloadPath);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.save_alt_outlined, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Downloads folder',
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  widget.fileTransfer.isDownloading
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator()),
                        )
                      : isDownloadAvailable
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: IconButton(
                                icon:
                                    ((isDownloaded || isFilesAvailableOfline) &&
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
                  children:
                      List.generate(widget.fileTransfer.files.length, (index) {
                    return Container(
                      width: 250,
                      child: ListTile(
                          title: Text(
                            widget.fileTransfer.files[index]?.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.toFont,
                            ),
                          ),
                          subtitle: Text(
                            double.parse(widget.fileTransfer.files[index].size
                                        .toString()) <=
                                    1024
                                ? '${widget.fileTransfer.files[index].size} Kb' +
                                    ' . ${widget.fileTransfer.files[index].name.split('.').last}'
                                : '${(widget.fileTransfer.files[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb' +
                                    ' . ${widget.fileTransfer.files[index].name.split('.').last}',
                            style: TextStyle(
                              color: ColorConstants.fadedText,
                              fontSize: 14.toFont,
                            ),
                          ),
                          leading: FutureBuilder(
                              key: Key(widget.fileTransfer.files[index].name),
                              future: _futureBuilder[
                                  widget.fileTransfer.files[index].name],
                              builder: (context, snapshot) {
                                return snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null
                                    ? InkWell(
                                        onTap: () {
                                          handleFileCLick(
                                            widget
                                                .fileTransfer.files[index].name,
                                          );
                                        },
                                        child: CommonUtilityFunctions()
                                            .thumbnail(
                                                widget.fileTransfer.files[index]
                                                    .name
                                                    ?.split('.')
                                                    ?.last,
                                                getDownloadDirectory(widget
                                                    .fileTransfer
                                                    .files[index]
                                                    .name),
                                                isFilePresent: isOverwrite
                                                    ? false
                                                    : snapshot.data),
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
                  ? Text('${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: CustomTextStyles.greyText15)
                  : Text('${(fileSize).toStringAsFixed(2)} MB',
                      style: CustomTextStyles.greyText15),
            ],
          ),
          SizedBox(height: 15.toHeight),
          Text(
              '${DateFormat("MM-dd-yyyy").format(widget.fileTransfer.date)}  |  ${DateFormat('kk: mm').format(widget.fileTransfer.date)}',
              style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          SizedBox(height: 15.toHeight),
        ],
      ),
    );
  }

  overwriteDialog() {
    showDialog(
        context: NavService.navKey.currentContext,
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
                            child: Text('Yes',
                                style: TextStyle(fontSize: 16.toFont))),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: TextStyle(fontSize: 16.toFont)))
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
                text: 'A file named ',
                style: TextStyle(color: Colors.black, fontSize: 15.toFont)),
            TextSpan(
                text: '${existingFileNamesToOverwrite[0]}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.bold)),
            TextSpan(
                text: ' already exists. Do you want to overwrite it?',
                style: TextStyle(color: Colors.black, fontSize: 15.toFont)),
          ],
        ),
      );
    } else if (existingFileNamesToOverwrite.length > 1) {
      textSpansMessage.add(TextSpan(
        text: 'These files already exist: ',
        style: TextStyle(color: Colors.black, fontSize: 15.toFont),
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
            text: '\nDo you want to overwrite them?',
            style:
                TextStyle(color: Colors.black, fontSize: 15.toFont, height: 2)),
      );
    }
    return textSpansMessage;
  }

  downloadFiles() async {
    var res = await Provider.of<HistoryProvider>(context, listen: false)
        .downloadFiles(
      widget.fileTransfer.key,
      widget.fileTransfer.sender,
      false,
    );

    if (res) {
      if (mounted) {
        getFutureBuilders();
        setState(() {
          isDownloaded = true;
          isOverwrite = false;
        });
      }

      await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .sendFileDownloadAcknowledgement(widget.fileTransfer);
    }
  }
}
