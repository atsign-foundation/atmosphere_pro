import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'downloads_folders.dart';

class APK extends StatefulWidget {
  @override
  _APKState createState() => _APKState();
}

class _APKState extends State<APK> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
      child: ProviderHandler<MyFilesProvider>(
        functionName: 'received_history',
        showError: false,
        load: (provider) {},
        successBuilder: (provider) => ListView.builder(
            itemCount: provider.receivedApk.length,
            itemBuilder: (context, index) {
              DateTime date = DateTime.parse(provider.receivedApk[index].date!);
              return InkWell(
                onTap: () async {
                  await openFilePath(provider.receivedApk[index].filePath!);
                },
                onLongPress: () {
                  deleteFile(provider.receivedApk[index].filePath!,
                      fileTransferId:
                          provider.receivedApk[index].fileTransferId);
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedApk[index].fileName!,
                        style: CustomTextStyles.primaryBold14),
                    leading: Container(
                      width: 50.toWidth,
                      height: 49.toHeight,
                      decoration: BoxDecoration(
                          color: ColorConstants.appBarColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Image.asset(
                        ImageConstants.apkFile,
                        width: 40.toWidth,
                        height: 40.toHeight,
                      ),
                    ),
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedApk[index].size
                                          .toString()) <=
                                      1024
                                  ? '${provider.receivedApk[index].size!.toStringAsFixed(2)} ' +
                                      TextStrings().kb
                                  : '${(provider.receivedApk[index].size! / 1024).toStringAsFixed(2)} ' +
                                      TextStrings().mb,
                              style: CustomTextStyles.secondaryRegular12),
                          SizedBox(
                            width: 12.toWidth,
                          ),
                          Text(
                              '${date.day.toString()}/${date.month}/${date.year}',
                              style: CustomTextStyles.secondaryRegular12),
                        ]),
                  ),
                ),
              );
            }),
      ),
    );
  }

  deleteFile(String filePath, {String? fileTransferId}) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(onConfirmation: () async {
        var file = File(filePath);
        if (await file.exists()) {
          file.deleteSync();
        }
        if (fileTransferId != null) {
          await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .removeParticularFile(
                  fileTransferId, filePath.split(Platform.pathSeparator).last);
        }
      }),
    );
  }
}
