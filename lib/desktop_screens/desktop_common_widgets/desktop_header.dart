import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_input_field.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DdesktopHeader extends StatelessWidget {
  final String title;
  final ValueChanged<bool> onFilter;
  List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  bool showBackIcon;
  DdesktopHeader({this.title, this.showBackIcon = true, this.onFilter});
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
          DesktopCustomInputField(
            backgroundColor: Colors.white,
            hintText: 'Search...',
            icon: Icons.search,
            height: 45,
            iconColor: ColorConstants.greyText,
          ),
          SizedBox(width: 15),
          InkWell(
            onTap: () {
              onFilter(true);
            },
            child: Container(
              child: Icon(Icons.filter_list_sharp),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
