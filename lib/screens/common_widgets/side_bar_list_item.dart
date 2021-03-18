import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class SideBarItem extends StatelessWidget {
  final String image;
  final String title;
  final String routeName;
  final Map<String, dynamic> arguments;
  final bool showIconOnly;

  const SideBarItem(
      {Key key,
      this.image,
      this.title,
      this.routeName,
      this.arguments,
      this.showIconOnly = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   onTap: () {
    //     Navigator.pop(context);
    //     Navigator.pushNamed(context, routeName,
    //         arguments: arguments != null ? arguments : {});
    //   },
    //   leading: Image.asset(
    //     image,
    //     height: 20.toHeight,
    //     color: ColorConstants.fadedText,
    //   ),
    //   title: Text(
    //     title,
    //     softWrap: true,
    //     style: TextStyle(
    //       color: ColorConstants.fadedText,
    //       letterSpacing: 0.1,
    //       fontSize: 14.toFont,
    //     ),
    //   ),
    // );
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName,
            arguments: arguments != null ? arguments : {});
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
            SizedBox(width: 10),
            !showIconOnly
                ? Text(
                    title,
                    softWrap: true,
                    style: TextStyle(
                      color: ColorConstants.fadedText,
                      letterSpacing: 0.1,
                      fontSize: 14.toFont,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
