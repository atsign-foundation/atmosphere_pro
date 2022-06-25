import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
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

  showOverlay(FlushbarStatus flushbarStatus) async {
    hideOverlay();

    snackBarOverlayEntry = _buildSnackBarOverlayEntry(flushbarStatus);
    NavService.navKey.currentState?.overlay?.insert(snackBarOverlayEntry!);

    if (flushbarStatus == FlushbarStatus.DONE) {
      await Future.delayed(Duration(seconds: 3));
      hideOverlay();
    } else if (flushbarStatus == FlushbarStatus.FAILED) {
      await Future.delayed(Duration(seconds: 5));
      hideOverlay();
    }
  }

  hideOverlay() {
    snackBarOverlayEntry?.remove();
    snackBarOverlayEntry = null;
  }

  OverlayEntry _buildSnackBarOverlayEntry(FlushbarStatus flushbarStatus) {
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
                    flushbarStatus == FlushbarStatus.SENDING
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        flushbarStatus == FlushbarStatus.SENDING
                                            ? Colors.black
                                            : Colors.white,
                                    fontSize: 16.toFont,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  getFileUploadMessage(
                                    provider.sentFileTransferProgress,
                                  ),
                                  style: TextStyle(fontSize: 12.toFont),
                                ),
                              ],
                            ),
                          ),
                          flushbarStatus == FlushbarStatus.FAILED
                              ? TextButton(
                                  onPressed: () {
                                    openFileReceiptBottomSheet(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      TextStrings.buttonShowMore,
                                      style: TextStyle(
                                        color: ColorConstants.fontPrimary,
                                        fontSize: 15.toFont,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                )
                              : TextButton(
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
                                      TextStrings.buttonDismiss,
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

  String _getText(FlushbarStatus flushbarStatus,
      {FileTransferProgress? fileTransferProgress}) {
    switch (flushbarStatus) {
      case FlushbarStatus.SENDING:
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
      case FlushbarStatus.DONE:
        return transferMessages[1];
      case FlushbarStatus.FAILED:
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

  Widget getProgressBar(FileTransferProgress fileTransferProgress) {
    /// Not showing upload percent
    // if (fileTransferProgress.fileState == FileState.upload &&
    // fileTransferProgress.percent != null) {
    // var percent = fileTransferProgress.percent! / 100;
    // return LinearProgressIndicator();
    // }
    return LinearProgressIndicator();
  }

  Color _getColor(FlushbarStatus flushbarStatus) {
    switch (flushbarStatus) {
      case FlushbarStatus.SENDING:
        return Colors.amber;
      case FlushbarStatus.DONE:
        return Color(0xFF5FAA45);
      case FlushbarStatus.FAILED:
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
