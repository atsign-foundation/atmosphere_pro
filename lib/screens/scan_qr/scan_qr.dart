import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({Key key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  BackendService backendService = BackendService.getInstance();

  @override
  void initState() {
    super.initState();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      backendService.authenticate(scanData, context);
    });
  }

  void _cramAuthWithoutQR() async {
    // String colinSecret =
    //     "540f1b5fa05b40a58ea7ef82d3cfcde9bb72db8baf4bc863f552f82695837b9fee631f773ab3e34dde05b51e900220e6ae6f7240ec9fc1d967252e1aea4064ba";
    String kevinSecret =
        'e0d06915c3f81561fb5f8929caae64a7231db34fdeaff939aacac3cb736be8328c2843b518a2fc7a58fcec8c0aa98c735c0ce5f8ce880e97cd61cf1f2751efc5';
    await backendService
        .authenticateWithCram("@kevin🛠", cramSecret: kevinSecret)
        .then((response) async {
      print("auth successful $response");
      if (response != null) {
        await backendService.startMonitor();
        await Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN);
      }
    }).catchError((err) {
      print("error in cram auth: $err");
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TextStrings().scanQrTitle,
        showTitle: true,
        showBackButton: true,
        elevation: 5,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 25.toHeight),
        child: Column(
          children: [
            Text(
              TextStrings().scanQrMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.toFont,
                color: ColorConstants.greyText,
              ),
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            Expanded(
              child: Container(
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.WEBSITE_SCREEN);
              },
              child: Text(
                TextStrings().scanQrFooter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.toFont,
                  color: ColorConstants.redText,
                ),
              ),
            ),
            // Remove this block of code later.
            // Adding skip button for development & testing purpose.
            // start
            SizedBox(
              height: 15.toHeight,
            ),
            InkWell(
              onTap: () {
                _cramAuthWithoutQR();
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16.toFont,
                  color: ColorConstants.blueText,
                ),
              ),
            ),
            // end
          ],
        ),
      ),
    );
  }
}
