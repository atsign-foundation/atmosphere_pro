import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';

import 'routes/routes.dart';

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        ChangeNotifierProvider(create: (context) => TrustedContactProvider()),
        ChangeNotifierProvider(create: (context) => FileDownloadChecker()),
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
                textScaleFactor:
                    data.textScaleFactor > 1.1 ? 1.1 : data.textScaleFactor),
            child: child,
          );
        },
        title: 'AtSign Atmosphere Pro',
        debugShowCheckedModeBanner: false,
        initialRoute: SetupRoutes.initialRoute,
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
        routes: SetupRoutes.routes,
      ),
    );
  }
}
