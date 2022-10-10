import 'package:flutter/material.dart';

class ColorConstants {
  static const Color successColor = Colors.green;
  static const Color fadedText = Color(0xFF6D6D79);
  static const Color fadedbackground = Color(0xFFFDF9F9);
  static const Color appBarColor = Colors.white;
  static const Color scaffoldColor = Colors.white;
  static const Color appBarCloseColor = Color(0xff03A2E0);
  static const Color fontPrimary = Color(0xff131219);
  static const Color fontSecondary = Color(0xff868A92);
  static const Color dullText = Color(0xFFBEC0C8);
  static const Color greyText = Color(0xFF868A92);
  static const Color blueText = Color(0xFF03A2E0);
  static const Color redText = Color(0xFFF05E3E);
  static const Color inputFieldColor = Color(0xFFF7F7FF);
  static const Color dividerColor = Color(0xFF707070);
  static const Color fadedBlue = Color(0xFFF7F7FF);
  static const Color fadedGrey = Color(0xffF1F2F3);
  static const Color listBackground = Color(0xffF7F7FF);
  static const Color orangeColor = Color(0xffF05E3F);
  static const Color yellow = Color(0xFFEAA743);
  static const Color MILD_GREY = Color(0xFFE4E4E4);
  static const Color redAlert = Color(0xffF86060);
  static const Color red = Color(0xFFe34040);
  static const Color successGreen = Color(0xFF0ACB21);
  static const Color selago = Color(0xFFFFFAFA);
  static const Color mildGrey = Color(0xFFE4E4E4);
  static const Color selected_list = Color(0xFFFEF7F7);
  static const Color dark_red = Color(0xFFB00021);
  static const Color receivedSelectedTileColor = Color(0xFFF0EFFF);
  static const Color light_grey = Color(0xFFBFBFBF);
  static const Color light_border_color = Color(0xFFEEF1F4);
  static const Color textBoxBg = Color(0xFFF2F2F2);
  static const Color lightBlueBg = Color(0xFFF8FBFF);

  static const Color sidebarTextUnselected = Color(0xFFA4A4A5);
  static const Color sidebarTextSelected = Color(0xFF000000);
  static const Color sidebarTextHeading = Color(0xFFE7E7E7);
  static const Color sidebarTileSelected = Color(0xFFF5F5F5);
}

class ContactInitialsColors {
  static Color getColor(String atsign) {
    if (atsign.length == 1) {
      atsign = atsign + ' ';
    }
    switch (atsign[1].toUpperCase()) {
      case 'A':
        return Color(0xFFAA0DFE);
      case 'B':
        return Color(0xFF3283FE);
      case 'C':
        return Color(0xFF85660D);
      case 'D':
        return Color(0xFF782AB6);
      case 'E':
        return Color(0xFF565656);
      case 'F':
        return Color(0xFF1C8356);
      case 'G':
        return Color(0xFF16FF32);
      case 'H':
        return Color(0xFFF7E1A0);
      case 'I':
        return Color(0xFFE2E2E2);
      case 'J':
        return Color(0xFF1CBE4F);
      case 'K':
        return Color(0xFFC4451C);
      case 'L':
        return Color(0xFFDEA0FD);
      case 'M':
        return Color(0xFFFE00FA);
      case 'N':
        return Color(0xFF325A9B);
      case 'O':
        return Color(0xFFFEAF16);
      case 'P':
        return Color(0xFFF8A19F);
      case 'Q':
        return Color(0xFF90AD1C);
      case 'R':
        return Color(0xFFF6222E);
      case 'S':
        return Color(0xFF1CFFCE);
      case 'T':
        return Color(0xFF2ED9FF);
      case 'U':
        return Color(0xFFB10DA1);
      case 'V':
        return Color(0xFFC075A6);
      case 'W':
        return Color(0xFFFC1CBF);
      case 'X':
        return Color(0xFFB00068);
      case 'Y':
        return Color(0xFFFBE426);
      case 'Z':
        return Color(0xFFFA0087);
      case '@':
        return Color(0xFFAA0DFE);

      default:
        return Color(0xFFAA0DFE);
    }
  }
}
