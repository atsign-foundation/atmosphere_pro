import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_switch_atsign.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_welcome_screen/desktop_welcome_screen.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key key}) : super(key: key);

  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  BackendService backendService = BackendService.getInstance();
  var atClientPrefernce;
  bool authenticating = false;

  @override
  void initState() {
    _checkToOnboardinHome();
    super.initState();
  }

  void _checkToOnboardinHome() async {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    String currentatSign = await backendService.getAtSign();
    print('currentatSign $currentatSign');
    await backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value)
        .catchError((e) => print(e));

    await CustomOnboarding.onboard(
        atSign: currentatSign,
        atClientPrefernce: atClientPrefernce,
        showLoader: showLoaderInHome);
  }

  void showLoaderInHome(bool loaderState) {
    setState(() {
      authenticating = loaderState;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 0.1,
                  ),
                ),
              ),
              child: AppBar(
                leading: Image.asset(
                  ImageConstants.logoIcon,
                  height: 50.toHeight,
                  width: 50.toHeight,
                ),
                actions: [
                  Icon(Icons.notifications, size: 30),
                  SizedBox(width: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('alala'),
      ),
    );
  }
}
