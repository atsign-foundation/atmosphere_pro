import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';

class SendingFileCard extends StatelessWidget {
  final FLUSHBAR_STATUS? flushbarStatus;
  final FileTransfer? fileTransfer;
  const SendingFileCard({
    Key? key,
    this.flushbarStatus,
    this.fileTransfer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flushbarStatus == FLUSHBAR_STATUS.SENDING && fileTransfer != null
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sending ${fileTransfer!.files?.length ?? 0} files',
                  style: TextStyle(fontSize: 11),
                ),
                Text(
                  getAtsignCountFromFileTransfer(fileTransfer!),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                LinearProgressIndicator()
              ],
            ),
          )
        : SizedBox();
  }

  String getAtsignCountFromFileTransfer(FileTransfer fileTransfer) {
    String msg = fileTransfer.atSigns?[0] ?? '';

    if (fileTransfer.atSigns != null && fileTransfer.atSigns!.length > 1) {
      msg +=
          ' and ${fileTransfer.atSigns!.length - 1} ${fileTransfer.atSigns!.length - 1 > 1 ? "others" : "other"} ';
    }
    return msg;
  }
}
