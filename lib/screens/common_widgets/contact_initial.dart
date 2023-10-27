import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double? size, maxSize, minSize, borderRadius;
  final String? initials;
  final Color? background;

  const ContactInitial({
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
    late int index;
    if (initials!.length < 3) {
      index = initials!.length;
    } else {
      index = 2;
    }

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

class ContactInitialV2 extends StatelessWidget {
  final double? size, maxSize, minSize;
  final String? initials;
  final int? index;
  final Color? background;

  const ContactInitialV2({
    Key? key,
    this.size = 40,
    required this.initials,
    this.index,
    this.background,
    this.maxSize,
    this.minSize,
  }) : super(key: key);

  int get startIndex => (index == 1) ? 0 : 1;

  int get endIndex => (initials!.length < 3) ? initials!.length : 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size!.toFont,
      width: size!.toFont,
      decoration: BoxDecoration(
        color: background ?? ContactInitialsColors.getColor(initials!),
        borderRadius: BorderRadius.circular((size!.toFont * 0.2)),
        boxShadow: const [
          BoxShadow(
            color: ColorConstants.light_grey,
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials!.substring(startIndex, endIndex).toUpperCase(),
          style: CustomTextStyles.whiteBold(size: (size! ~/ 3)),
        ),
      ),
    );
  }
}
