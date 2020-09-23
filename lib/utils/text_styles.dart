import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CustomTextStyles {
  //colorWeightSize

  static TextStyle blueRegular18 = TextStyle(
    color: ColorConstants.appBarCloseColor,
    fontSize: 18.toFont,
  );
  static TextStyle blueRegular16 = TextStyle(
    color: ColorConstants.appBarCloseColor,
    fontSize: 16.toFont,
  );

  static TextStyle whiteBold16 = TextStyle(
    color: Colors.white,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w600,
  );
  static TextStyle primaryBold18 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 18.toFont,
    fontWeight: FontWeight.w600,
  );

  static TextStyle primaryBold16 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w600,
  );

  static TextStyle primaryBold14 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 14.toFont,
    fontWeight: FontWeight.w600,
  );

  static TextStyle secondaryRegular16 = TextStyle(
    color: ColorConstants.fontSecondary,
    fontSize: 16.toFont,
  );
  static TextStyle secondaryRegular14 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 14.toFont,
      fontWeight: FontWeight.w300);

  static TextStyle primaryRegular16 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 16.toFont,
      fontWeight: FontWeight.w400);

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      fontWeight: FontWeight.w200);
}
