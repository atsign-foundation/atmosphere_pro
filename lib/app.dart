import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/switch_atsign_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'dart:io';
import 'routes/routes.dart';

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var initialRoute, routes;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      initialRoute = SetupRoutes.initialRoute;
      routes = SetupRoutes.routes;
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      initialRoute = DesktopSetupRoutes.initialRoute;
      routes = DesktopSetupRoutes.routes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HistoryProvider>(
            create: (context) => HistoryProvider()),
        ChangeNotifierProvider<FileTransferProvider>(
            create: (context) => FileTransferProvider()),
        ChangeNotifierProvider<WelcomeScreenProvider>(
            create: (context) => WelcomeScreenProvider()),
        ChangeNotifierProvider<SideBarProvider>(
            create: (context) => SideBarProvider()),
        ChangeNotifierProvider(create: (context) => TrustedContactProvider()),
        ChangeNotifierProvider(create: (context) => NestedRouteProvider()),
        ChangeNotifierProvider(create: (context) => SwitchAtsignProvider()),
        ChangeNotifierProvider(create: (context) => FileDownloadChecker()),
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
                textScaleFactor:
                    data.textScaleFactor > 1.1 ? 1.1 : data.textScaleFactor),
            child: child!,
          );
        },
        title: 'AtSign Atmosphere Pro',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        navigatorKey: NavService.navKey,
        theme: ThemeData(
            fontFamily: 'HelveticaNeu',
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            buttonBarTheme: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            )),
        routes: routes,
      ),
    );
  }
}
