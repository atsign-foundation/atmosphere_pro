import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ImageViewWidget extends StatelessWidget {
  final FilesDetail image;

  const ImageViewWidget({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(image.date ?? "").toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 31,
              top: 16,
              bottom: 16,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 33,
              ),
            ),
          ),
          Expanded(
            child: Container(
              // height: double.infinity,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 33),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(
                    File(image.filePath ?? ''),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: SvgPicture.asset(
                    AppVectors.icDownloadFile,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: SvgPicture.asset(
                      AppVectors.icSendFile,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: SvgPicture.asset(
                    AppVectors.icDeleteFile,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Container(
            height: 175,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 16, 18, 16),
            margin: EdgeInsets.symmetric(horizontal: 33),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                Text(
                  "${image.fileName}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppUtils.getFileSizeString(
                    bytes: image.size ?? 0,
                    decimals: 2,
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorConstants.oldSliver,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "${(image.contactName ?? '').split("@")[1]}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "${image.contactName}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 13),
                Text(
                  "Message:",
                  style: TextStyle(
                    color: ColorConstants.textLightGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "${image.date}",
                  style: TextStyle(
                    color: ColorConstants.textLightGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
