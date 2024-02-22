import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DownloadAllButton extends StatelessWidget {
  final bool enable;

  const DownloadAllButton({
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color:
            enable ? ColorConstants.portlandOrange : ColorConstants.lightGray,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Download',
            style: CustomTextStyles.whiteW60012,
          ),
          SizedBox(width: 8),
          SvgPicture.asset(
            AppVectors.icDownloadOutline,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
