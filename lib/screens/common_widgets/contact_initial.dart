import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double? size, maxSize, minSize;
  final String? initials;
  final int? index;
  final Color? background;

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
    int? _index = index;
    if (initials!.length < 3) {
      _index = initials!.length;
    } else {
      _index = 3;
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
          initials!.substring((_index == 1) ? 0 : 1, _index).toUpperCase(),
          style: CustomTextStyles.whiteBold(size: (size! ~/ 3)),
        ),
      ),
    );
  }
}
