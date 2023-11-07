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

class DesktopAPK extends StatefulWidget {
  const DesktopAPK({Key? key}) : super(key: key);

  @override
  State<DesktopAPK> createState() => _DesktopAPKState();
}

class _DesktopAPKState extends State<DesktopAPK> {
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
        return provider.receivedApk.isEmpty
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
                      provider.receivedApk.length,
                      (index) {
                        if (provider.receivedApk[index].filePath!
                            .split(Platform.pathSeparator)
                            .last
                            .toLowerCase()
                            .contains(provider.fileSearchText)) {
                          return InkWell(
                            onTap: () async {
                              File test =
                                  File(provider.receivedApk[index].filePath!);
                              bool fileExists = await test.exists();
                              if (fileExists) {
                                await OpenFile.open(
                                    provider.receivedApk[index].filePath);
                              } else {
                                CommonUtilityFunctions().showNoFileDialog();
                              }
                            },
                            child: MouseRegion(
                              onEnter: (PointerEnterEvent e) {
                                setState(() {
                                  onHoverFileName =
                                      provider.receivedApk[index].fileName;
                                });
                              },
                              onExit: (PointerExitEvent e) {
                                setState(() {
                                  onHoverFileName = null;
                                });
                              },
                              child: DesktopFileCard(
                                  key: Key(
                                      provider.receivedApk[index].filePath!),
                                  title: provider.receivedApk[index].filePath!
                                      .split(Platform.pathSeparator)
                                      .last,
                                  filePath:
                                      provider.receivedApk[index].filePath,
                                  showDelete: onHoverFileName ==
                                      provider.receivedApk[index].fileName,
                                  transferId: provider
                                      .receivedApk[index].fileTransferId!),
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
