import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_client/at_client.dart';
import 'package:at_commons/at_commons.dart';

class AtErrorDialog {
  static getAlertDialog(var error, BuildContext context) {
    String errorMessage = _getErrorMessage(error);
    var title = TextStrings().error;
    return AlertDialog(
      title: Row(
        children: [
          Text(title, style: CustomTextStyles.primaryMedium14),
          Icon(Icons.sentiment_dissatisfied)
        ],
      ),
      content: Text('$errorMessage'),
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
        break;
      case UnAuthenticatedException:
        return TextStrings().unableToAuthenticate;
        break;
      case NoSuchMethodError:
        return TextStrings().failedInProcessing;
        break;
      case AtConnectException:
        return TextStrings().unableToConnectServer;
        break;
      case AtIOException:
        return TextStrings().unableToPerformRead_Write;
        break;
      case AtServerException:
        return TextStrings().unableToActivateServer;
        break;
      case SecondaryNotFoundException:
        return TextStrings().serverIsUnavailable;
        break;
      case SecondaryConnectException:
        return TextStrings().unableToConnect;
        break;
      case InvalidAtSignException:
        return TextStrings().invalidAtSign;
        break;
      case String:
        return error;
        break;
      default:
        return TextStrings().unknownError;
        break;
    }
  }
}
