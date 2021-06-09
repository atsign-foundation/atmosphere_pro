import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';

class DesktopSelectedFiles extends StatefulWidget {
  @override
  _DesktopSelectedFilesState createState() => _DesktopSelectedFilesState();
}

class _DesktopSelectedFilesState extends State<DesktopSelectedFiles> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (((SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH) / 2) - 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected files', style: CustomTextStyles.desktopPrimaryBold18),
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              runSpacing: 10.0,
              spacing: 20.0,
              children: List.generate(2, (index) {
                return customFileTile(
                  '144KB',
                  'JPG',
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget customFileTile(String size, String type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {},
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      ImageConstants.welcomeDesktop,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Icon(Icons.cancel),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'File Name',
                style: CustomTextStyles.desktopPrimaryRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5.toHeight),
              type != null
                  ? Text(
                      '$size . $type',
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
