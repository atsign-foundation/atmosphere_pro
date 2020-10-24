import 'dart:async';

import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationService _notificationService;
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  // bool userAcceptance;
  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;
  Completer c = Completer();
  bool authenticating = false;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _initBackendService();
    _checkToOnboard();
    _checkForPermissionStatus();
  }

  void _initBackendService() {
    backendService = BackendService.getInstance();
    _notificationService.setOnNotificationClick(onNotificationClick);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      debugPrint('SystemChannels> $msg');
      backendService.app_lifecycle_state = msg;
    });
  }

  void _checkToOnboard() async {
    // onboard call to get the already setup atsigns
    await backendService.onboard().then((isChecked) async {
      if (!isChecked) {
        c.complete(true);
        print("onboard returned: $isChecked");
      } else {
        await backendService.startMonitor();
        onboardSuccess = true;
        c.complete(true);
      }
    }).catchError((error) async {
      c.complete(true);
      print("Error in authenticating: $error");
    });
  }

  void _checkForPermissionStatus() async {
    final existingCameraStatus = await _cameraPermission.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await _cameraPermission.request();
    }
    final existingStorageStatus = await _storagePermission.status;
    if (existingStorageStatus != PermissionStatus.granted) {
      await _storagePermission.request();
    }
  }

  onNotificationClick(String payload) async {
    // this popup added to accept stream to await answer
    // BuildContext c = NavService.navKey.currentContext;
    // print('Payload $payload');
    // bool userAcceptance = null;
    // await showDialog(
    //   context: c,
    //   builder: (c) => ReceiveFilesAlert(
    //     payload: payload,
    //     sharingStatus: (s) {
    //       // sharingStatus = s;
    //       userAcceptance = s;
    //       print('STATUS====>$s');
    //     },
    //   ),
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: SizeConfig().screenWidth,
            height: SizeConfig().screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10.toWidth,
                          top: 10.toHeight,
                        ),
                        child: Image.asset(
                          ImageConstants.logoIcon,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 36.toWidth,
                        vertical: 10.toHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              TextStrings().homeFileTransferItsSafe,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                  fontSize: 38.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text.rich(
                              TextSpan(
                                text: TextStrings().homeHassleFree,
                                style: TextStyle(
                                  fontSize: 15.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: TextStrings().homeWeWillSetupAccount,
                                    style: TextStyle(
                                      color: ColorConstants.fadedText,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CustomButton(
                                buttonText: TextStrings().buttonStart,
                                onPressed: () async {
                                  this.setState(() {
                                    authenticating = true;
                                  });
                                  await c.future;
                                  if (onboardSuccess) {
                                    await Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Routes.WELCOME_SCREEN,
                                        (route) => false);
                                  } else {
                                    await Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Routes.SCAN_QR_SCREEN,
                                        (route) => false);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          authenticating
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.redText)),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
