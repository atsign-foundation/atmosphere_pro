import 'dart:io';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' show basename;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  late BackendService _backendService;

  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;

  bool authenticating = false;

  List<SharedMediaFile>? _sharedFiles;
  late FileTransferProvider filePickerProvider;
  String? activeAtSign;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<InternetConnectivityChecker>(
              NavService.navKey.currentContext!,
              listen: false)
          .checkConnectivity();
    });

    storeApplicationDocumentsDirectory();
    filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    _backendService = BackendService.getInstance();
    _checkToOnboard();

    acceptFiles();
    _checkForPermissionStatus();
    BackendService.getInstance()
        .isAuthuneticatingStream
        .listen((isAuthenticating) {
      if (mounted) {
        setState(() {
          authenticating = isAuthenticating;
        });
      }
    });
  }

  storeApplicationDocumentsDirectory() async {
    var _dir;
    if (Platform.isIOS || Platform.isWindows) {
      _dir = await getApplicationDocumentsDirectory();
    } else {
      _dir = await getExternalStorageDirectory();
    }
    MixedConstants.ApplicationDocumentsDirectory = _dir.path;
  }

  var atClientPrefernce;
  void _checkToOnboard() async {
    setState(() {
      authenticating = true;
    });
    String? currentatSign = await _backendService.getAtSign();
    await _backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) => print(e));

    if (currentatSign == null || currentatSign == '') {
      setState(() {
        authenticating = false;
      });
    } else {
      await Provider.of<WelcomeScreenProvider>(context, listen: false)
          .onboardingLoad(atSign: currentatSign);
    }
  }

  void acceptFiles() async {
    await ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> value) async {
      _sharedFiles = value;

      if (value.isNotEmpty) {
        value.forEach((element) async {
          File file = File(element.path);
          var length = await file.length();
          FileTransferProvider.appClosedSharedFiles.add(
            PlatformFile(
                name: basename(file.path),
                path: file.path,
                size: length.round(),
                bytes: await file.readAsBytes()),
          );
          await filePickerProvider.setFiles();
        });

        print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
        // check to see if atsign is paired
        var atsign = await _backendService.currentAtsign;
        if (atsign != null) {
          BuildContext c = NavService.navKey.currentContext!;
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
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        _sharedFiles!.forEach((element) async {
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
            (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
      }
    }, onError: (error) {
      print('ERROR IS HERE=========>$error');
    });
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

  var cardHeight = 300.0;
  var paddingSmall = 80.0;
  var paddingLarge = 100.0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // var cardHeight = SizeConfig().screenHeight / 0.3;
    // var paddingSmall = SizeConfig().screenHeight / 0.1;
    // var paddingLarge = SizeConfig().screenHeight / 0.2;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  ImageConstants.logoIcon,
                  height: 60.toHeight,
                  width: 60.toHeight,
                ),
                Text(
                  "atmospherePro",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaNeu',
                  ),
                ),
              ],
            ),
            Flexible(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: paddingSmall * 4.toHeight),
                      child: Container(
                        width: SizeConfig().screenWidth,
                        child: Image.asset(
                          ImageConstants.graphic4,
                          height: cardHeight.toHeight,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: paddingSmall * 3.toHeight),
                      child: Container(
                        width: SizeConfig().screenWidth,
                        child: Image.asset(
                          ImageConstants.graphic3,
                          height: cardHeight.toHeight,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: paddingSmall.toHeight),
                      child: Container(
                        width: SizeConfig().screenWidth,
                        child: Image.asset(
                          ImageConstants.graphic1,
                          height: cardHeight.toHeight,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: SizeConfig().screenWidth,
                      height: cardHeight.toHeight,
                      child: Image.asset(
                        ImageConstants.graphic2,
                        height: cardHeight.toHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: SizeConfig().screenWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25, bottom: 5),
                            child: Text(
                              "Your app, your data",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.toFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25, bottom: 30),
                            child: Text(
                              "Free, Encrypted File Transfer.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.toFont,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Center(
                              child: InkWell(
                                onTap: authenticating
                                    ? () {}
                                    : () async {
                                        await _backendService.checkToOnboard();
                                      },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Upload atSign",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18.toFont,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
