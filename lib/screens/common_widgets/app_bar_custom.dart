import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
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
  final List<Widget>? suffixIcon;
  final TextStyle? titleStyle;
  final bool isLoading;

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
    this.isLoading = false,
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
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12, right: 72,),
                    child: SkeletonLoadingWidget(
                      height: 48,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                : Padding(
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
                                        fontSize: 20.toFont,
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
                      ]..addAll(suffixIcon ?? []),
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
