import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

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

  static TextStyle black16 = TextStyle(
      color: Colors.black,
      fontSize: 16.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle black12 = TextStyle(
      color: Colors.black,
      fontSize: 12.toFont,
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
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle grey13 = TextStyle(
      fontSize: 13.toFont,
      color: ColorConstants.greyText,
      fontWeight: FontWeight.normal);

  static TextStyle grey15 = TextStyle(
      fontSize: 15.toFont,
      color: ColorConstants.greyText,
      fontWeight: FontWeight.normal);

  static TextStyle red15 = TextStyle(
      color: ColorConstants.redAlert,
      fontSize: 15.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle red20 = TextStyle(
      color: ColorConstants.redAlert,
      fontSize: 20.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle darkGrey13 = TextStyle(
      color: ColorConstants.dullText,
      fontSize: 13.toFont,
      fontWeight: FontWeight.normal);
  static TextStyle blueRegular12 = TextStyle(
      color: ColorConstants.blueText,
      fontSize: 12.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

//BOLD FONTS
  static TextStyle blackBold25 = TextStyle(
    color: Colors.black,
    fontSize: 25.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );
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

  static TextStyle primaryBold18 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontWeight: FontWeight.w700,
    fontSize: 18.toFont,
    letterSpacing: 0.1,
  );

  static TextStyle desktopPrimaryW400S14 = TextStyle(
    color: Colors.black,
    fontSize: 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
  );

  static TextStyle desktopPrimaryW500S15 = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle oldSliverW400S10 = TextStyle(
    color: ColorConstants.oldSliver,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle oldSliverW400S11 = TextStyle(
    color: ColorConstants.oldSliver,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle oldSliverW400S12 = TextStyle(
    color: ColorConstants.oldSliver,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle whiteBoldS12 =
      TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700);

  static TextStyle primaryBold17 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 17.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
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

  static TextStyle primaryBold15 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 15.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle primaryBlueBold14 = TextStyle(
    color: ColorConstants.blueText,
    fontSize: 14.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  //SEMIBOLD FONTS
  static TextStyle greySemiBold18 = TextStyle(
    color: Color(0xFF939393),
    fontSize: 18.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
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

  static TextStyle whiteMedium18 = TextStyle(
    color: Colors.white,
    fontSize: 18.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
  );

  /// Desktop

  static TextStyle greyText16 = TextStyle(
      color: ColorConstants.greyText,
      fontSize: 16,
      fontWeight: FontWeight.normal);

  static TextStyle greyText15 = TextStyle(
      color: ColorConstants.greyText,
      fontSize: 15,
      fontWeight: FontWeight.normal);

  static TextStyle orangeext15 = TextStyle(
      color: ColorConstants.orangeColor,
      fontSize: 15,
      fontWeight: FontWeight.normal);

  static TextStyle orangeColorW50013 = TextStyle(
    color: ColorConstants.orangeColor,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle greyText12 = TextStyle(
      color: ColorConstants.greyText,
      fontSize: 12,
      fontWeight: FontWeight.normal);

  static TextStyle primaryRegular20 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 20.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.bold);

  static TextStyle primaryNormal20 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 20.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle blueNormal20 = TextStyle(
      color: ColorConstants.blueText,
      fontSize: 20.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopSecondaryRegular18 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopSecondaryRegular16 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 16,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopSecondaryRegular14 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 14,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500);

  static TextStyle desktopSecondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500);

  static TextStyle desktopSecondaryBold18 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.bold);

  static TextStyle desktopPrimaryBold12 = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static TextStyle desktopPrimaryW50015 = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle desktopPrimaryW50010 = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static TextStyle desktopPrimaryBold18 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.bold);

  static TextStyle desktopSecondaryBold12 = TextStyle(
      color: ColorConstants.sidebarTextHeading,
      fontSize: 10,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w700);

  static TextStyle desktopBlackPlayfairDisplay26 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 44,
    color: Colors.black,
  );

  static TextStyle desktopPrimaryRegular12 = TextStyle(
      color: Colors.black,
      fontSize: 12,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopPrimaryRegular14 = TextStyle(
      color: Colors.black,
      fontSize: 14,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopPrimaryRegular18 = TextStyle(
      color: Colors.black,
      fontSize: 18,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopPrimaryRegular16 = TextStyle(
      color: Colors.black,
      fontSize: 16,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle desktopPrimaryRegular24 = TextStyle(
    color: Colors.black,
    fontSize: 24,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
  );

  static TextStyle desktopButton15 = TextStyle(
    color: Colors.white,
    fontSize: 15,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle orangeW50015 = TextStyle(
    color: ColorConstants.orange,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle whiteW50015 = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle blackW50020 = const TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static TextStyle orangeW50014 = TextStyle(
      color: ColorConstants.orange, fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle whiteBold12 = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static TextStyle blackW60013 = const TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static TextStyle blackW40011 = const TextStyle(
    color: Colors.black,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle darkSliverBold20 = TextStyle(
    color: ColorConstants.darkSliver,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle raisinBlackW60025 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 25.toFont,
    fontWeight: FontWeight.w600,
  );

  static TextStyle raisinBlackW50013 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 13.toFont,
    fontWeight: FontWeight.w500,
  );

  static TextStyle raisinBlackW50012 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 12.toFont,
    fontWeight: FontWeight.w500,
  );

  static TextStyle darkSliverWW50015 = TextStyle(
    color: ColorConstants.darkSliver,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle darkSliverWW40012 = TextStyle(
    color: ColorConstants.darkSliver,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle blackW60012 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  static TextStyle blackW60014 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle blackW40010 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w400,
    fontSize: 10,
  );

  static TextStyle blackW40012 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  static TextStyle raisinBlackW40010 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle raisinBlackW40012 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle blackW60010 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 10,
  );

  static TextStyle blackW60011 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 11,
  );

  static TextStyle blackW50014 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle raisinBlackW4009 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 9,
    fontWeight: FontWeight.w400,
  );

  static TextStyle raisinBlackW40011 = TextStyle(
    color: ColorConstants.raisinBlack,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle whiteW60012 = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle spanishGrayW60010 = const TextStyle(
    color: ColorConstants.spanishGray,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static TextStyle spanishGrayW50012 = const TextStyle(
    color: ColorConstants.spanishGray,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle portlandOrangeW60012 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ColorConstants.portlandOrange,
  );

  static TextStyle portlandOrangeW50012 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorConstants.portlandOrange,
  );
}
