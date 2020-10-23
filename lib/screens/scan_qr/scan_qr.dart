import 'dart:io';

import 'package:archive/archive.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_app/services/at_error_dialog.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/scan_qr_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({Key key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QrReaderViewController _controller;
  BackendService backendService = BackendService.getInstance();
  ScanQrProvider qrProvider = ScanQrProvider();
  bool loading = false;
  bool cameraPermissionGrated = false;
  bool scanCompleted = false;

  String _incorrectKeyFile =
      'Unable to fetch the keys from chosen file. Please choose correct file';
  String _failedFileProcessing = 'Failed in processing files. Please try again';

  @override
  void initState() {
    askCameraPermission();
    super.initState();
  }

  askCameraPermission() async {
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

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   BuildContext c = NavService.navKey.currentContext;
  //   if (qrProvider.status['cram'] == Status.Error) {
  //     showDialog(
  //       context: c,
  //       barrierDismissible: true,
  //       builder: (context) => Container(
  //         height: 40,
  //         width: 40,
  //         color: Colors.red,
  //       ),
  //     );
  //   }
  //   super.didChangeDependencies();
  // }
  void _uploadCramKeyFile() async {
    try {
      String cramKey;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      // setState(() {
      //   loading = true;
      // });
      for (var file in result.files) {
        if (cramKey == null) {
          String result = await FlutterQrReader.imgScan(File(file.path));
          if (result.contains('@')) {
            cramKey = result;
            break;
          } //read scan QRcode and extract atsign,aeskey
        }
      }

      if (cramKey == null) {
        // _showAlertDialog(_incorrectKeyFile);
        showSnackBar(context, "File content error");
        setState(() {
          loading = true;
        });
      } else {
        String authenticateMessage =
            await backendService.authenticate(cramKey, context);

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
    } on Exception catch (ex) {
      setState(() {
        loading = false;
      });
    }
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
              isInverted: true,
              buttonText: TextStrings().upload,
              onPressed: _uploadCramKeyFile,
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            // CustomButton(
            //   width: 230.toWidth,
            //   buttonText: TextStrings().uploadKey,
            //   onPressed: _uploadKeyFile,
            //   onPressed: () {
            //     providerCallback<ScanQrProvider>(context,
            //         task: (provider) => provider.uploadKeyFile(),
            //         taskName: (provider) => provider.uploadKey,
            //         onSuccess: (provider) =>
            //             (provider.aesKeyResponse) ??
            //             Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN),
            //         onError: (err) =>
            //             ErrorDialog().show(err.toString(), context: context));
            //   },
            // ),
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
