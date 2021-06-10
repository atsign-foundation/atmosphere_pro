import 'package:atsign_atmosphere_pro/desktop_screens/desktop_group/desktop_group_detail.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_group/desktop_group_list.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:flutter/material.dart';

class DesktopGroupView extends StatefulWidget {
  @override
  _DesktopGroupViewState createState() => _DesktopGroupViewState();
}

class _DesktopGroupViewState extends State<DesktopGroupView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth,
      child: Row(
        children: [
          Container(
            width: SizeConfig().screenWidth / 2 - 35,
            child: DesktopGroupList(),
          ),
          Container(
            width: SizeConfig().screenWidth / 2 - 35,
            child: DesktopGroupDetail(),
          )
        ],
      ),
    );
  }
}
