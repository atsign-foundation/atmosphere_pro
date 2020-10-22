import 'dart:io';

import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({Key key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QrReaderViewController _controller;
  BackendService backendService = BackendService.getInstance();
  bool loading = false;
  bool cameraPermissionGrated = false;

  @override
  void initState() {
    askCameraPermission();
    super.initState();
  }

  askCameraPermission() async {
    print("called herer");
    var status = await Permission.camera.status;
    print("camera status => $status");
    if (status.isUndetermined) {
      // We didn't ask for permission yet.
      await [
        Permission.camera,
        Permission.storage,
      ].request();
      this.setState(() {
        cameraPermissionGrated = true;
      });
    } else {
      this.setState(() {
        cameraPermissionGrated = true;
      });
    }
  }

  void onScan(String data, List<Offset> offsets) {
    print([data, offsets]);
    backendService.authenticate(data, context);
    _controller.stopCamera();
  }

  void _cramAuthWithoutQR() async {
    String aliceSecret =
        'b26455a907582760ebf35bc4847de549bc41c24b25c8b1c58d5964f7b4f8a43bc55b0e9a601c9a9657d9a8b8bbc32f88b4e38ffaca03c8710ebae1b14ca9f364';
    String colinSecret =
        "540f1b5fa05b40a58ea7ef82d3cfcde9bb72db8baf4bc863f552f82695837b9fee631f773ab3e34dde05b51e900220e6ae6f7240ec9fc1d967252e1aea4064ba";
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

  void _uploadKeyFile() async {
    print("upload file");
    try {
      String fileContents, aesKey, atsign;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      setState(() {
        loading = true;
      });
      for (var file in result.files) {
        if (file.path.contains('atKeys')) {
          fileContents = File(file.path).readAsStringSync();
        } else if (aesKey == null &&
            atsign == null &&
            file.path.contains('_private_key.png')) {
          String result = await FlutterQrReader.imgScan(File(file.path));
          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
          //read scan QRcode and extract atsign,aeskey
        }
      }
      if (fileContents == null || (aesKey == null && atsign == null)) {
        // _showAlertDialog(_incorrectKeyFile);
        print("show file content error");
      }
      await _processAESKey(atsign, aesKey, fileContents);
    } on Error catch (error) {
      setState(() {
        loading = false;
      });
      // _logger.severe('Processing files throws $error');
      // _showAlertDialog(_failedFileProcessing);
    } on Exception catch (ex) {
      setState(() {
        loading = false;
      });
      // _logger.severe('Processing files throws $ex');
      // _showAlertDialog(_failedFileProcessing);
    }
  }

  _processAESKey(String atsign, String aesKey, String contents) async {
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != null || contents != '');
    await backendService
        .authenticateWithAESKey(atsign, jsonData: contents, decryptKey: aesKey)
        .then((response) async {
      if (response) {
        await Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN);
      }
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print("Error in authenticateWithAESKey");
      // _showAlertDialog(err);
      // setState(() {
      //   loading = false;
      // });
      // _logger.severe('Scanning QR code throws $err Error');
    });
  }

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TextStrings().scanQrTitle,
        showTitle: true,
        showLeadingicon: true,
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
            Container(
              alignment: Alignment.center,
              width: 300.toWidth,
              height: 350.toHeight,
              color: Colors.black,
              child: !cameraPermissionGrated
                  ? SizedBox()
                  : QrReaderView(
                      width: 300.toWidth,
                      height: 350.toHeight,
                      callback: (container) {
                        this._controller = container;
                        _controller.startCamera(onScan);
                      },
                    ),
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            Center(child: Text('OR')),
            SizedBox(
              height: 25.toHeight,
            ),
            CustomButton(
              width: 230.toWidth,
              buttonText: TextStrings().upload,
              onPressed: _uploadKeyFile,
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => WebsiteScreen(
                        url: MixedConstants.WEBSITE_URL,
                        title: TextStrings().websiteTitle),
                  ),
                );
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
