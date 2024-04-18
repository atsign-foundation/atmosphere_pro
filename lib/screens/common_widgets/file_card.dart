import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileCard extends StatefulWidget {
  final PlatformFile fileDetail;
  final Function? deleteFunc;
  final Function? onTap;

  FileCard({
    Key? key,
    required this.fileDetail,
    this.deleteFunc,
    this.onTap,
  }) : super(key: key);

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  late Future _futureBuilder;
  @override
  void initState() {
    super.initState();
    getFutureBuilders();
  }

  getFutureBuilders() {
    _futureBuilder =
        CommonUtilityFunctions().isFilePresent(widget.fileDetail.path ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorConstants.textBoxBg,
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.toHeight),
        padding: EdgeInsets.fromLTRB(
          16.toWidth,
          12.toHeight,
          14.toWidth,
          12.toHeight,
        ),
        child: Row(
          children: [
            widget.fileDetail.path != null
                ? Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(right: 15),
                    child: FutureBuilder(
                      future: _futureBuilder,
                      builder: (BuildContext cotext, snapshot) {
                        return snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null
                            ? CommonUtilityFunctions().thumbnail(
                                widget.fileDetail.path!
                                    .split(Platform.pathSeparator)
                                    .last
                                    .split('.')
                                    .last,
                                widget.fileDetail.path,
                                isFilePresent: snapshot.data as bool)
                            : Container(
                                child: Icon(
                                  Icons.image,
                                  size: 30.toFont,
                                ),
                              );
                      },
                    ),
                  )
                : SvgPicture.asset(
                    AppVectors.icFile,
                  ),
            SizedBox(width: 6.toWidth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.fileDetail.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.toFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    AppUtils.getFileSizeString(
                      bytes: widget.fileDetail.size.toDouble(),
                      decimals: 2,
                    ),
                    style: TextStyle(
                      fontSize: 12.toFont,
                      color: ColorConstants.sidebarTextUnselected,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                widget.deleteFunc?.call();
              },
              child: SvgPicture.asset(
                AppVectors.icClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
