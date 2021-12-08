import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopReceivedFileDetails extends StatefulWidget {
  final FileTransfer fileTransfer;
  final UniqueKey key;
  DesktopReceivedFileDetails({this.fileTransfer, this.key});

  @override
  _DesktopReceivedFileDetailsState createState() =>
      _DesktopReceivedFileDetailsState();
}

class _DesktopReceivedFileDetailsState
    extends State<DesktopReceivedFileDetails> {
  int fileCount = 0, fileSize = 0;
  bool isDownloadAvailable = false;

  @override
  void initState() {
    fileCount = widget.fileTransfer.files.length;

    widget.fileTransfer.files.forEach((element) {
      fileSize += element.size;
    });

    var expiryDate = widget.fileTransfer.date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      isDownloadAvailable = true;
    }

    super.initState();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                            icon: Icon(
                              Icons.download,
                              color: Color(0xFF08CB21),
                              size: 30,
                            ),
                            onPressed: () async {
                              await Provider.of<HistoryProvider>(context,
                                      listen: false)
                                  .downloadFiles(
                                widget.fileTransfer.key,
                                widget.fileTransfer.sender,
                                false,
                              );
                            },
                          ),
                        )
                      : SizedBox(),
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
                              future: CommonFunctions().isFilePresent(
                                  MixedConstants.RECEIVED_FILE_DIRECTORY +
                                      '/' +
                                      widget.fileTransfer.files[index].name),
                              builder: (context, snapshot) {
                                return snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null
                                    ? InkWell(
                                        onTap: () async {
                                          await OpenFile.open(MixedConstants
                                                  .RECEIVED_FILE_DIRECTORY +
                                              '/' +
                                              widget.fileTransfer.files[index]
                                                  .name);
                                        },
                                        child: CommonFunctions().thumbnail(
                                            widget
                                                .fileTransfer.files[index].name
                                                ?.split('.')
                                                ?.last,
                                            MixedConstants
                                                    .RECEIVED_FILE_DIRECTORY +
                                                '/${widget.fileTransfer.files[index].name}',
                                            isFilePresent: snapshot.data),
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
}
