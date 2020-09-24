import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String image;

  const CustomCircleAvatar({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toFont,
      width: 50.toFont,
      child: CircleAvatar(
        radius: 45.toFont,
        backgroundColor: ColorConstants.fontSecondary,
        child: Container(
          height: 44.toFont,
          width: 44.toFont,
          child: CircleAvatar(
            // radius: 35.toFont,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(image),
          ),
        ),
      ),
    );
  }
}
