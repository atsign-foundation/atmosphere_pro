import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_service.dart';
import '../data_models/file_transfer_status.dart';

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
    } else if (flushbarStatus == FLUSHBAR_STATUS.FAILED) {
      await Future.delayed(Duration(seconds: 5));
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
    // Color bgColor = _getColor(flushbarStatus);
    Color bgColor = Colors.white;

    String text = errorMessage ?? _getText(flushbarStatus);

    return OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Consumer<FileProgressProvider>(
        builder: (_context, provider, _) {
          text = errorMessage ??
              _getText(
                flushbarStatus,
                fileTransferProgress: provider.sentFileTransferProgress,
              );
          return Scaffold(
            backgroundColor: bgColor.withOpacity(0.7),
            body: SafeArea(
              child: Container(
                width: size.width,
                height: SizeConfig().screenHeight,
                child: Material(
                  color: bgColor.withOpacity(0.7),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: hideOverlay,
                          child: Container(
                            width: 105.toWidth,
                            height: 35,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ColorConstants.grey),
                            ),
                            child: Center(
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(ImageConstants.sendFileIcon),
                            SizedBox(height: 40),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          text,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25.toFont,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            flushbarStatus == FLUSHBAR_STATUS.SENDING
                                ? provider.sentFileTransferProgress != null
                                    ? getProgressBar()
                                    : getProgressBar()
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
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
        fileTransferProgress?.fileSize != null) {
      var fileSize = fileTransferProgress?.fileSize ?? 0;
      if (fileSize < 2000000) {
        uploadMessage = 'This might take around 5 seconds...';
      } else if (fileSize < 10000000) {
        uploadMessage = 'This might take around 10 seconds...';
      } else if (fileSize < 60000000) {
        uploadMessage = 'This might take around 1 minutes...';
      } else if (fileSize < 20000000) {
        uploadMessage = 'This might take around 4 minutes...';
      } else if (fileSize < 50000000) {
        uploadMessage = 'This might take around 6 minutes...';
      } else if (fileSize < 100000000) {
        uploadMessage = 'This might take around 11 minutes...';
      } else {
        uploadMessage = 'This might take a while...';
      }
    }

    return uploadMessage;
  }

  Widget getProgressBar() {
    /// Not showing upload percent
    // if (fileTransferProgress.fileState == FileState.upload &&
    // fileTransferProgress.percent != null) {
    // var percent = fileTransferProgress.percent! / 100;
    // return LinearProgressIndicator();
    // }
    return SizedBox(
      width: 300.toWidth,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        child: LinearProgressIndicator(
          color: ColorConstants.yellow,
          minHeight: 45,
          backgroundColor: Color(0xFFE2E2E2),
        ),
      ),
    );
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
    'Sending your files',
    'Success!🎉 ',
    'Something went wrong! ⚠️',
  ];

  openFileReceiptBottomSheet(context,
      {FileRecipientSection? fileRecipientSection =
          FileRecipientSection.FAILED}) {
    var _historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    Provider.of<FileTransferProvider>(context, listen: false)
        .selectedFileHistory = _historyProvider.sentHistory[0];
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (_context) {
          return Container(
            height: SizeConfig().screenHeight * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: FileRecipients(
              _historyProvider.sentHistory[0].sharedWith,
              fileRecipientSection: fileRecipientSection,
              key: UniqueKey(),
            ),
          );
        });
  }
}
