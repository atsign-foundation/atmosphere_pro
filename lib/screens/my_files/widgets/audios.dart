import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class Audios extends StatefulWidget {
  @override
  _AudiosState createState() => _AudiosState();
}

class _AudiosState extends State<Audios> {
  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              DateTime date =
                  DateTime.parse(provider.receivedAudio[index].date);
              return InkWell(
                onTap: () {},
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text('A.Walker Faded . Mp3',
                        style: CustomTextStyles.primaryBold14),
                    leading: Container(
                      width: 50.toWidth,
                      height: 49.toHeight,
                      decoration: BoxDecoration(
                          color: ColorConstants.redText,
                          borderRadius: BorderRadius.circular(5)),
                      child: Image.asset(
                        ImageConstants.musicFile,
                        width: 40.toWidth,
                        height: 40.toHeight,
                      ),
                    ),
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedAudio[index].size
                                          .toString()) <=
                                      1024
                                  ? '${(provider.receivedAudio[index].size).toStringAsFixed(2)} Kb'
                                  : '${(provider.receivedAudio[index].size / 1024).toStringAsFixed(2)} Mb',
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
