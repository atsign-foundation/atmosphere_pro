import 'dart:io';

import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class DesktopRecents extends StatefulWidget {
  @override
  _DesktopRecentsState createState() => _DesktopRecentsState();
}

class _DesktopRecentsState extends State<DesktopRecents> {
  String? onHoverFileName;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyFilesProvider>(builder: (_, provider, ___) {
      return provider.recentFile.isEmpty
          ? Center(
              child: Text(TextStrings().noFilesFound),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              margin: EdgeInsets.symmetric(
                  vertical: 10.toHeight, horizontal: 10.toWidth),
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  runSpacing: 10.0,
                  spacing: 30.0,
                  children: List.generate(
                    provider.recentFile.length,
                    (index) {
                      if (provider.recentFile[index].filePath!
                          .split(Platform.pathSeparator)
                          .last
                          .toLowerCase()
                          .contains(provider.fileSearchText)) {
                        return InkWell(
                          onTap: () async {
                            File test =
                                File(provider.recentFile[index].filePath!);
                            bool fileExists = await test.exists();
                            if (fileExists) {
                              await OpenFile.open(
                                  provider.recentFile[index].filePath);
                            }
                          },
                          child: MouseRegion(
                            onEnter: (PointerEnterEvent e) {
                              setState(() {
                                onHoverFileName =
                                    provider.recentFile[index].fileName;
                              });
                            },
                            onExit: (PointerExitEvent e) {
                              setState(() {
                                onHoverFileName = null;
                              });
                            },
                            child: DesktopFileCard(
                              title: provider.recentFile[index].filePath!
                                  .split(Platform.pathSeparator)
                                  .last,
                              filePath: provider.recentFile[index].filePath,
                              showDelete: onHoverFileName ==
                                  provider.recentFile[index].fileName,
                              transferId:
                                  provider.recentFile[index].fileTransferId!,
                            ),
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ),
              ),
            );
    });
  }
}
