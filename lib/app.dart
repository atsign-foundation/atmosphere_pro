import 'dart:async';
import 'dart:io';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/blocked_contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;
import 'routes/routes.dart';

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  FilePickerProvider filePickerProvider;
  @override
  void initState() {
    super.initState();
    filePickerProvider = FilePickerProvider();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;

        // filePickerProvider.
        if (value.isNotEmpty) {
          // FilePickerProvider.sharedFiles = value;
          value.forEach((element) async {
            var test = File(element.path);
            var length = await test.length() / 1024;
            // var finalLength = int.parse(length.toString());
            print('LENGTH====>${length.round()}');
            // print('length====>${length.toString()}');
            // var l = await int.parse(length.toString());
            // print(l);
            // print('LENGTH====>${int.parse()}');
            filePickerProvider.selectedFiles.add(PlatformFile(
                name: basename(test.path),
                path: test.path,
                size: length.round(),
                bytes: await test.readAsBytes()));
            await filePickerProvider.calculateSize();
          });

          // print('IN APP>DAT====>${filePickerProvider.selectedFiles.length}');
          filePickerProvider.selectedFiles.forEach((element) {
            print(
                'element=====>${element.name}=======>${element.size}=======>${element.path}=======>${element.bytes}');
          });
          BuildContext c = NavService.navKey.currentContext;

          print("Shared:wawawawawawa" +
              (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
// File
          Navigator.pushReplacementNamed(c, Routes.WELCOME_SCREEN);
        }
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        print("Shared:lololollo" +
            (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   if (FilePickerProvider.sharedFiles.isNotEmpty) {
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

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
