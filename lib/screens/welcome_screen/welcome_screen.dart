import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_screen.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/history/transfer_history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files_screen.dart';
import 'package:atsign_atmosphere_pro/screens/settings/settings_screen.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/bottom_navigation_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_sceen_home.dart';
import 'package:atsign_atmosphere_pro/services/overlay_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../utils/text_strings.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BackendService backendService = BackendService.getInstance();
  HistoryProvider? historyProvider;
  bool isExpanded = true;

  // int _selectedBottomNavigationIndex = 0;
  late FileTransferProvider _fileTransferProvider;
  late WelcomeScreenProvider welcomeScreenProvider;

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
    welcomeScreenProvider = context.read<WelcomeScreenProvider>();
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
    FileTransferProvider().flushBarStatusStream.listen(
      (flushbarStatus) async {
        final isSuccess = await OverlayService.instance.showOverlay(
          flushbarStatus,
          errorMessage: flushbarStatus == FLUSHBAR_STATUS.FAILED
              ? _fileTransferProvider.error[_fileTransferProvider.SEND_FILES]
              : null,
        );

        if (isSuccess == true) {
          _fileTransferProvider.resetData();
          welcomeScreenProvider.resetData();
        }
      },
    );
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

  static List<Widget> _bottomSheetWidgetOptions = <Widget>[
    WelcomeScreenHome(),
    ContactScreen(),
    MyFilesScreen(),
    TransferHistoryScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.scaffoldColor,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: customBottomNavigationBar(),
          key: _scaffoldKey,
          backgroundColor: ColorConstants.scaffoldColor,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            width: 79,
            height: 79,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xffF05E3F), Color(0xffe9a642)],
                  stops: [0.1, 0.8],
                )),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              onPressed: () {
                welcomeScreenProvider.changeBottomNavigationIndex(0);
              },
              child: context
                          .watch<WelcomeScreenProvider>()
                          .selectedBottomNavigationIndex ==
                      0
                  ? SvgPicture.asset(
                      "assets/svg/plus.svg",
                    )
                  : SvgPicture.asset(
                      "assets/svg/home.svg",
                    ),
            ),
          ),
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
          //         title: 'Received Files',
          //       ),
          extendBody: true,
          drawerScrimColor: Colors.transparent,
          endDrawer: SideBarWidget(
            isExpanded: true,
          ),
          body: Consumer<InternetConnectivityChecker>(
              builder: (_c, provider, widget) {
            if (provider.isInternetAvailable) {
              return _bottomSheetWidgetOptions[context
                  .watch<WelcomeScreenProvider>()
                  .selectedBottomNavigationIndex];
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

  Widget customBottomNavigationBar() {
    return Consumer<WelcomeScreenProvider>(builder: (context, provider, _) {
      return Selector<WelcomeScreenProvider, int>(
          selector: (context, provider) =>
              provider.selectedBottomNavigationIndex,
          builder: (context, selectedBottomNavigationIndex, _) {
            return Container(
              height: 70.toHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, spreadRadius: 0, blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BottomNavigationWidget(
                        icon: "assets/svg/contacts.svg",
                        title: "Contacts",
                        index: 1,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                      BottomNavigationWidget(
                        icon: "assets/svg/my_files.svg",
                        title: "My Files",
                        index: 2,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      BottomNavigationWidget(
                        icon: "assets/svg/history.svg",
                        title: "History",
                        index: 3,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                      BottomNavigationWidget(
                        icon: "assets/svg/settings.svg",
                        title: "Settings",
                        index: 4,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }
}

class PainterOne extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    var paint1 = Paint()
      ..color = Color(0xffEAA743)
      ..style = PaintingStyle.fill;

    RRect halfRect = RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: h),
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50));
    canvas.drawRRect(halfRect, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
