import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? description;
  final Widget? actionCustom;
  final double? marginRightAction;
  final double? height;
  final bool isContent;
  final Widget? suffixIcon;

  const AppBarCustom({
    Key? key,
    this.title,
    this.actionCustom,
    this.marginRightAction,
    this.height,
    this.description,
    this.isContent = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 24),
            child: SvgPicture.asset(
              AppVectors.appIcon,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20.toFont,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  description ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          suffixIcon ?? SizedBox(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 130);
}
