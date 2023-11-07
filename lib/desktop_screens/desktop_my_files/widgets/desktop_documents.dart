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

class DesktopDocuments extends StatefulWidget {
  const DesktopDocuments({Key? key}) : super(key: key);

  @override
  State<DesktopDocuments> createState() => _DesktopDocumentsState();
}

class _DesktopDocumentsState extends State<DesktopDocuments> {
  String? onHoverFileName;

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      load: (provider) {
        // provider.getReceivedHistory();
      },
      successBuilder: (provider) {
        return provider.receivedDocument.isEmpty
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
                      provider.receivedDocument.length,
                      (index) {
                        if (provider.receivedDocument[index].filePath!
                            .split(Platform.pathSeparator)
                            .last
                            .toLowerCase()
                            .contains(provider.fileSearchText)) {
                          return InkWell(
                            onTap: () async {
                              File test = File(
                                  provider.receivedDocument[index].filePath!);
                              bool fileExists = await test.exists();
                              if (fileExists) {
                                await OpenFile.open(
                                    provider.receivedDocument[index].filePath);
                              } else {
                                CommonUtilityFunctions().showNoFileDialog();
                              }
                            },
                            child: MouseRegion(
                              onEnter: (PointerEnterEvent e) {
                                setState(() {
                                  onHoverFileName =
                                      provider.receivedDocument[index].fileName;
                                });
                              },
                              onExit: (PointerExitEvent e) {
                                setState(() {
                                  onHoverFileName = null;
                                });
                              },
                              child: DesktopFileCard(
                                key: Key(
                                    provider.receivedDocument[index].filePath!),
                                title: provider
                                    .receivedDocument[index].filePath!
                                    .split(Platform.pathSeparator)
                                    .last,
                                filePath:
                                    provider.receivedDocument[index].filePath,
                                showDelete: onHoverFileName ==
                                    provider.receivedDocument[index].fileName,
                                transferId: provider
                                    .receivedDocument[index].fileTransferId!,
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
