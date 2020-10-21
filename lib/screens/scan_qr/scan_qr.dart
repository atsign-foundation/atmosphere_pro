import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/scan_qr_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void onScan(String data, List<Offset> offsets) {
    print([data, offsets]);
    backendService.authenticate(data, context);
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
              child: QrReaderView(
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
              onPressed: () {
                providerCallback<ScanQrProvider>(context,
                    task: (provider) => provider.uploadKeyFile(),
                    taskName: (provider) => provider.uploadKey,
                    onSuccess: (provider) =>
                        (provider.aesKeyResponse) ??
                        Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN),
                    onError: (err) =>
                        ErrorDialog().show(err.toString(), context: context));
              },
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
                providerCallback<ScanQrProvider>(context,
                    task: (provider) => provider.cramAuthWithoutQR(),
                    taskName: (provider) => 'cram_without_qr',
                    onSuccess: (provider) =>
                        Navigator.pushNamed(context, Routes.WELCOME_SCREEN),
                    onErrorHandeling: () {
                      // Navigator.pushNamed(context, Routes.WELCOME_SCREEN);
                    },
                    onError: (err) =>
                        ErrorDialog().show(err.toString(), context: context));
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16.toFont,
                  color: ColorConstants.blueText,
                ),
              ),
            )

            // end
          ],
        ),
      ),
    );
  }
}
