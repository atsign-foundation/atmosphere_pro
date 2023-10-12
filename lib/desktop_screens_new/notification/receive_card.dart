import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:flutter/material.dart';

class ReceivedFileCard extends StatelessWidget {
  final FileHistory fileHistory;
  const ReceivedFileCard({
    Key? key,
    required this.fileHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fileHistory.fileDetails?.sender ?? '@kim'}',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Text(
            'Sent ${fileHistory.fileDetails?.files?.length} files',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          fileHistory.fileTransferObject?.notes != ""
              ? Text(
                  '"${fileHistory.fileTransferObject?.notes}"',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
