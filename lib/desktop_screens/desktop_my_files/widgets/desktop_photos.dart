import 'dart:io';

import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:at_common_flutter/services/size_config.dart';

class DesktopPhotos extends StatefulWidget {
  const DesktopPhotos({Key? key}) : super(key: key);

  @override
  State<DesktopPhotos> createState() => _DesktopPhotosState();
}

class _DesktopPhotosState extends State<DesktopPhotos> {
  String? onHoverFileName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      load: (provider) {
        // provider.getReceivedHistory();
      },
      successBuilder: (provider) {
        return provider.receivedPhotos.isEmpty
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
                      provider.receivedPhotos.length,
                      (index) {
                        if (provider.receivedPhotos[index].filePath!
                            .split(Platform.pathSeparator)
                            .last
                            .toLowerCase()
                            .contains(provider.fileSearchText)) {
                          return InkWell(
                            onTap: () async {
                              File test = File(
                                  provider.receivedPhotos[index].filePath!);
                              bool fileExists = await test.exists();
                              if (fileExists) {
                                await OpenFile.open(
                                    provider.receivedPhotos[index].filePath);
                              } else {
                                CommonUtilityFunctions().showNoFileDialog();
                              }
                            },
                            child: MouseRegion(
                              onEnter: (PointerEnterEvent e) {
                                setState(() {
                                  onHoverFileName =
                                      provider.receivedPhotos[index].fileName;
                                });
                              },
                              onExit: (PointerExitEvent e) {
                                setState(() {
                                  onHoverFileName = null;
                                });
                              },
                              child: DesktopFileCard(
                                key: Key(
                                    provider.receivedPhotos[index].filePath!),
                                title: provider.receivedPhotos[index].filePath!
                                    .split(Platform.pathSeparator)
                                    .last,
                                filePath:
                                    provider.receivedPhotos[index].filePath,
                                showDelete: onHoverFileName ==
                                    provider.receivedPhotos[index].fileName,
                                transferId: provider
                                    .receivedPhotos[index].fileTransferId!,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
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
