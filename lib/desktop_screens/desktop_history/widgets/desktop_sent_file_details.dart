import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopSentFileDetails extends StatefulWidget {
  final FileHistory? selectedFileData;
  Key? key;
  DesktopSentFileDetails({this.key, this.selectedFileData});

  @override
  _DesktopSentFileDetailsState createState() => _DesktopSentFileDetailsState();
}

class _DesktopSentFileDetailsState extends State<DesktopSentFileDetails> {
  int fileCount = 0, fileSize = 0;
  Map<String?, Future> _futureBuilder = {};

  @override
  void initState() {
    super.initState();
    fileCount = widget.selectedFileData!.fileDetails!.files!.length;
    widget.selectedFileData!.fileDetails!.files!.forEach((element) {
      fileSize += element.size!;
    });
    getFutureBuilders();
  }

  getFutureBuilders() {
    widget.selectedFileData!.fileDetails!.files!.forEach((element) {
      _futureBuilder[element.name] = CommonUtilityFunctions()
          .isFilePresent(MixedConstants.SENT_FILE_DIRECTORY + element.name!);
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
        children: <Widget>[
          Text('Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                  children: List.generate(
                      widget.selectedFileData!.fileDetails!.files!.length,
                      (index) {
                    return Container(
                      child: Container(
                        width: 250,
                        child: ListTile(
                          title: Text(
                            widget.selectedFileData!.fileDetails!.files![index]
                                .name!,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.toFont,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            double.parse(widget.selectedFileData!.fileDetails!
                                        .files![index].size
                                        .toString()) <=
                                    1024
                                ? '${widget.selectedFileData!.fileDetails!.files![index].size} Kb' +
                                    ' . ${widget.selectedFileData!.fileDetails!.files![index].name!.split('.').last}'
                                : '${(widget.selectedFileData!.fileDetails!.files![index].size! / (1024 * 1024)).toStringAsFixed(2)} Mb' +
                                    ' . ${widget.selectedFileData!.fileDetails!.files![index].name!.split('.').last} ',
                            style: TextStyle(
                              color: ColorConstants.fadedText,
                              fontSize: 14.toFont,
                            ),
                          ),
                          leading: InkWell(
                              onTap: () async {
                                String filePath =
                                    MixedConstants.DESKTOP_SENT_DIR +
                                        widget.selectedFileData!.fileDetails!
                                            .files![index].name!;

                                await OpenFile.open(filePath);
                              },
                              child: FutureBuilder(
                                  key: Key(widget.selectedFileData!.fileDetails!
                                      .files![index].name!),
                                  future: _futureBuilder[widget
                                      .selectedFileData!
                                      .fileDetails!
                                      .files![index]
                                      .name],
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.data != null
                                        ? InkWell(
                                            onTap: () async {
                                              String filePath = MixedConstants
                                                      .DESKTOP_SENT_DIR +
                                                  widget
                                                      .selectedFileData!
                                                      .fileDetails!
                                                      .files![index]
                                                      .name!;

                                              if (await File(filePath)
                                                  .exists()) {
                                                await OpenFile.open(filePath);
                                              }
                                            },
                                            child: CommonUtilityFunctions()
                                                .thumbnail(
                                                    widget
                                                        .selectedFileData!
                                                        .fileDetails!
                                                        .files![index]
                                                        .name
                                                        ?.split('.')
                                                        ?.last,
                                                    MixedConstants
                                                            .DESKTOP_SENT_DIR +
                                                        widget
                                                            .selectedFileData!
                                                            .fileDetails!
                                                            .files![index]
                                                            .name!,
                                                    isFilePresent:
                                                        snapshot.data as bool),
                                          )
                                        : SizedBox();
                                  })),
                          trailing: IconButton(
                            icon: (widget.selectedFileData!.fileDetails!
                                            .files![index].isUploaded !=
                                        null &&
                                    widget.selectedFileData!.fileDetails!
                                        .files![index].isUploaded!)
                                ? SizedBox()
                                : (widget.selectedFileData!.fileDetails!
                                                .files![index].isUploading !=
                                            null &&
                                        widget.selectedFileData!.fileDetails!
                                            .files![index].isUploading!)
                                    ? TypingIndicator(
                                        showIndicator: true,
                                        flashingCircleBrightColor:
                                            ColorConstants.dullText,
                                        flashingCircleDarkColor:
                                            ColorConstants.fadedText,
                                      )
                                    : Icon(Icons.refresh),
                            onPressed: () async {
                              await Provider.of<FileTransferProvider>(context,
                                      listen: false)
                                  .reuploadFiles(
                                      widget.selectedFileData!.fileDetails!
                                          .files!,
                                      index,
                                      widget.selectedFileData!);
                            },
                          ),
                        ),
                      ),
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
                '${fileCount.toString()} files . ',
                style: CustomTextStyles.greyText15,
              ),
              fileSize > 1024
                  ? Text('${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: CustomTextStyles.greyText15)
                  : Text('${fileSize.toStringAsFixed(2)} KB',
                      style: CustomTextStyles.greyText15),
            ],
          ),
          // SizedBox(height: 15.toHeight),
          // Text('Successfully transfered', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          Text(
              '${DateFormat("MM-dd-yyyy").format(widget.selectedFileData!.fileDetails!.date!)}  |  ${DateFormat('kk: mm').format(widget.selectedFileData!.fileDetails!.date!)}',
              style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          // Text('To', style: CustomTextStyles.greyText15),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 20.toHeight),
          //   child: Divider(height: 5),
          // ),
          widget.selectedFileData != null
              ? DesktopTranferOverlappingContacts(
                  key: Key(
                      widget.selectedFileData!.fileTransferObject!.transferId),
                  selectedList: widget.selectedFileData!.sharedWith,
                  fileHistory: widget.selectedFileData)
              : SizedBox()
        ],
      ),
    );
  }
}
