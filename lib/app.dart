import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'AtSign Atmosphere App',
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
