import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import '../../services/backend_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';
import '../../utils/text_strings.dart';

class CustomFlushBar {
  CustomFlushBar._();

  static CustomFlushBar _instance = CustomFlushBar._();

  factory CustomFlushBar() => _instance;

  Flushbar f;
  AnimationController currentController;
  BackendService backendService = BackendService.getInstance();

  Flushbar getFlushbar(
      String displayMessage, AnimationController progressController,
      {String buttonMessage}) {
    if (currentController == null) {
      currentController = progressController;
    } else {
      f?.dismiss();
    }
    SizeConfig().init(NavService.navKey.currentContext);
    f = Flushbar(
      title: displayMessage,
      message: 'hello',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: ColorConstants.scaffoldColor,
      boxShadows: [
        BoxShadow(
            color: Colors.black, offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: Duration(seconds: 5),
      icon: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImageConstants.imagePlaceholder),
              fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
      ),
      progressIndicatorValueColor:
          AlwaysStoppedAnimation<Color>(ColorConstants.orangeColor),
      progressIndicatorController: progressController,
      mainButton: FlatButton(
        onPressed: () {
          if (f.isShowing()) {
            f.dismiss();
          }
        },
        child: Text(
          buttonMessage ?? TextStrings().buttonDismiss,
          style: TextStyle(color: ColorConstants.fontPrimary),
        ),
      ),
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED) {
          backendService.controller = null;
        }
      },
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Column(
        children: [
          Row(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 13.toFont,
                color: ColorConstants.successColor,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 5.toWidth,
                ),
                child: Text(
                  displayMessage,
                  style: TextStyle(
                      color: ColorConstants.fadedText, fontSize: 10.toFont),
                ),
              )
            ],
          ),
        ],
      ),
    );
    return f;
  }
}
