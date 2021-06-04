import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSelectedContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: TextSpan(
          text: 'Selected person',
          style: CustomTextStyles.desktopSecondaryRegularBold18,
          children: [
            TextSpan(
              text: '  18 people selected',
              style: CustomTextStyles.desktopSecondaryRegular18,
            )
          ],
        ),
      ),
      SizedBox(
        height: 30,
      ),
      GridView.count(
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 7,
        childAspectRatio: 0.75,
        // (  SizeConfig().screenHeight - 80 - 250) /
        //    (SizeConfig().screenWidth - 70) / 2,
        children: List.generate(20, (index) {
          return InkWell(
            onTap: () {},
            child: customPersonVerticalTile(
              'Levina',
              '@levina',
            ),
          );
        }),
      )
    ]);
  }

  Widget customPersonVerticalTile(String title, String subTitle) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              ContactInitial(
                initials: title ?? ' ',
                size: 30,
                maxSize: (80.0 - 30.0),
                minSize: 50,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.cancel),
              ),
            ],
          ),
          SizedBox(width: 10.toHeight),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: CustomTextStyles.desktopPrimaryRegular14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.toHeight),
                subTitle != null
                    ? Text(
                        subTitle,
                        style: CustomTextStyles.secondaryRegular12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
