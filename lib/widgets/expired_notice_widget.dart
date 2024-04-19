import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class ExpiredNoticeWidget extends StatelessWidget {
  const ExpiredNoticeWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildErrorBadge,
        SizedBox(width: 8),
        Text(
          'Package expires after 6 days',
          style: CustomTextStyles.portlandOrangeW50012,
        )
      ],
    );
  }

  Widget get buildErrorBadge {
    return Container(
      width: 52,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(33),
        color: ColorConstants.moreFilesBackgroundColor,
      ),
      child: Text(
        'Error',
        style: CustomTextStyles.portlandOrangeW60012,
      ),
    );
  }
}
