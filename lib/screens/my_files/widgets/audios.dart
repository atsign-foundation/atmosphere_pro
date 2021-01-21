import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
class Audios extends StatefulWidget {
  @override
  _AudiosState createState() => _AudiosState();
}

class _AudiosState extends State<Audios> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
      child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {},
                child: Card(
                    margin: EdgeInsets.only(top: 15.toHeight),
                    child: ListTile(
                      tileColor: ColorConstants.listBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      title: Text('A.Walker Faded . Mp3', style: CustomTextStyles.primaryBold14),
                      leading: Container(
                        width: 50.toWidth,
                        height: 49.toHeight,
                        decoration: BoxDecoration(
                            color: ColorConstants.redText, borderRadius: BorderRadius.circular(5)),
                        child: Image.asset(
                          ImageConstants.musicFile,
                          width: 40.toWidth,
                          height: 40.toHeight,
                        ),
                      ),
                      subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                        Text('15.3 MB', style: CustomTextStyles.secondaryRegular12),
                        SizedBox(
                          width: 12.toWidth,
                        ),
                        Text('Nov 25, 2020', style: CustomTextStyles.secondaryRegular12),
                      ]),
                    )));
          }),
    );
  }
}
