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
  bool scanCompleted = false;

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

  showSnackBar(BuildContext context, messageText) {
    final snackBar = SnackBar(content: Text(messageText));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void onScan(String data, List<Offset> offsets, context) async {
    print("here scan completed => $data ");
    this.setState(() {
      scanCompleted = true;
    });
    String authenticateMessage =
        await backendService.authenticate(data, context);

    print("message from authenticate => $authenticateMessage");
    showSnackBar(context, authenticateMessage);
    this.setState(() {
      scanCompleted = false;
    });

    _controller.stopCamera();
  }

  void _uploadCramKeyFile() async {
    try {
      String cramKey;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      print("it is called  => $result");
      // setState(() {
      //   loading = true;
      // });
      for (var file in result.files) {
        print("it is comming here => $file");
        if (cramKey == null) {
          String result = await FlutterQrReader.imgScan(File(file.path));
          print("resultttt => $result");
          if (result.contains('@')) {
            cramKey = result;
            break;
          } //read scan QRcode and extract atsign,aeskey
        }
      }
      print("hererere => $cramKey");

      if (cramKey == null) {
        // _showAlertDialog(_incorrectKeyFile);
        print("herree also");
        print("show file content error");
        showSnackBar(context, "show file content error");
        setState(() {
          loading = true;
        });
      } else {
        String authenticateMessage =
            await backendService.authenticate(cramKey, context);

        print("message from authenticate => $authenticateMessage");
        showSnackBar(context, authenticateMessage);
        setState(() {
          loading = false;
        });
      }
      // await _processAESKey(atsign, aesKey, fileContents);
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

  void _uploadKeyFile() async {
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
      await backendService.startMonitor();
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
            Builder(
              builder: (context) => Container(
                alignment: Alignment.center,
                width: 300.toWidth,
                height: 350.toHeight,
                color: Colors.black,
                child: !cameraPermissionGrated
                    ? SizedBox()
                    : Stack(
                        children: [
                          QrReaderView(
                            width: 300.toWidth,
                            height: 350.toHeight,
                            callback: (container) {
                              this._controller = container;
                              _controller.startCamera((data, offsets) {
                                onScan(data, offsets, context);
                              });
                            },
                          ),
                          scanCompleted
                              ? Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          ColorConstants.redText)),
                                )
                              : SizedBox()
                        ],
                      ),
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
            CustomButton(
              width: 230.toWidth,
              buttonText: TextStrings().uploadCram,
              onPressed: _uploadCramKeyFile,
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
          ],
        ),
      ),
    );
  }
}
