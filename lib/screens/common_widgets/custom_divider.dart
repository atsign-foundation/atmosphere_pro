// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

/// Divider for list view in Contact and my files screen.
/// Having the initial letter in the start.
class CustomDivider extends StatelessWidget {
  const CustomDivider({
    Key? key,
    required this.initialLetter,
    this.padRight = false,
  }) : super(key: key);

  final String initialLetter;
  final bool padRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          initialLetter,
          style: CustomTextStyles.blackBold(size: 20),
        ),
        SizedBox(width: 20.toWidth),
        Expanded(
          child: Container(
            color: ColorConstants.myFilesBtn,
            height: 1,
          ),
        ),
        if (padRight) SizedBox(width: 16.toWidth)
      ],
    );
  }
}
