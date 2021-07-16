import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_popup_route.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class LoadingDialog {
  LoadingDialog._();

  static LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  show({String text}) {
    if (!_showing) {
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: (text != null)
                      ? onlyText(text)
                      : CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  hide() {
    print("hide called");
    if (_showing) {
      NavService.navKey.currentState.pop();
      _showing = false;
    }
  }

  showTextLoader(String text, {TextStyle style}) {
    if (!_showing) {
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: onlyText(text, style: style),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  onlyText(String text, {TextStyle style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            textScaleFactor: 1,
            style: style ??
                TextStyle(
                    color: ColorConstants.MILD_GREY,
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
          ),
        ),
        TypingIndicator(
          showIndicator: true,
          flashingCircleBrightColor: ColorConstants.dullText,
          flashingCircleDarkColor: ColorConstants.fadedText,
        ),
      ],
    );
  }
}
