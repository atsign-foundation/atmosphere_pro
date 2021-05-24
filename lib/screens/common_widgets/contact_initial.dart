import 'dart:math';

import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double size;
  final String initials;
  int index;

  ContactInitial({Key key, this.size = 40, @required this.initials, this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (initials.length < 3) {
      index = initials.length;
    } else {
      index = 3;
    }

    Random r = Random();
    return Container(
      height: size.toFont,
      width: size.toFont,

      decoration: BoxDecoration(
        color:
            Color.fromARGB(255, r.nextInt(255), r.nextInt(255), r.nextInt(255)),
        borderRadius: BorderRadius.circular(size.toWidth),
      ),
      // border: Border.all(width: 0.5, color: ColorConstants.fontSecondary)),
      child: Center(
        child: Text(
          initials.substring((index == 1) ? 0 : 1, index),
          style: CustomTextStyles.whiteBold(size: (size ~/ 3)),
        ),
      ),
    );
  }
}
