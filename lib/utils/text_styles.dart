import 'dart:ui';

import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomTextStyles {
//REGULAR FONTS
  static TextStyle blueRegular18 = TextStyle(
      color: ColorConstants.appBarCloseColor,
      fontSize: 18.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle blueRegular16 = TextStyle(
      color: ColorConstants.appBarCloseColor,
      fontSize: 16.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle blueRegular14 = TextStyle(
      color: ColorConstants.appBarCloseColor,
      fontSize: 14.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular16 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 16.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular14 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 14.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle primaryRegular16 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 16.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle grey13 =
      TextStyle(fontSize: 13.toFont, color: ColorConstants.greyText);

  static TextStyle grey15 =
      TextStyle(fontSize: 15.toFont, color: ColorConstants.greyText);

  static TextStyle red15 =
      TextStyle(color: ColorConstants.redAlert, fontSize: 15.toFont);

  static TextStyle darkGrey13 = TextStyle(
    color: ColorConstants.dullText,
    fontSize: 13.toFont,
  );

//BOLD FONTS
  static TextStyle whiteBold16 = TextStyle(
    color: Colors.white,
    fontSize: 16.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );
  static TextStyle whiteBold({int size = 16}) => TextStyle(
        color: Colors.white,
        fontSize: size.toFont,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w700,
      );
  static TextStyle primaryBold18 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontWeight: FontWeight.w700,
    fontSize: 18.toFont,
    letterSpacing: 0.1,
  );

  static TextStyle primaryBold16 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 16.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle primaryBold14 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 14.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle primaryBlueBold14 = TextStyle(
    color: ColorConstants.blueText,
    fontSize: 14.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  //MEDIUM FONTS

  static TextStyle primaryMedium14 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 14.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );

  static TextStyle blueMedium16 = TextStyle(
    color: ColorConstants.appBarCloseColor,
    fontSize: 16.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );

  static TextStyle orangeMedium16 = TextStyle(
    color: ColorConstants.orangeColor,
    fontSize: 16.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );

  static TextStyle redSmall12 = TextStyle(
    color: ColorConstants.redText,
    fontSize: 11.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );
}
