import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileTile extends StatelessWidget {
  const FileTile({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.fileExt,
    required this.fileDate,
    this.selectedFileName = "",
  }) : super(key: key);

  final String fileName;
  final double fileSize;
  final String filePath;
  final String fileExt;
  final String fileDate;
  final String selectedFileName;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(fileDate).toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    return Padding(
      padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selectedFileName == fileName
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
                child: thumbnail(fileExt, filePath),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: selectedFileName == fileName
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
                          fileName,
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
                    AppUtils.getFileSizeString(bytes: fileSize),
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
