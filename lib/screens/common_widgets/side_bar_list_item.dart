import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
// import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

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
      this.showIconOnly = false, this.isDesktop = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
}
