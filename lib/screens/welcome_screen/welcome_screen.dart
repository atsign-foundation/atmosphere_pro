import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_screen.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_sceen_home.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_screen_received_files.dart';
import 'package:atsign_atmosphere_pro/services/overlay_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/text_strings.dart';
import '../common_widgets/side_bar.dart';
import '../../view_models/file_transfer_provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BackendService backendService = BackendService.getInstance();
  HistoryProvider? historyProvider;
  bool isExpanded = true;
  int _selectedBottomNavigationIndex = 0;
  late FileTransferProvider _fileTransferProvider;
  // 0-Sending, 1-Success, 2-Error
  List<Widget> transferStatus = [
    SizedBox(),
    Icon(
      Icons.check_circle,
      size: 20.toFont,
      color: ColorConstants.successColor,
    ),
    Icon(
      Icons.cancel,
      size: 20.toFont,
      color: ColorConstants.redText,
    )
  ];
  String? currentAtSign;
  @override
  void initState() {
    _fileTransferProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    setAtSign();

    listenForFlushBarStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      WelcomeScreenProvider().isExpanded = false;
      await initPackages();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  listenForFlushBarStatus() {
    FileTransferProvider().flushBarStatusStream.listen((flushbarStatus) async {
      OverlayService.instance.showOverlay(
        flushbarStatus,
        errorMessage: flushbarStatus == FLUSHBAR_STATUS.FAILED
            ? _fileTransferProvider.error[_fileTransferProvider.SEND_FILES]
            : null,
      );
      });
  }

  setAtSign() async {
    currentAtSign = await backendService.getAtSign();
    setState(() {});
  }

  initPackages() async {
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    GroupService().init(MixedConstants.ROOT_DOMAIN, MixedConstants.ROOT_PORT);
    await GroupService().fetchGroupsAndContacts();
  }

  void _onBottomNavigationSelect(int index) {
    setState(() {
      _selectedBottomNavigationIndex = index;
    });
  }

  static List<Widget> _bottomSheetWidgetOptions = <Widget>[
    WelcomeScreenHome(),
    WelcomeScreenReceivedFiles()
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.transparent,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontSize: 12.toFont,
            fontWeight: FontWeight.normal,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.toFont,
            fontWeight: FontWeight.normal,
          ),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 20.toFont),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.import_export, size: 20.toFont),
              label: 'Received',
            ),
          ],
          currentIndex: _selectedBottomNavigationIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onBottomNavigationSelect,
        ),
        key: _scaffoldKey,
        // backgroundColor: ColorConstants.scaffoldColor,
        // appBar: _selectedBottomNavigationIndex == 0
        //     ? (SizeConfig().isTablet(context)
        //         ? null
        //         : CustomAppBar(
        //             showLeadingicon: true,
        //           ))
        //     : CustomAppBar(
        //         showMenu: true,
        //         showBackButton: false,
        //         showTrailingButton: true,
        //         showTitle: true,
        //         showClosedBtnText: false,
        //         title: 'Received Files'),
        extendBody: true,
        drawerScrimColor: Colors.transparent,
        endDrawer: SideBarWidget(
          isExpanded: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/main_background.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Consumer<InternetConnectivityChecker>(
              builder: (_c, provider, widget) {
            if (provider.isInternetAvailable) {
              return _bottomSheetWidgetOptions[_selectedBottomNavigationIndex];
            } else {
              return ErrorScreen(
                TextStrings.noInternet,
              );
            }
          }),
        ),
      ),
    );
  }
}
