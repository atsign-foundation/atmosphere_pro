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
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: borderRadius),
      ),
      baseColor: ColorConstants.dividerGrey,
      highlightColor: ColorConstants.background,
    );
  }
}
