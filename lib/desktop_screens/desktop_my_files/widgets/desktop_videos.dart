import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:open_file/open_file.dart';

class DesktopVideos extends StatefulWidget {
  @override
  _DesktopVideosState createState() => _DesktopVideosState();
}

class _DesktopVideosState extends State<DesktopVideos> {
  String? onHoverFileName;

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      load: (provider) {
        // provider.getReceivedHistory();
      },
      successBuilder: (provider) {
        return provider.receivedVideos.isEmpty
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
                      provider.receivedVideos.length,
                      (index) {
                        if (provider.receivedVideos[index].filePath!
                            .split(Platform.pathSeparator)
                            .last
                            .toLowerCase()
                            .contains(provider.fileSearchText)) {
                          return InkWell(
                            onTap: () async {
                              File test = File(
                                  provider.receivedVideos[index].filePath!);
                              bool fileExists = await test.exists();
                              if (fileExists) {
                                await OpenFile.open(
                                    provider.receivedVideos[index].filePath);
                              }
                            },
                            child: MouseRegion(
                              onEnter: (PointerEnterEvent e) {
                                setState(() {
                                  onHoverFileName =
                                      provider.receivedVideos[index].fileName;
                                });
                              },
                              onExit: (PointerExitEvent e) {
                                setState(() {
                                  onHoverFileName = null;
                                });
                              },
                              child: DesktopFileCard(
                                title: provider.receivedVideos[index].filePath!
                                    .split(Platform.pathSeparator)
                                    .last,
                                filePath:
                                    provider.receivedVideos[index].filePath,
                                showDelete: onHoverFileName ==
                                    provider.receivedVideos[index].fileName,
                                transferId: provider
                                    .receivedVideos[index].fileTransferId!,
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
