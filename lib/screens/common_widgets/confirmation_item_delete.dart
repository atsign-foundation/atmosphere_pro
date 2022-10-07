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
      width: 300.toWidth,
      height: 300.toHeight,
      padding: EdgeInsets.all(15.toFont),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: CustomTextStyles.grey15),
            SizedBox(
              height: 20.toHeight,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    TextStrings().buttonCancel,
                    style: TextStyle(
                      fontSize: 16.toFont,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onConfirmation();
                  },
                  child: Text(
                    'Yes, delete only Transfer History',
                    style: TextStyle(
                        fontSize: 16.toFont,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onConfirmation();
                    if (Platform.isAndroid || Platform.isIOS) {
                      await Future.forEach(
                        widget.receivedHistory!.files!,
                        (FileData element) async {
                          String filePath = BackendService.getInstance()
                                  .downloadDirectory!
                                  .path +
                              Platform.pathSeparator +
                              element.name!;
                          if (await CommonUtilityFunctions()
                              .isFilePresent(filePath)) {
                            var file = File(filePath);
                            file.deleteSync();
                          }
                        },
                      );
                      await Provider.of<MyFilesProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .deletMyFileRecord(widget.receivedHistory!.key);
                    } else {
                      await Future.forEach(
                        widget.receivedHistory!.files!,
                        (FileData element) async {
                          String filePath =
                              MixedConstants.RECEIVED_FILE_DIRECTORY +
                                  Platform.pathSeparator +
                                  (widget.receivedHistory!.sender ?? '') +
                                  Platform.pathSeparator +
                                  (element.name ?? '');

                          if (await CommonUtilityFunctions()
                              .isFilePresent(filePath)) {
                            var file = File(filePath);
                            if (await file.existsSync()) {
                              file.deleteSync();
                            }
                          }
                        },
                      );

                      await Provider.of<MyFilesProvider>(
                              NavService.navKey.currentContext!,
                              listen: false)
                          .deletMyFileRecord(widget.receivedHistory!.key);
                    }
                  },
                  child: Text(
                    'Yes, delete Transfer History and My Files ',
                    style: TextStyle(
                        fontSize: 16.toFont,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
