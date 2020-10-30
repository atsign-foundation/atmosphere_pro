import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_popup_route.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class ErrorDialogWidget extends StatelessWidget {
  final String text;
  final String buttonText;
  final Function onButtonPress;
  final bool includeCancel;

  ErrorDialogWidget({
    @required this.text,
    this.buttonText,
    this.onButtonPress,
    this.includeCancel,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          height: 240.toHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.toFont,
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20.toWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.toHeight),
              Text(
                TextStrings().errorOccured,
                style: CustomTextStyles.primaryBold18,
              ),
              SizedBox(height: 10.toHeight),
              Text(
                text,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.toHeight),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      buttonText: 'OK',
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onButtonPress != null) onButtonPress();
                      },
                    ),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorDialog {
  ErrorDialog._();

  static ErrorDialog _instance = ErrorDialog._();

  factory ErrorDialog() => _instance;
  bool _showing = false;
  var appLocal;

  show(String text,
      {String buttonText,
      Function onButtonPressed,
      @required BuildContext context,
      bool includeCancel = false}) {
    if (!_showing) {
      _showing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavService.navKey.currentState
            .push(
          CustomPopupRoutes(
              pageBuilder: (_, __, ___) => ErrorDialogWidget(
                    text: text.toString(),
                    buttonText: (buttonText == null) ? 'ok' : buttonText,
                    onButtonPress: onButtonPressed,
                    includeCancel: includeCancel,
                  ),
              barrierDismissible: true),
        )
            .then((_) {
          print("hidden error");
          _showing = false;
        });
      });
    }
  }

  hide() {
    if (_showing) NavService.navKey.currentState.pop();
  }
}
