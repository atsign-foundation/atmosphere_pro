import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({Key key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanned;

  @override
  void initState() {
    scanned = false;
    super.initState();
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
                  onQRViewCreated: (controller) {
                    controller.scannedDataStream.listen((scanData) {
                      if (!scanned) {
                        scanned = true;
                        Navigator.of(context)
                            .pushNamed(Routes.WELCOME_SCREEN)
                            .then(
                              (value) => scanned = false,
                            );
                      }
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            Text(
              TextStrings().scanQrFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.toFont,
                color: ColorConstants.redText,
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
                Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN);
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
