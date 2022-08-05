import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopFileCard extends StatefulWidget {
  final String? title;
  final String? filePath;
  final bool showDelete;
  final String transferId;
  Key? key;
  DesktopFileCard(
      {this.title,
      this.filePath,
      this.showDelete = false,
      required this.transferId,
      this.key});

  @override
  State<DesktopFileCard> createState() => _DesktopFileCardState();
}

class _DesktopFileCardState extends State<DesktopFileCard> {
  late Future _futureBuilder;
  @override
  void initState() {
    super.initState();
    getFutureBuilders();
  }

  getFutureBuilders() {
    _futureBuilder = CommonUtilityFunctions().isFilePresent(widget.filePath!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Card(
            child: Column(
              children: <Widget>[
                widget.filePath != null
                    ? Container(
                        width: 180,
                        height: 120,
                        child: FutureBuilder(
                          future: _futureBuilder,
                          builder: (BuildContext cotext, snapshot) {
                            return snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data != null
                                ? CommonUtilityFunctions().thumbnail(
                                    widget.filePath!
                                        .split(Platform.pathSeparator)
                                        .last
                                        .split('.')
                                        .last,
                                    widget.filePath,
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
                    : Container(
                        width: 180,
                        height: 120,
                        child: ClipRect(
                          child: Image.asset(ImageConstants.emptyTrustedSenders,
                              fit: BoxFit.fill),
                        ),
                      ),
                widget.title != null
                    ? Container(
                        width: 180,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorConstants.light_border_color),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            widget.title!,
                            style: TextStyle(
                              color: Color(0xFF8A8E95),
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
        widget.showDelete
            ? Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: deleteMyFiletem,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: ColorConstants.light_grey)),
                    child: Icon(Icons.close, size: 20),
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  deleteMyFiletem() async {
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content: ConfirmationDialog(
                  TextStrings.deleteFileConfirmationMsg_myFiles, () async {
                var file = File(widget.filePath!);
                if (await file.exists()) {
                  await file.delete();
                }

                await Provider.of<MyFilesProvider>(
                        NavService.navKey.currentContext!,
                        listen: false)
                    .removeParticularFile(widget.transferId,
                        widget.filePath!.split(Platform.pathSeparator).last);
              }));
        });
  }

  deleteFile(String filePath, {String? fileTransferId}) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(onConfirmation: () {
        var file = File(filePath);
        file.deleteSync();

        if (fileTransferId != null) {
          Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .removeParticularFile(
                  fileTransferId, filePath.split(Platform.pathSeparator).last);
        }
      }),
    );
  }
}
