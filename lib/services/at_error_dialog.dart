import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_commons/at_commons.dart';

class AtErrorDialog {
  static getAlertDialog(var error, BuildContext context) {
    String errorMessage = _getErrorMessage(error);
    var title = TextStrings().error;
    return AlertDialog(
      title: Row(
        children: [
          Text(title, style: CustomTextStyles.primaryMedium14),
          const Icon(Icons.sentiment_dissatisfied)
        ],
      ),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(TextStrings().buttonClose),
        )
      ],
    );
  }

  ///Returns corresponding errorMessage for [error].
  static String _getErrorMessage(var error) {
    switch (error.runtimeType) {
      case AtClientException:
        return TextStrings().unableToPerform;
      case UnAuthenticatedException:
        return TextStrings().unableToAuthenticate;
      case NoSuchMethodError:
        return TextStrings().failedInProcessing;
      case AtConnectException:
        return TextStrings().unableToConnectServer;
      case AtIOException:
        return TextStrings().unableToPerformRead_Write;
      case AtServerException:
        return TextStrings().unableToActivateServer;
      case SecondaryNotFoundException:
        return TextStrings().serverIsUnavailable;
      case SecondaryConnectException:
        return TextStrings().unableToConnect;
      case InvalidAtSignException:
        return TextStrings().invalidAtSign;
      case String:
        return error;
      default:
        return TextStrings().unknownError;
    }
  }
}
