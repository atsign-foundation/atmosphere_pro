import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopCustomPersonVerticalTile extends StatelessWidget {
  final String title, subTitle;
  final bool showCancelIcon;
  DesktopCustomPersonVerticalTile(
      {this.title, this.subTitle, this.showCancelIcon = true});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {},
          child: Stack(
            children: [
              ContactInitial(
                initials: title ?? ' ',
                size: 30,
                maxSize: (80.0 - 30.0),
                minSize: 50,
              ),
              showCancelIcon
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.cancel),
                    )
                  : SizedBox(),
            ],
          ),
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
    );
  }
}
