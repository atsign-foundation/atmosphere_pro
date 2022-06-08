import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

class Audios extends StatefulWidget {
  @override
  _AudiosState createState() => _AudiosState();
}

class _AudiosState extends State<Audios> {
  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      showError: false,
      load: (provider) => provider.sortFiles(),
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: ListView.builder(
            itemCount: provider.receivedAudio.length,
            itemBuilder: (context, index) {
              DateTime date =
                  DateTime.parse(provider.receivedAudio[index].date!);
              return InkWell(
                onTap: () async {
                  await openFilePath(provider.receivedAudio[index].filePath!);
                },
                onLongPress: () {
                  deleteFile(provider.receivedAudio[index].filePath!,
                      fileTransferId:
                          provider.receivedAudio[index].fileTransferId);
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedAudio[index].fileName!,
                        style: CustomTextStyles.primaryBold14),
                    leading: Container(
                      width: SizeConfig().isTablet(context)
                          ? 30.toWidth
                          : 50.toWidth,
                      height: SizeConfig().isTablet(context)
                          ? 30.toHeight
                          : 50.toHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.toHeight),
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          height: 40.toHeight,
                          width: 40.toWidth,
                          child: Image.asset(
                            ImageConstants.musicLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedAudio[index].size
                                          .toString()) <=
                                      1024
                                  ? '${provider.receivedAudio[index].size!.toStringAsFixed(2)} ' +
                                      TextStrings().kb
                                  : '${(provider.receivedAudio[index].size! / 1024).toStringAsFixed(2)} ' +
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
