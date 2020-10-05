import 'dart:io';

import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GetNow extends StatefulWidget {
  @override
  _GetNowState createState() => _GetNowState();
}

class _GetNowState extends State<GetNow> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorConstants.appBarColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: ColorConstants.fontPrimary,
            size: 22,
          ),
        ),
      ),
      body: WebView(
        initialUrl: 'https://staging.atsign.wtf/',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
