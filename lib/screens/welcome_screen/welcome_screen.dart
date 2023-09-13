import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_screen.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/linear_progress_bar.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/contact_screen.dart';
import 'package:atsign_atmosphere_pro/screens/history/transfer_history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/my_files_screen.dart';
import 'package:atsign_atmosphere_pro/screens/settings/settings_screen.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/bottom_navigation_widget.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/welcome_sceen_home.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/text_strings.dart';

class WelcomeScreen extends StatefulWidget {
  final int? indexBottomBarSelected;

  const WelcomeScreen({
    Key? key,
    this.indexBottomBarSelected,
  }) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BackendService backendService = BackendService.getInstance();
  HistoryProvider? historyProvider;
  bool isExpanded = true;

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
    welcomeScreenProvider = context.read<WelcomeScreenProvider>();
    setAtSign();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      WelcomeScreenProvider().isExpanded = false;
      await initPackages();
    });

    if (widget.indexBottomBarSelected != null) {
      welcomeScreenProvider
          .changeBottomNavigationIndex(widget.indexBottomBarSelected!);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    return Scaffold(
      bottomNavigationBar: customBottomNavigationBar(),
      key: _scaffoldKey,
      backgroundColor: ColorConstants.background,
      // extendBody: true,
      // drawerScrimColor: Colors.transparent,
      // endDrawer: SideBarWidget(
      //   isExpanded: true,
      // ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Consumer<WelcomeScreenProvider>(
              builder: (_c, welcomeProvider, _) {
                return !welcomeProvider.isShowOverlay
                    ? SafeArea(
                  bottom: false,
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    child: StreamBuilder<FLUSHBAR_STATUS>(
                      stream: FileTransferProvider().flushBarStatusStream,
                      builder: (context, snapshot) {
                        final flushbarStatus =
                            snapshot.data ?? FLUSHBAR_STATUS.SENDING;

                        if (flushbarStatus == FLUSHBAR_STATUS.DONE) {
                          Future.delayed(
                            const Duration(seconds: 3),
                                () {
                              welcomeScreenProvider.changeOverlayStatus(true);
                            },
                          );
                          return Material(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: ColorConstants.successGreen,
                              child: Center(
                                child: Text(
                                  'Success!🎉 ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (flushbarStatus == FLUSHBAR_STATUS.FAILED) {
                          Future.delayed(
                            const Duration(seconds: 3),
                                () {
                              welcomeScreenProvider.changeOverlayStatus(true);
                            },
                          );
                          return Material(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: ColorConstants.redAlert,
                              child: Center(
                                child: Text(
                                  'Something went wrong! ⚠️',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Consumer<FileProgressProvider>(
                            builder: (_c, provider, _) {
                              var percent = (provider.sentFileTransferProgress
                                  ?.percent ??
                                  30) /
                                  100;
                              return ProgressBarAnimation(
                                value: percent,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF05E3F),
                                    Color(0xFFEAA743),
                                  ],
                                ),
                                // backgroundColor: Colors.red,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                )
                    : SizedBox();
              },
            ),
            Expanded(
              child: Consumer<InternetConnectivityChecker>(
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customBottomNavigationBar() {
    return Consumer<WelcomeScreenProvider>(
      builder: (context, provider, _) {
        return Selector<WelcomeScreenProvider, int>(
          selector: (context, provider) =>
              provider.selectedBottomNavigationIndex,
          builder: (context, selectedBottomNavigationIndex, _) {
            return Container(
              height: 74,
              margin: EdgeInsets.fromLTRB(
                16.toWidth,
                0,
                16.toWidth,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(76),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: BottomNavigationWidget(
                        iconActivate: ImageConstants.icUserActivate,
                        iconInactivate: ImageConstants.icUserInactivate,
                        title: "Contacts",
                        index: 1,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ),
                    Expanded(
                      child: BottomNavigationWidget(
                        iconActivate: ImageConstants.icFileActivate,
                        iconInactivate: ImageConstants.icFileInactivate,
                        title: "Files",
                        index: 2,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ),
                    Expanded(
                      child: BottomNavigationWidget(
                        iconActivate: ImageConstants.icSendActivate,
                        iconInactivate: ImageConstants.icSendInactivate,
                        index: 0,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ),
                    Expanded(
                      child: BottomNavigationWidget(
                        iconActivate: ImageConstants.icHistoryActivate,
                        iconInactivate: ImageConstants.icHistoryInactivate,
                        title: "History",
                        index: 3,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ),
                    Expanded(
                      child: BottomNavigationWidget(
                        iconActivate: ImageConstants.icSettingActivate,
                        iconInactivate: ImageConstants.icSettingInactivate,
                        title: "Settings",
                        index: 4,
                        indexSelected: selectedBottomNavigationIndex,
                        onTap: (index) {
                          welcomeScreenProvider
                              .changeBottomNavigationIndex(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
