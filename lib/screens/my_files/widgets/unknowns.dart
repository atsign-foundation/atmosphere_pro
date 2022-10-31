import 'dart:io';

import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'downloads_folders.dart';

class Unknowns extends StatefulWidget {
  @override
  _UnknownsState createState() => _UnknownsState();
}

class _UnknownsState extends State<Unknowns> {
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
            itemCount: provider.receivedUnknown.length,
            itemBuilder: (context, index) {
              DateTime date =
                  DateTime.parse(provider.receivedUnknown[index].date!);
              return InkWell(
                onTap: () async {
                  await openFilePath(provider.receivedUnknown[index].filePath!);
                },
                onLongPress: () {
                  deleteFile(provider.receivedUnknown[index].filePath!,
                      fileTransferId:
                          provider.receivedUnknown[index].fileTransferId!);
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedUnknown[index].fileName!,
                        style: CustomTextStyles.primaryBold14),
                    leading: Container(
                      width: SizeConfig().isTablet(context)
                          ? 30.toWidth
                          : 50.toWidth,
                      height: SizeConfig().isTablet(context)
                          ? 30.toHeight
                          : 49.toHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.toHeight),
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          height: 50.toHeight,
                          width: 50.toWidth,
                          child: Image.asset(
                            FileTypes.PDF_TYPES.contains(provider.receivedUnknown[index].fileName!
                                    .split('.')
                                    .last)
                                ? ImageConstants.pdfLogo
                                : FileTypes.WORD_TYPES.contains(provider
                                        .receivedUnknown[index].fileName!
                                        .split('.')
                                        .last)
                                    ? ImageConstants.wordLogo
                                    : FileTypes.EXEL_TYPES.contains(provider
                                            .receivedUnknown[index].fileName!
                                            .split('.')
                                            .last)
                                        ? ImageConstants.exelLogo
                                        : FileTypes.TEXT_TYPES.contains(provider
                                                .receivedUnknown[index]
                                                .fileName!
                                                .split('.')
                                                .last)
                                            ? ImageConstants.txtLogo
                                            : FileTypes.ARCHIVE_TYPES.contains(provider
                                                    .receivedUnknown[index]
                                                    .fileName!
                                                    .split('.')
                                                    .last)
                                                ? ImageConstants.archiveLogo
                                                : FileTypes.WEB_IMAGE_TYPES.contains(provider.receivedUnknown[index].fileName!.split('.').last)
                                                    ? ImageConstants.svgLogo
                                                    : ImageConstants.otherFileLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedUnknown[index].size
                                          .toString()) <=
                                      1024
                                  ? '${provider.receivedUnknown[index].size!.toStringAsFixed(2)} ' +
                                      TextStrings().kb
                                  : '${(provider.receivedUnknown[index].size! / 1024).toStringAsFixed(2)} ' +
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
      builder: (context) => EditBottomSheet(
        onConfirmation: () async {
          var file = File(filePath);
          if (await file.exists()) {
            file.deleteSync();
          }
          if (fileTransferId != null) {
            await Provider.of<MyFilesProvider>(
                    NavService.navKey.currentContext!,
                    listen: false)
                .removeParticularFile(fileTransferId,
                    filePath.split(Platform.pathSeparator).last);
          }
        },
        deleteMessage: TextStrings.deleteFileConfirmationMsgMyFiles,
      ),
    );
  }
}
