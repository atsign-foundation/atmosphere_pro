import 'dart:ui';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/linear_progress_bar.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'navigation_service.dart';
import '../data_models/file_transfer_status.dart';

class OverlayService {
  OverlayService._();

  static final OverlayService _instance = OverlayService._();

  static OverlayService get instance => _instance;
  OverlayEntry? snackBarOverlayEntry;

  void showOverlay() {
    hideOverlay();
    snackBarOverlayEntry = _buildSnackBarOverlayEntry();
    NavService.navKey.currentState?.overlay?.insert(snackBarOverlayEntry!);
    return null;
  }

  void hideOverlay() {
    snackBarOverlayEntry?.remove();
    snackBarOverlayEntry = null;
  }

  OverlayEntry _buildSnackBarOverlayEntry() {
    Color bgColor = Colors.white;

    return OverlayEntry(
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: StreamBuilder<FLUSHBAR_STATUS>(
            stream: FileTransferProvider().flushBarStatusStream,
            builder: (context, snapshot) {
              final flushbarStatus = snapshot.data ?? FLUSHBAR_STATUS.SENDING;
              return Consumer<FileProgressProvider>(
                builder: (_context, provider, _) {
                  String text = _getText(
                    flushbarStatus,
                    fileTransferProgress: provider.sentFileTransferProgress,
                  );

                  String icon = getImage(flushbarStatus);
                  return Scaffold(
                    backgroundColor: bgColor.withOpacity(0.7),
                    body: SafeArea(
                      child: Material(
                        color: bgColor.withOpacity(0.7),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: 24, right: 14),
                                child: InkWell(
                                  onTap: () {
                                    hideOverlay();
                                    if (flushbarStatus !=
                                            FLUSHBAR_STATUS.DONE &&
                                        flushbarStatus !=
                                            FLUSHBAR_STATUS.FAILED) {
                                      WelcomeScreenProvider()
                                          .changeOverlayStatus(false);
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    AppVectors.icClose,
                                    height: 52,
                                    width: 52,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(icon),
                                  SizedBox(height: 40),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 3,
                                      horizontal: 15,
                                    ),
                                    child: Text(
                                      text,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25.toFont,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  flushbarStatus == FLUSHBAR_STATUS.SENDING
                                      ? getProgressBar()
                                      : _buildHistoryButton(),
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
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 80),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          hideOverlay();
          Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext!,
            Routes.WELCOME_SCREEN,
            (route) => false,
            arguments: {
              "indexBottomBarSelected": 3,
            },
          );
        },
        child: Container(
          width: 160.toWidth,
          height: 36.toHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorConstants.grey),
          ),
          child: Center(
            child: Text(
              'See History',
              style: TextStyle(
                color: ColorConstants.grey,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getText(FLUSHBAR_STATUS flushbarStatus,
      {FileTransferProgress? fileTransferProgress}) {
    switch (flushbarStatus) {
      case FLUSHBAR_STATUS.SENDING:
        String sendingMessage = transferMessages[0];
        if (fileTransferProgress != null) {
          if (fileTransferProgress.fileState == FileState.encrypt) {
            sendingMessage = 'Encrypting your files';
          } else if (fileTransferProgress.fileState == FileState.upload) {
            sendingMessage = 'Sending your files';
          } else if (fileTransferProgress.fileState == FileState.processing) {
            sendingMessage = 'Sending your files';
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

  String getImage(FLUSHBAR_STATUS flushbarStatus) {
    switch (flushbarStatus) {
      case FLUSHBAR_STATUS.SENDING:
        return ImageConstants.sendFileIcon;
      case FLUSHBAR_STATUS.DONE:
        return ImageConstants.iconSuccess;
      case FLUSHBAR_STATUS.FAILED:
        return ImageConstants.iconWarning;
      default:
        return ImageConstants.sendFileIcon;
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
    return SizedBox(
      width: 300.toWidth,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        child: ProgressBarAnimation(
          height: 45,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF05E3F),
              Color(0xFFEAA743),
            ],
          ),
          backgroundColor: Color(0xFFE2E2E2),
        ),
      ),
    );
  }

/*  Color _getColor(FLUSHBAR_STATUS flushbarStatus) {
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
  }*/

  List<String> transferMessages = [
    'Sending your files',
    'Success!',
    'Something went wrong,\nplease try again!',
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
