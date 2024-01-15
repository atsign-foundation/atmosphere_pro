import 'package:flutter/material.dart';

import 'colors.dart';

class Themes {
  static ThemeData lightTheme({
    Color highlightColor = ColorConstants.raisinBlack,
    String? fontFamily,
  }) {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primaryColor: ColorConstants.desktopPrimary,
      primaryColorDark: ColorConstants.raisinBlack,
      canvasColor: Colors.white,
      highlightColor: highlightColor,
      scaffoldBackgroundColor: ColorConstants.scaffoldBackgroundColor,
      fontFamily: fontFamily ?? 'HelveticaNeu',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ThemeData.dark().colorScheme.copyWith(
            brightness: Brightness.light,
            primary: ColorConstants.desktopPrimary,
            background: getBackgroundColor(highlightColor),
          ),
    );
  }

  static Color getBackgroundColor(Color color) {
    String colorStr = color.toString().toLowerCase().substring(10, 16);

    if (colorStr.toUpperCase() == 'BB86FC') {
      return color.withOpacity(0.3);
    } else if (colorStr == '3FC0F3') {
      return color.withOpacity(0.05);
    } else if (colorStr == 'A77D60') {
      return color.withOpacity(0.05);
    } else if (colorStr == 'C47E61') {
      return color.withOpacity(0.05);
    } else {
      return color.withOpacity(0.1);
    }
  }
}
