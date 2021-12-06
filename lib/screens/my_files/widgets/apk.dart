import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';

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
      child: ProviderHandler<HistoryProvider>(
        functionName: 'received_history',
        load: (provider) => provider.getReceivedHistory(),
        successBuilder: (provider) => ListView.builder(
            itemCount: provider.receivedApk.length,
            itemBuilder: (context, index) {
              DateTime date = DateTime.parse(provider.receivedApk[index].date);
              return InkWell(
                onTap: () async {
                  await openFilePath(provider.receivedApk[index].filePath);
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedApk[index].fileName,
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
                                  ? '${(provider.receivedApk[index].size).toStringAsFixed(2)} Kb'
                                  : '${(provider.receivedApk[index].size / 1024).toStringAsFixed(2)} Mb',
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
