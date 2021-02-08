import 'package:atsign_atmosphere_pro/view_models/blocked_contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_picker_provider.dart';
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
        ChangeNotifierProvider<AddContactProvider>(
            create: (context) => AddContactProvider()),
        ChangeNotifierProvider<FilePickerProvider>(
            create: (context) => FilePickerProvider()),
        ChangeNotifierProvider<ContactProvider>(
            create: (context) => ContactProvider()),
        ChangeNotifierProvider<BlockedContactProvider>(
            create: (context) => BlockedContactProvider()),
        ChangeNotifierProvider<WelcomeScreenProvider>(
            create: (context) => WelcomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => TrustedContactProvider())
      ],
      child: MaterialApp(
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
                brightness: Brightness.light),
            buttonBarTheme: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            )),
        routes: SetupRoutes.routes,
      ),
    );
  }
}
