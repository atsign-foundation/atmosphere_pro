import 'dart:io';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show basename;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService _backendService;

  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;

  bool authenticating = false;

  List<SharedMediaFile> _sharedFiles;
  FileTransferProvider filePickerProvider;
  String activeAtSign;

  @override
  void initState() {
    super.initState();
    filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    _initBackendService();
    acceptFiles();
    _checkForPermissionStatus();
  }

  void acceptFiles() async {
    await ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> value) async {
      _sharedFiles = value;

      if (value.isNotEmpty) {
        value.forEach((element) async {
          File file = File(element.path);
          var length = await file.length();
          await FileTransferProvider.appClosedSharedFiles.add(PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes()));
          await filePickerProvider.setFiles();
        });

        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        // check to see if atsign is paired
        var atsign = await _backendService.currentAtsign;
        if (atsign != null) {
          BuildContext c = NavService.navKey.currentContext;
          await Navigator.pushNamedAndRemoveUntil(
              c, Routes.WELCOME_SCREEN, (route) => false);
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    await ReceiveSharingIntent.getInitialMedia().then(
        (List<SharedMediaFile> value) async {
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
        _sharedFiles.forEach((element) async {
          File file = File(element.path);
          var length = await file.length();
          PlatformFile fileToBeAdded = PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes());
          FileTransferProvider.appClosedSharedFiles.add(fileToBeAdded);
          filePickerProvider.setFiles();
        });

        print("Shared second:" +
            (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
      }
    }, onError: (error) {
      print('ERROR IS HERE=========>$error');
    });
  }

  String state;

  void _initBackendService() async {
    authenticating = true;
    _backendService = BackendService.getInstance();

    onboardSuccess = await _backendService.onboard();

    if (onboardSuccess != null && onboardSuccess == true) {
      await _backendService.startMonitor();
    }

    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels> $msg');
      _backendService.app_lifecycle_state = msg;
      if (_backendService.monitorConnection != null &&
          _backendService.monitorConnection.isInValid()) {
        _backendService.startMonitor();
      }
      return null;
    });
    authenticating = false;
    setState(() {});
  }

  bool isAuth = false;

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

  onNotificationClick(String payload) async {}

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
                                  letterSpacing: 0.1,
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
                                onPressed: (authenticating)
                                    ? () {}
                                    : () async {
                                        if (onboardSuccess) {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.WELCOME_SCREEN,
                                                  (route) => false);
                                        } else {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.SCAN_QR_SCREEN,
                                                  (route) => false,
                                                  arguments: {
                                                'atClientPreference':
                                                    _backendService
                                                        .atClientPreference,
                                                'atClientServiceInstance':
                                                    _backendService
                                                        .atClientServiceInstance,
                                                'nextScreen': WelcomeScreen()
                                              });
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
