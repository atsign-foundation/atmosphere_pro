import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoadingWidget extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;
  final double width;
  final double height;

  const SkeletonLoadingWidget({
    this.borderRadius = const BorderRadius.all(Radius.zero),
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorConstants.dividerGrey,
      highlightColor: ColorConstants.background,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: ColorConstants.dividerGrey,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
