import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopHeader extends StatelessWidget {
  final String? title;
  final ValueChanged<bool>? onFilter;
  final List<Widget>? actions;
  final List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  final bool showBackIcon, isTitleCentered;

  DesktopHeader({
    this.title,
    this.showBackIcon = true,
    this.onFilter,
    this.actions,
    this.isTitleCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 20.toWidth),
          showBackIcon
              ? InkWell(
                  onTap: () {
                    DesktopSetupRoutes.nested_pop();
                  },
                  child: Icon(Icons.arrow_back),
                )
              : SizedBox(),
          SizedBox(width: 15.toWidth),
          title != null && isTitleCentered
              ? Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.toWidth),
                    child: Center(
                      child: Text(
                        title!,
                        style: CustomTextStyles.primaryRegular20,
                        maxLines: 2,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          title != null && !isTitleCentered
              ? Container(
                  child: Center(
                    child: Text(
                      title!,
                      style: CustomTextStyles.primaryRegular20,
                      maxLines: 2,
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(width: 15.toWidth),
          !isTitleCentered ? Expanded(child: SizedBox()) : SizedBox(),
          actions != null
              ? Row(
                  children: actions!,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
