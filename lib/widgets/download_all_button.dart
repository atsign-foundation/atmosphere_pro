import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DownloadAllButton extends StatelessWidget {
  final bool isMobile;
  final bool enable;

  const DownloadAllButton({
    this.enable = true,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
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
            style: isMobile
                ? CustomTextStyles.whiteW60010
                : CustomTextStyles.whiteW60012,
          ),
          SizedBox(width: 8),
          SizedBox(
            height: isMobile ? 28 : 32,
            width: isMobile ? 28 : 32,
            child: Center(
              child: SvgPicture.asset(
                AppVectors.icDownloadOutline,
                height: 16,
                width: isMobile ? 24 : 28,
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }
}
