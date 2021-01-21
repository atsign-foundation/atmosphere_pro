import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';

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
        load: (provider) => provider.getRecievedHistory(),
        successBuilder: (provider) => ListView.builder(
            itemCount: provider.receivedApk.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
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
                          Text(provider.receivedApk[index].size.toString(),
                              style: CustomTextStyles.secondaryRegular12),
                          SizedBox(
                            width: 12.toWidth,
                          ),
                          Text('Version: 4.4419',
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
