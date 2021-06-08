import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DdesktopHeader extends StatelessWidget {
  final String title;
  bool showBackIcon;
  DdesktopHeader({this.title, this.showBackIcon = true});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 20),
          showBackIcon ? Icon(Icons.arrow_back) : SizedBox(),
          SizedBox(width: 15),
          title != null
              ? Text(
                  title,
                  style: CustomTextStyles.primaryRegularBold18,
                )
              : SizedBox(),
          SizedBox(width: 15),
          Expanded(child: SizedBox()),
          CustomInputField(
            backgroundColor: Colors.white,
            hintText: 'Search...',
            icon: Icons.search,
            iconColor: ColorConstants.greyText,
          ),
          SizedBox(width: 15),
          Icon(Icons.filter_list_sharp),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
