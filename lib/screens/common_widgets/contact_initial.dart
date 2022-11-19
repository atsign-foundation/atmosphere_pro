import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double? size, maxSize, minSize;
  final String? initials;
  int? index;
  Color? background;

  ContactInitial(
      {Key? key,
      this.size = 40,
      required this.initials,
      this.index,
      this.background,
      this.maxSize,
      this.minSize})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (initials!.length < 3) {
      index = initials!.length;
    } else {
      index = 3;
    }

    return Container(
      height: size!.toFont,
      width: size!.toFont,
      decoration: BoxDecoration(
        color: background ?? ContactInitialsColors.getColor(initials!),
        // borderRadius: BorderRadius.circular(size.toWidth),
        // color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular((size!.toFont)),
      ),
      child: Center(
        child: Text(
          initials!.substring((index == 1) ? 0 : 1, index).toUpperCase(),
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

  ContactInitialV2({
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

  Widget build(BuildContext context) {
    return Container(
      height: size!.toFont,
      width: size!.toFont,
      decoration: BoxDecoration(
        color: background ?? ContactInitialsColors.getColor(initials!),
        borderRadius: BorderRadius.circular((size!.toFont * 0.2)),
        boxShadow: [
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
