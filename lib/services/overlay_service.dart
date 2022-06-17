import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'navigation_service.dart';

class OverlayService {
  OverlayService._();
  static final OverlayService _instance = OverlayService._();
  static OverlayService get instance => _instance;
  OverlayEntry? snackBarOverlayEntry;

  showOverlay(FLUSHBAR_STATUS flushbarStatus, {String? errorMessage}) async {
    hideOverlay();

    snackBarOverlayEntry =
        _buildSnackBarOverlayEntry(flushbarStatus, errorMessage: errorMessage);
    NavService.navKey.currentState?.overlay?.insert(snackBarOverlayEntry!);

    if (flushbarStatus == FLUSHBAR_STATUS.DONE) {
      await Future.delayed(Duration(seconds: 3));
      hideOverlay();
    }
  }

  hideOverlay() {
    snackBarOverlayEntry?.remove();
    snackBarOverlayEntry = null;
  }

  OverlayEntry _buildSnackBarOverlayEntry(
    FLUSHBAR_STATUS flushbarStatus, {
    String? errorMessage,
  }) {
    String text = errorMessage ?? _getText(flushbarStatus);
    Color bgColor = _getColor(flushbarStatus);

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
            child: Column(
              children: [
                flushbarStatus == FLUSHBAR_STATUS.SENDING
                    ? LinearProgressIndicator()
                    : SizedBox(),
                Padding(
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
                            color: flushbarStatus == FLUSHBAR_STATUS.SENDING
                                ? Colors.black
                                : Colors.white,
                            fontSize: 18.toFont,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          hideOverlay();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                          ),
                          child: Text(
                            TextStrings().buttonDismiss,
                            style: TextStyle(
                              color: ColorConstants.fontPrimary,
                              fontSize: 15.toFont,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getText(FLUSHBAR_STATUS flushbarStatus) {
    switch (flushbarStatus) {
      case FLUSHBAR_STATUS.SENDING:
        return transferMessages[0];
      case FLUSHBAR_STATUS.DONE:
        return transferMessages[1];
      case FLUSHBAR_STATUS.FAILED:
        return transferMessages[2];
      default:
        return '';
    }
  }

  Color _getColor(FLUSHBAR_STATUS flushbarStatus) {
    switch (flushbarStatus) {
      case FLUSHBAR_STATUS.SENDING:
        return Colors.amber;
      case FLUSHBAR_STATUS.DONE:
        return Color(0xFF5FAA45);
      case FLUSHBAR_STATUS.FAILED:
        return ColorConstants.redAlert;
      default:
        return Colors.amber;
    }
  }

  List<String> transferMessages = [
    'Sending file(s) ...',
    'File(s) sent',
    'Oops! something went wrong'
  ];
}
