import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorConstants.textBoxBg,
          ),
        ),
        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      fileDetail.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.toFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    AppUtils.getFileSizeString(
                      bytes: fileDetail.size.toDouble(),
                      decimals: 2,
                    ),
                    style: TextStyle(
                      fontSize: 9.toFont,
                      color: ColorConstants.sidebarTextUnselected,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                deleteFunc?.call();
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
