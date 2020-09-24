import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class AppBarWithCloseButton extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const AppBarWithCloseButton({this.title, this.actions});

  @override
  Size get preferredSize => Size(
        double.infinity,
        AppBar().preferredSize.height,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10.toWidth),
          child: Center(
            child: Text(
              TextStrings().buttonClose,
              style: TextStyle(
                color: ColorConstants.blueText,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title ?? '',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.toFont,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions ?? [],
    );
  }
}
