import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/utils/colors.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmationItemDelete extends StatefulWidget {
  final FileTransfer? receivedHistory;

  final String title;
  final Function onConfirmation;
  ConfirmationItemDelete(this.title, this.onConfirmation, this.receivedHistory);

  @override
  _ConfirmationItemDeleteState createState() => _ConfirmationItemDeleteState();
}

class _ConfirmationItemDeleteState extends State<ConfirmationItemDelete> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Platform.isAndroid || Platform.isIOS ? 300.toWidth : 250.toWidth,
      height:
          Platform.isAndroid || Platform.isIOS ? 300.toHeight : 220.toHeight,
      padding: EdgeInsets.all(15.toFont),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: CustomTextStyles.grey15, textAlign: TextAlign.justify),
            SizedBox(
              height: 20.toHeight,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.only(left: 22, right: 22)),
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onConfirmation();
                  },
                  child: Text(
                    'Delete only transfer history',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.only(left: 10, right: 10)),
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () async {
                    deleteTransferHistoryAndFiles();
                  },
                  child: Text(
                    'Delete transfer history and files',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.only(left: 85, right: 85)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    TextStrings().buttonCancel,
                    style: TextStyle(
                      fontSize: 16.toFont,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> deleteTransferHistoryAndFiles() async {
    Navigator.of(context).pop();
    await widget.onConfirmation();
    if (Platform.isAndroid || Platform.isIOS) {
      await Future.forEach(
        widget.receivedHistory!.files!,
        (FileData element) async {
          String filePath =
              BackendService.getInstance().downloadDirectory!.path +
                  Platform.pathSeparator +
                  element.name!;
          if (await CommonUtilityFunctions().isFilePresent(filePath)) {
            var file = File(filePath);
            file.deleteSync();
          }
        },
      );
      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .deletMyFileRecord(widget.receivedHistory!.key);
    } else {
      await Future.forEach(
        widget.receivedHistory!.files!,
        (FileData element) async {
          String filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
              Platform.pathSeparator +
              (widget.receivedHistory!.sender ?? '') +
              Platform.pathSeparator +
              (element.name ?? '');

          if (await CommonUtilityFunctions().isFilePresent(filePath)) {
            var file = File(filePath);
            if (await file.existsSync()) {
              file.deleteSync();
            }
          }
        },
      );

      await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
              listen: false)
          .deletMyFileRecord(widget.receivedHistory!.key);
    }
  }
}
