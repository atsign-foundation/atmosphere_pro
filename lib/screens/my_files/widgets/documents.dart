import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';

import 'downloads_folders.dart';

class Documents extends StatefulWidget {
  @override
  _DocumentsState createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      functionName: 'sort_files',
      load: (provider) => provider.sortFiles(provider.receivedHistoryLogs),
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: ListView.builder(
            itemCount: provider.receivedDocument.length,
            itemBuilder: (context, index) {
              DateTime date =
                  DateTime.parse(provider.receivedDocument[index].date);
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.only(top: 20.toWidth),
                          height: 190.toHeight,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    color: ColorConstants.fontSecondary)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 10.toHeight),
                                  width: 50.toWidth,
                                  height: 5.toHeight,
                                  decoration: BoxDecoration(
                                      color: ColorConstants.fontSecondary,
                                      borderRadius: BorderRadius.circular(5)),
                                )
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    left: 20.toWidth,
                                    top: 10.toHeight,
                                    right: 20.toWidth),
                                child: Column(children: <Widget>[
                                  ListTile(
                                      onTap: () async {
                                        await openDownloadsFolder(context);
                                      },
                                      title: Text(
                                        'Open file location',
                                        style:
                                            CustomTextStyles.primaryRegular16,
                                      )),
                                  Divider(
                                    thickness: 1,
                                    color: ColorConstants.greyText,
                                  ),
                                  ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      title: Text(
                                        'Cancel',
                                        style:
                                            CustomTextStyles.primaryRegular16,
                                      )),
                                ]))
                          ]),
                        );
                      });
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedDocument[index].fileName,
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
                            FileTypes.PDF_TYPES.contains(provider
                                    .receivedDocument[index].fileName
                                    .split('.')
                                    .last)
                                ? ImageConstants.pdfLogo
                                : FileTypes.WORD_TYPES.contains(provider
                                        .receivedDocument[index].fileName
                                        .split('.')
                                        .last)
                                    ? ImageConstants.wordLogo
                                    : FileTypes.EXEL_TYPES.contains(provider
                                            .receivedDocument[index].fileName
                                            .split('.')
                                            .last)
                                        ? ImageConstants.exelLogo
                                        : FileTypes.TEXT_TYPES.contains(provider
                                                .receivedDocument[index]
                                                .fileName
                                                .split('.')
                                                .last)
                                            ? ImageConstants.txtLogo
                                            : ImageConstants.unknownLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedDocument[index].size
                                          .toString()) <=
                                      1024
                                  ? '${(provider.receivedDocument[index].size).toStringAsFixed(2)} Kb'
                                  : '${(provider.receivedDocument[index].size / 1024).toStringAsFixed(2)} Mb',
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
}
