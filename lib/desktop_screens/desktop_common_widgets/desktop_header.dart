import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopHeader extends StatelessWidget {
  final String title;
  final ValueChanged<bool> onFilter;
  List<Widget> actions;
  List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  bool showBackIcon;
  DesktopHeader(
      {this.title, this.showBackIcon = true, this.onFilter, this.actions});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 20),
          showBackIcon
              ? InkWell(
                  onTap: () {
                    DesktopSetupRoutes.nested_pop();
                  },
                  child: Icon(Icons.arrow_back),
                )
              : SizedBox(),
          SizedBox(width: 15),
          title != null
              ? Text(
                  title,
                  style: CustomTextStyles.primaryRegular20,
                )
              : SizedBox(),
          SizedBox(width: 15),
          Expanded(child: SizedBox()),
          actions != null
              ? Row(
                  children: actions,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
