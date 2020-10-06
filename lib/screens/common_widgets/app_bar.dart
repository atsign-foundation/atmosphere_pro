///This is a custom app bar [showTitle] enables to display the title in the center
///[showBackButton] toggles the automatically implies leading functionality
///if [false] it shows a [Close] String instead of backbutton
///[showLeadingButton] toggles the drawer menu button
///[title] is a [String] to display the title of the appbar
///[showAddButton] toggles the visibility of add button and is only used for contacts screen
///therefore it has it's navigation embedded in the widget itself.

import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showTitle;
  final bool showBackButton;
  final bool showLeadingicon;
  final bool showAddButton;
  final double elevation;

  const CustomAppBar({
    this.title,
    this.showTitle = false,
    this.showBackButton = false,
    this.showLeadingicon = false,
    this.showAddButton = false,
    this.elevation = 0,
  });
  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 0,
      centerTitle: true,
      leading: (showLeadingicon)
          ? Image.asset(ImageConstants.logoIcon)
          : (showBackButton)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.fontPrimary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : null,
      title: Row(
        children: [
          Container(
            height: 40.toHeight,
            margin: EdgeInsets.only(top: 5.toHeight),
            child: (!showBackButton && !showLeadingicon)
                ? Center(
                    child: GestureDetector(
                      child: Text(
                        TextStrings().buttonClose,
                        style: CustomTextStyles.blueRegular18,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: (showTitle)
                ? Center(
                    child: Text(
                      title,
                      style: CustomTextStyles.primaryBold18,
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      actions: [
        Container(
          height: 22.toHeight,
          width: 22.toWidth,
          margin: EdgeInsets.only(right: 20),
          child: (showTitle)
              ? (showAddButton)
                  ? IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.ADD_CONTACT_SCREEN);
                      })
                  : Container()
              : GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    height: 22.toHeight,
                    width: 22.toWidth,
                    child: Image.asset(
                      ImageConstants.drawerIcon,
                    ),
                  ),
                ),
        )
      ],
      automaticallyImplyLeading: false,
      backgroundColor: ColorConstants.appBarColor,
    );
  }
}
