import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/widgets/custom_shape_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DownloadAllProgressIndicator extends StatelessWidget {
  final double progress;

  const DownloadAllProgressIndicator({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 108,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Download',
                style: CustomTextStyles.spanishGrayW60010,
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                AppVectors.icDownloadOutline,
                fit: BoxFit.cover,
                color: ColorConstants.spanishGray,
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: 108,
            height: 32,
            child: CustomShapeProgressIndicator(
              progress: progress,
              progressLineColor: ColorConstants.downloadIndicatorColor,
              backgroundColor: Colors.white,
              borderRadius: 29,
            ),
          ),
        ),
      ],
    );
  }
}
