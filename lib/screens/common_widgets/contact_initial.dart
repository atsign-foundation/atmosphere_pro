import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double? size, maxSize, minSize, borderRadius;
  final String? initials;
  final Color? background;

  ContactInitial({
    Key? key,
    this.size = 40,
    required this.initials,
    this.background,
    this.maxSize,
    this.minSize,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final index = (initials!.length < 3) ? initials!.length : 2;

    return Container(
      height: size!.toFont,
      width: size!.toFont,
      decoration: BoxDecoration(
        color: background ?? ContactInitialsColors.getColor(initials!),
        // borderRadius: BorderRadius.circular(size.toWidth),
        // color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular((borderRadius ?? size!.toFont)),
      ),
      child: Center(
        child: Text(
          initials!.substring(0, index).toUpperCase(),
          style: CustomTextStyles.whiteBold(size: (size! ~/ 3)),
        ),
      ),
    );
  }
}
