import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileListTile extends StatelessWidget {
  const FileListTile({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.fileExt,
    required this.fileDate,
    this.selectedFile = false,
  }) : super(key: key);

  final String fileName;
  final double fileSize;
  final String filePath;
  final String fileExt;
  final String fileDate;
  final bool selectedFile;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(fileDate).toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        key: UniqueKey(),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 49,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Icon(Icons.file_copy_outlined, size: 30),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${fileName}",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 6.toFont,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "$shortDate $time",
                    style: TextStyle(
                      fontSize: 10,
                      color: ColorConstants.oldSliver,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppUtils.getFileSizeString(
                bytes: fileSize,
                decimals: 2,
              ),
              style: TextStyle(
                fontSize: 10,
                color: ColorConstants.oldSliver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
