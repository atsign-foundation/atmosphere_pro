import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final Widget child;
  final double radius;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.radius = 8,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorConstants.orangeColor,
            ColorConstants.yellow,
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: ColorConstants.light_grey,
            spreadRadius: 0,
            blurRadius: 2,
            offset: Offset(1, 2), // changes position of shadow
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
    );
  }
}
