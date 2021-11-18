import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_sceen_home.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_screen_received_files.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/size_config.dart';
import '../common_widgets/side_bar.dart';
import '../../view_models/file_transfer_provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Flushbar sendingFlushbar;
  BackendService backendService = BackendService.getInstance();
  HistoryProvider historyProvider;
  bool isExpanded = true;
  int _selectedBottomNavigationIndex = 0;
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
  List<String> transferMessages = [
    'Sending file ...',
    'File sent',
    'Oops! something went wrong'
  ];
  String currentAtSign;
  @override
  void initState() {
    setAtSign();

    listenForFlushBarStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      WelcomeScreenProvider().isExpanded = false;
      await initPackages();
      await Provider.of<HistoryProvider>(NavService.navKey.currentState.context,
              listen: false)
          .getSentHistory();
      await Provider.of<HistoryProvider>(NavService.navKey.currentState.context,
              listen: false)
          .getReceivedHistory();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  listenForFlushBarStatus() {
    FileTransferProvider().flushBarStatusStream.listen((flushbarStatus) async {
      if (sendingFlushbar != null && !sendingFlushbar.isDismissed()) {
        await sendingFlushbar.dismiss();
      }

      if (flushbarStatus == FLUSHBAR_STATUS.SENDING) {
        sendingFlushbar = _showScaffold(
            status: 0, shouldTimeout: false, showLinearProgress: true);
        await sendingFlushbar.show(NavService.navKey.currentContext);
      } else if (flushbarStatus == FLUSHBAR_STATUS.FAILED) {
        sendingFlushbar = _showScaffold(status: 2, shouldTimeout: false);
        await sendingFlushbar.show(NavService.navKey.currentContext);
      } else if (flushbarStatus == FLUSHBAR_STATUS.DONE) {
        sendingFlushbar = _showScaffold(status: 1);
        await sendingFlushbar.show(NavService.navKey.currentContext);
      }
    });
  }

  setAtSign() async {
    currentAtSign = await backendService.getAtSign();
    setState(() {});
  }

  initPackages() async {
    // await GroupService().init(await BackendService.getInstance().getAtSign());
    await initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);

    await GroupService()
        .init(MixedConstants.ROOT_DOMAIN, MixedConstants.ROOT_PORT);
    await GroupService().fetchGroupsAndContacts();
  }

  _showScaffold(
      {int status = 0,
      bool shouldTimeout = true,
      bool showLinearProgress = false}) {
    return Flushbar(
      title: transferMessages[status],
      message: 'hello',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      // reverseAnimationCurve: Curves.decelerate,
      // forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: ColorConstants.scaffoldColor,
      showProgressIndicator: showLinearProgress,
      progressIndicatorController: null,
      boxShadows: [
        BoxShadow(
            color: Colors.black, offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: (shouldTimeout) ? Duration(seconds: 3) : null,
      icon: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImageConstants.imagePlaceholder),
              fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
      ),

      mainButton: FlatButton(
        onPressed: () {
          if (sendingFlushbar != null && !sendingFlushbar.isDismissed()) {
            sendingFlushbar.dismiss();
          }
        },
        child: Text(
          TextStrings().buttonDismiss,
          style:
              TextStyle(color: ColorConstants.fontPrimary, fontSize: 15.toFont),
        ),
      ),
      // showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: transferStatus[status],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 5.toWidth,
            ),
            child: Container(
              width: SizeConfig().screenWidth * 0.5,
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                transferMessages[status],
                style: TextStyle(
                    color: ColorConstants.fadedText, fontSize: 15.toFont),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
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
      color: ColorConstants.scaffoldColor,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 20,
                  height: 20,
                  child: Image.asset(ImageConstants.transferHistoryIcon),
                ),
                label: 'Received',
              ),
            ],
            currentIndex: _selectedBottomNavigationIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onBottomNavigationSelect,
          ),
          key: _scaffoldKey,
          backgroundColor: ColorConstants.scaffoldColor,
          appBar: _selectedBottomNavigationIndex == 0
              ? (SizeConfig().isTablet(context)
                  ? null
                  : CustomAppBar(
                      showLeadingicon: true,
                    ))
              : CustomAppBar(
                  showMenu: true,
                  showBackButton: false,
                  showTrailingButton: true,
                  showTitle: true,
                  showClosedBtnText: false,
                  title: 'Received Files'),
          extendBody: true,
          drawerScrimColor: Colors.transparent,
          endDrawer: SideBarWidget(
            isExpanded: true,
          ),
          body: _bottomSheetWidgetOptions[_selectedBottomNavigationIndex],
        ),
      ),
    );
  }
}
