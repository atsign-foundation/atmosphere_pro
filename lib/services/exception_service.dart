import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'navigation_service.dart';

class ExceptionService {
  ExceptionService._();
  static final ExceptionService _instance = ExceptionService._();
  static ExceptionService get instance => _instance;
  OverlayEntry? exceptionOverlayEntry;

  showGetExceptionOverlay(Object e, {Function? onRetry}) async {
    var _error = _getExceptions(e);
    _showExceptionOverlay(_error, onRetry: onRetry);
  }

  showPutExceptionOverlay(Object e, {Function? onRetry}) async {
    var _error = _putExceptions(e);
    _showExceptionOverlay(_error, onRetry: onRetry);
  }

  /// exceptions for get method
  String _getExceptions(Object e) {
    switch (e) {
      case AtKeyException:
        return 'AtKeyException: Something went wrong';
      case AtDecryptionException:
        return 'AtDecryptionException: Decryption failed';
      case AtPrivateKeyNotFoundException:
        return 'AtPrivateKeyNotFoundException: Decryption failed';
      case AtPublicKeyChangeException:
        return 'AtPublicKeyChangeException: Decryption failed';
      case SharedKeyNotFoundException:
        return 'SharedKeyNotFoundException: Decryption failed';
      case SelfKeyNotFoundException:
        return 'SelfKeyNotFoundException: Decryption failed';
      case AtClientException:
        return 'AtClientException: Cloud secondary is invalid or not reachable';

      default:
        return 'Something went wrong !!!';
    }
  }

  /// exceptions for put method
  String _putExceptions(Object e) {
    switch (e) {
      default:
        return 'Something went wrong !!!';
    }
  }

  //// UI part
  _showExceptionOverlay(String error, {Function? onRetry}) async {
    hideOverlay();

    exceptionOverlayEntry = _buildexceptionOverlayEntry(
      error,
      onRetry: onRetry,
    );
    NavService.navKey.currentState?.overlay?.insert(exceptionOverlayEntry!);

    await Future.delayed(Duration(seconds: 5));
    hideOverlay();
  }

  hideOverlay() {
    exceptionOverlayEntry?.remove();
    exceptionOverlayEntry = null;
  }

  OverlayEntry _buildexceptionOverlayEntry(String error, {Function? onRetry}) {
    Color bgColor = ColorConstants.redAlert;

    return OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        width: size.width,
        height: 80,
        bottom: 0,
        child: Material(
          child: Container(
            alignment: Alignment.center,
            color: bgColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 3, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$error',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  onRetry != null
                      ? TextButton(
                          onPressed: () {
                            hideOverlay();
                            onRetry();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                            ),
                            child: Text(
                              TextStrings().buttonRetry,
                              style: TextStyle(
                                color: ColorConstants.fontPrimary,
                                fontSize: 15.toFont,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
