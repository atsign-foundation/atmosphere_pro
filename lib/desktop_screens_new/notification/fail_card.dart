import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:flutter/material.dart';

class FailCard extends StatelessWidget {
  final FileHistory fileHistory;

  const FailCard({Key? key, required this.fileHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Failed to send  ${fileHistory.fileDetails?.files?.length} files',
            style: TextStyle(
              fontSize: 11,
              color: ColorConstants.buttonHighLightColor,
            ),
          ),
          Text(
            getAtsignCount(fileHistory),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorConstants.buttonHighLightColor,
            ),
          ),
        ],
      ),
    );
  }

  String getAtsignCount(FileHistory fileHistory) {
    String msg = fileHistory.sharedWith?[0].atsign ?? '';

    if (fileHistory.sharedWith != null && fileHistory.sharedWith!.length > 1) {
      msg +=
          ' and ${fileHistory.sharedWith!.length - 1} ${fileHistory.sharedWith!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
  }
}
