///This is a custom app bar [showTitle] enables to display the title in the middle
///[showBackButton] toggles the automatically implies leading functionality
///if [false] it shows a [Close] String instead of backbutton
///[showLeadingButton] toggles the drawer menu button
///[title] is a [String] to display the title of the appbar

import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showTitle;
  final bool showBackButton;
  final bool showLeadingicon;

  const CustomAppBar(
      {this.title,
      this.showTitle = false,
      this.showBackButton = false,
      this.showLeadingicon = false});
  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          Flexible(
            flex: 2,
            child: Container(
              height: 40.toHeight,
              width: 60.toWidth,
              child: (!showLeadingicon)
                  ? (showBackButton)
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: ColorConstants.fontPrimary,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                      : Center(
                          child: GestureDetector(
                            child: Text(
                              'Close',
                              style: CustomTextStyles.blueRegular18,
                            ),
                          ),
                        )
                  : Image.asset(ImageConstants.logoIcon),
            ),
          ),
          Expanded(
            flex: 9,
            child: (showTitle)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          title,
                          style: CustomTextStyles.primaryBold18,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
          Expanded(
            flex: 2,
            child: (showTitle)
                ? Container(
                    height: 22.toHeight,
                    width: 22.toWidth,
                  )
                : GestureDetector(
                    onTap: () {
                      print('ON DRWAER TAP');
                    },
                    child: Image.asset(
                      ImageConstants.drawerIcon,
                    ),
                  ),
          )
        ],
      ),
      automaticallyImplyLeading: false,
      backgroundColor: ColorConstants.appBarColor,
    );
  }
}
