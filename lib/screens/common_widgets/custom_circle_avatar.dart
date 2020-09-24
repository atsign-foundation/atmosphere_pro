/// This is a custom Circle Avatar with a border of secondary color
/// [size] is set to [50] as default

import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String image;
  final double size;

  const CustomCircleAvatar({Key key, this.image, this.size = 50})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      child: CircleAvatar(
        radius: (size - 5).toFont,
        backgroundColor: ColorConstants.fontSecondary,
        child: Container(
          height: (size - 6).toFont,
          width: (size - 6).toFont,
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
