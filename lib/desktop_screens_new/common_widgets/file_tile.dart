import 'dart:io';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FileTile extends StatefulWidget {
  const FileTile({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.fileExt,
    required this.fileDate,
    required this.id,
    this.selectedFile = false,
  }) : super(key: key);

  final String fileName;
  final double fileSize;
  final String filePath;
  final String fileExt;
  final String fileDate;
  final bool selectedFile;
  final String? id;

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  String _filePath = '';
  String? sender;
  late MyFilesProvider myFilesProvider;

  @override
  void initState() {
    myFilesProvider = Provider.of<MyFilesProvider>(context, listen: false);
    findSenderAtsign();
    super.initState();
  }

  findSenderAtsign() {
    var i = myFilesProvider.myFiles
        .indexWhere((FileTransfer element) => element.key == widget.id);
    if (i != -1) {
      sender = myFilesProvider.myFiles[i].sender;
    }

    if (sender != null) {
      _filePath = MixedConstants.getFileDownloadLocationSync(sharedBy: sender) +
          Platform.pathSeparator +
          widget.fileName;
    } else {
      _filePath = widget.filePath;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.fileDate).toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    return Padding(
      padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: widget.selectedFile
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Container(
              width: 300,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: thumbnail(widget.fileExt, _filePath),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: widget.selectedFile
                    ? Theme.of(context).primaryColor
                    : ColorConstants.MILD_GREY,
              ),
            ),
            Container(
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fileName,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 10.toHeight),
                        Text(
                          "$shortDate $time",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppUtils.getFileSizeString(bytes: widget.fileSize),
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.gray,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
