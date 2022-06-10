import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_service.dart';

class OverlayService {
  OverlayService._();
  static final OverlayService _instance = OverlayService._();
  static OverlayService get instance => _instance;
  OverlayEntry? snackBarOverlayEntry;

  showOverlay(FLUSHBAR_STATUS flushbarStatus) async {
    hideOverlay();

    snackBarOverlayEntry = _buildSnackBarOverlayEntry(flushbarStatus);
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

  OverlayEntry _buildSnackBarOverlayEntry(FLUSHBAR_STATUS flushbarStatus) {
    Color bgColor = _getColor(flushbarStatus);

    return OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Consumer<FileProgressProvider>(
        builder: (_context, provider, _) {
          String text = _getText(flushbarStatus,
              fileTransferProgress: provider.sentFileTransferProgress);
          return Positioned(
            width: size.width,
            height: 100,
            bottom: 0,
            child: Material(
              child: Container(
                alignment: Alignment.center,
                color: bgColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    flushbarStatus == FLUSHBAR_STATUS.SENDING
                        ? provider.sentFileTransferProgress != null
                            ? getProgressBar(provider.sentFileTransferProgress!)
                            : LinearProgressIndicator()
                        : SizedBox(),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: flushbarStatus ==
                                            FLUSHBAR_STATUS.SENDING
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 18.toFont,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  getFileUploadMessage(
                                    provider.sentFileTransferProgress,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              hideOverlay();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 7),
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
        },
      );
    });
  }

  String _getText(FLUSHBAR_STATUS flushbarStatus,
      {FileTransferProgress? fileTransferProgress}) {
    switch (flushbarStatus) {
      case FLUSHBAR_STATUS.SENDING:
        String sendingMessage = transferMessages[0];
        if (fileTransferProgress != null) {
          if (fileTransferProgress.fileState == FileState.encrypt) {
            sendingMessage = 'Encrypting ${fileTransferProgress.fileName}';
          } else if (fileTransferProgress.fileState == FileState.upload) {
            sendingMessage = 'Uploading ${fileTransferProgress.fileName}';
          } else if (fileTransferProgress.fileState == FileState.processing) {
            sendingMessage = 'Uploading ${fileTransferProgress.fileName}';
          }
        }
        return sendingMessage;
      case FLUSHBAR_STATUS.DONE:
        return transferMessages[1];
      case FLUSHBAR_STATUS.FAILED:
        return transferMessages[2];
      default:
        return '';
    }
  }

  String getFileUploadMessage(FileTransferProgress? fileTransferProgress) {
    String uploadMessage = '';

    if (fileTransferProgress?.fileState == FileState.upload &&
        fileTransferProgress?.percent != null) {
      var fileSize = fileTransferProgress?.percent ?? 0;
      if (fileSize < 2000000) {
        uploadMessage = 'This might take around 5 seconds...';
      } else if (fileSize < 10000000) {
        uploadMessage = 'This might take around 10 seconds...';
      } else if (fileSize < 60000000) {
        uploadMessage = 'This might take around 1 minutes...';
      } else if (fileSize < 20000000) {
        uploadMessage = 'This might take around 4 minutes...';
      } else {
        uploadMessage = 'This might take a while...';
      }
    }

    return uploadMessage;
  }

  Widget getProgressBar(FileTransferProgress fileTransferProgress) {
    if (fileTransferProgress.fileState == FileState.upload &&
        fileTransferProgress.percent != null) {
      var percent = fileTransferProgress.percent! / 100;
      return LinearProgressIndicator(value: percent);
    }
    return LinearProgressIndicator();
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
