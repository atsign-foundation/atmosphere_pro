import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_client/at_client.dart';
import 'package:at_commons/at_commons.dart';

class AtErrorDialog {
  static getAlertDialog(var error, BuildContext context) {
    String errorMessage = _getErrorMessage(error);
    var title = 'Error';
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
          child: Text('Close'),
        )
      ],
    );
  }

  ///Returns corresponding errorMessage for [error].
  static String _getErrorMessage(var error) {
    switch (error.runtimeType) {
      case AtClientException:
        return 'Unable to perform this action. Please try again.';
        break;
      case UnAuthenticatedException:
        return 'Unable to authenticate. Please try again.';
        break;
      case NoSuchMethodError:
        return 'Failed in processing. Please try again.';
        break;
      case AtConnectException:
        return 'Unable to connect server. Please try again later.';
        break;
      case AtIOException:
        return 'Unable to perform read/write operation. Please try again.';
        break;
      case AtServerException:
        return 'Unable to activate server. Please contact admin.';
        break;
      case SecondaryNotFoundException:
        return 'Server is unavailable. Please try again later.';
        break;
      case SecondaryConnectException:
        return 'Unable to connect. Please check with network connection and try again.';
        break;
      case InvalidAtSignException:
        return 'Invalid atsign is provided. Please contact admin.';
        break;
      case String:
        return error;
        break;
      default:
        return 'Unknown error.';
        break;
    }
  }
}
