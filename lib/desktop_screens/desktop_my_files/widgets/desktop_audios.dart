import 'dart:io';

import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:open_file/open_file.dart';

class DesktopAudios extends StatefulWidget {
  @override
  _DesktopAudiosState createState() => _DesktopAudiosState();
}

class _DesktopAudiosState extends State<DesktopAudios> {
  String? onHoverFileName;

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      load: (provider) {
        // provider.getReceivedHistory();
      },
      successBuilder: (provider) {
        return provider.receivedAudio.isEmpty
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
                      provider.receivedAudio.length,
                      (index) {
                        if (provider.receivedAudio[index].filePath!
                            .split(Platform.pathSeparator)
                            .last
                            .toLowerCase()
                            .contains(provider.fileSearchText)) {
                          return InkWell(
                            onTap: () async {
                              File test =
                                  File(provider.receivedAudio[index].filePath!);
                              bool fileExists = await test.exists();
                              if (fileExists) {
                                await OpenFile.open(
                                    provider.receivedAudio[index].filePath);
                              } else {
                                CommonUtilityFunctions().showNoFileDialog();
                              }
                            },
                            child: MouseRegion(
                              onEnter: (PointerEnterEvent e) {
                                setState(() {
                                  onHoverFileName =
                                      provider.receivedAudio[index].fileName;
                                });
                              },
                              onExit: (PointerExitEvent e) {
                                setState(() {
                                  onHoverFileName = null;
                                });
                              },
                              child: DesktopFileCard(
                                key: Key(
                                    provider.receivedAudio[index].filePath!),
                                title: provider.receivedAudio[index].filePath!
                                    .split(Platform.pathSeparator)
                                    .last,
                                filePath:
                                    provider.receivedAudio[index].filePath,
                                showDelete: onHoverFileName ==
                                    provider.receivedAudio[index].fileName,
                                transferId: provider
                                    .receivedAudio[index].fileTransferId!,
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
      },
    );
  }
}
