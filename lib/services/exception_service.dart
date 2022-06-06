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

  String getExceptions(Object e) {
    switch (e) {
      case AtKeyException:
        return 'AtKeyException';
      case AtDecryptionException:
        return 'AtDecryptionException';
      case AtPrivateKeyNotFoundException:
        return 'AtPrivateKeyNotFoundException';
      case AtPublicKeyChangeException:
        return 'AtPublicKeyChangeException';
      case SharedKeyNotFoundException:
        return 'SharedKeyNotFoundException';
      case SelfKeyNotFoundException:
        return 'SelfKeyNotFoundException';
      case AtClientException:
        return 'AtClientException';

      default:
        return 'Something went wrong !!!';
    }
  }

  putExceptions(Object e) {
    switch (e) {
      default:
        return 'Something went wrong !!!';
    }
  }

  //// UI part
  showOverlayException(Object e,
      {bool isGetError = true, Function? onRetry}) async {
    hideOverlay();

    exceptionOverlayEntry = _buildexceptionOverlayEntry(
      e,
      isGetError: isGetError,
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

  OverlayEntry _buildexceptionOverlayEntry(
    Object e, {
    bool isGetError = true,
    Function? onRetry,
  }) {
    String text = isGetError ? getExceptions(e) : putExceptions(e);
    Color bgColor = ColorConstants.redAlert;

    return OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        width: size.width,
        height: 100,
        bottom: 0,
        child: Material(
          child: Container(
            alignment: Alignment.center,
            color: bgColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.toFont,
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
