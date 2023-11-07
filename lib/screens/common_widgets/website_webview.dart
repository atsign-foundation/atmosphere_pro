import 'dart:io';

import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const WebsiteScreen({Key? key, this.title, this.url}) : super(key: key);

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  late bool loading;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkForNetwork();
    });
  }

  checkForNetwork() {
    var isConnected = Provider.of<InternetConnectivityChecker>(
            NavService.navKey.currentContext!,
            listen: false)
        .isInternetAvailable;

    if (!isConnected) {
      SnackbarService().showSnackbar(
        NavService.navKey.currentContext!,
        TextStrings.noInternetMsg,
        bgColor: ColorConstants.redAlert,
      );
    }
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
          icon: const Icon(
            Icons.arrow_back,
            color: ColorConstants.fontPrimary,
            size: 22,
          ),
        ),
        title: Text(
          widget.title!,
          style: CustomTextStyles.primaryBold18,
        ),
      ),
      body: Stack(children: [
        WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          gestureRecognizers: {
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()..onUpdate = (_) {},
            )
          },
          onPageFinished: (test1) {
            setState(() {
              loading = false;
            });
          },
        ),
        loading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                  ColorConstants.blueText,
                )),
              )
            : const SizedBox()
      ]),
    );
  }
}
