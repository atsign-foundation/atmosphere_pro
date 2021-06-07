import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class CustomTextStyles {
  //colorWeightSize

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

  static TextStyle primaryRegularBold18 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 18.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.bold);

  static TextStyle primaryRegular18 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 18.toFont,
    letterSpacing: 0.1,
  );

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

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

  static TextStyle blackBold({int size = 16}) => TextStyle(
        color: Colors.black,
        fontSize: size.toFont,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w700,
      );

  static TextStyle blackPlayfairDisplay26 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26.toFont,
    color: Colors.black,
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

  static TextStyle greyText16 =
      TextStyle(color: ColorConstants.greyText, fontSize: 16);

  static TextStyle greyText15 =
      TextStyle(color: ColorConstants.greyText, fontSize: 15);

  static TextStyle orangeext15 =
      TextStyle(color: ColorConstants.orangeColor, fontSize: 15);

  static TextStyle greyText12 =
      TextStyle(color: ColorConstants.greyText, fontSize: 12);
}
