import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
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
  final TextStyle? titleStyle;

  const AppBarCustom({
    Key? key,
    this.title,
    this.actionCustom,
    this.marginRightAction,
    this.height,
    this.description,
    this.isContent = false,
    this.suffixIcon,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 16),
            child: SvgPicture.asset(
              AppVectors.appIcon,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title ?? '',
                            textAlign: TextAlign.left,
                            style: titleStyle ??
                                TextStyle(
                                  fontSize: 25.toFont,
                                  fontWeight: FontWeight.w500,
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
                            fontSize: 15.toFont,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 130);
}