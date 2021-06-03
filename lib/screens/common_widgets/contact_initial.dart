import 'dart:math';

import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double size, maxSize, minSize;
  final String initials;
  int index;

  ContactInitial({Key key, this.size = 40, @required this.initials, this.index, this.maxSize, this.minSize})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (initials.length < 3) {
      index = initials.length;
    } else {
      index = 3;
    }

    return Container(
      height: size.toFont,
      width: size.toFont,
      constraints: BoxConstraints(
              minHeight: minSize ?? double.infinity, minWidth: minSize ?? double.infinity, maxHeight: maxSize ?? double.infinity, maxWidth: maxSize ?? double.infinity,
              ),
      decoration: BoxDecoration(
        color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular((size.toFont)),
      ),
      child: Center(
        child: Text(
          initials.substring((index == 1) ? 0 : 1, index).toUpperCase(),
          style: CustomTextStyles.whiteBold(size: (size ~/ 3)),
        ),
      ),
    );
  }
}
