import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
// import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBarItem extends StatelessWidget {
  final String image;
  final String title;
  final String routeName;
  final Map<String, dynamic> arguments;
  final bool showIconOnly, isDesktop;
  final WelcomeScreenProvider _welcomeScreenProvider = WelcomeScreenProvider();

  SideBarItem(
      {Key key,
      this.image,
      this.title,
      this.routeName,
      this.arguments,
      this.showIconOnly = false,
      this.isDesktop = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isDesktop) {
          if (routeName != null && routeName != '') {
            Navigator.of(context).pop();
            return DesktopSetupRoutes.nested_push(routeName,
                arguments: arguments);
          }
          if (arguments['url'] != null) {
            _launchInBrowser(arguments['url']);
          }
          return null;
        }

        if (_welcomeScreenProvider.isExpanded) {
          Navigator.pop(context);
        }
        Navigator.pushNamed(context, routeName, arguments: arguments ?? {});
      },
      child: Container(
        height: 50,
        child: Row(
          children: [
            Image.asset(
              image,
              height: 22.toHeight,
              color: ColorConstants.fadedText,
            ),
            SizedBox(width: isDesktop ? 20 : 10),
            !showIconOnly
                ? Text(
                    title,
                    softWrap: true,
                    style: TextStyle(
                      color: ColorConstants.fadedText,
                      letterSpacing: 0.1,
                      fontSize: isDesktop ? 18 : 14.toFont,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
