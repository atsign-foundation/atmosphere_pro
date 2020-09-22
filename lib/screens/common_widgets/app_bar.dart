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
      // titleSpacing: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (!showLeadingicon)
              ? (showBackButton)
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: ColorConstants.fontPrimary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                  : Container(
                      padding: EdgeInsets.only(right: 16.toWidth),
                      child: GestureDetector(
                        child: Text(
                          'Close',
                          style: CustomTextStyles.blueRegular18,
                        ),
                      ),
                    )
              : Container(
                  height: 40,
                  width: 40,
                  child: Image.asset(ImageConstants.logoIcon),
                ),
          (showTitle)
              ? Container(
                  padding: EdgeInsets.only(
                      left: (showBackButton) ? 100.toWidth : 80.toWidth),
                  child: Text(
                    title,
                    style: CustomTextStyles.primaryBold18,
                  ),
                )
              : Container(),
        ],
      ),
      automaticallyImplyLeading: false,
      backgroundColor: ColorConstants.appBarColor,
      actions: [
        (showTitle)
            ? Container()
            : Container(
                height: 22.toHeight,
                width: 22.toWidth,
                margin: EdgeInsets.only(right: 27.toWidth),
                child: GestureDetector(
                  onTap: () {
                    print('ON DRWAER TAP');
                  },
                  child: Image.asset(
                    ImageConstants.drawerIcon,
                  ),
                ),
              )
      ],
    );
  }
}
