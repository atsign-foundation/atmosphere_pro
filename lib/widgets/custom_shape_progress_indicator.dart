import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CustomShapeProgressIndicator extends StatefulWidget {
  const CustomShapeProgressIndicator({
    this.progressLineThickness = 2,
    this.progressLineColor,
    this.backgroundColor,
    this.progress = 0,
    this.child,
    this.borderRadius = 10,
    this.height,
    this.width,
    this.infinityLoadingDelay = 3,
    this.backgroundLineThickness,
  });

  /// The progress of indicator
  ///
  /// The progress value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// this progress indicator displays a predetermined animation when the progress is 0
  final double progress;

  /// The thickness of animating progress line
  ///
  /// Default value is 2 pixel
  final double progressLineThickness;

  /// The thickness of background shape line
  ///
  /// if the [backgroundLineThickness] is null,
  /// the [progressLineThickness] will use for background line thickness
  final double? backgroundLineThickness;

  /// The color of animating line
  ///
  /// if the value is null, primary color of app will be used.
  final Color? progressLineColor;

  /// The color of background line
  ///
  /// if the value is null, disabled color of app will be used.
  final Color? backgroundColor;

  /// Border radius of the shape
  ///
  /// default value is 10
  final double borderRadius;

  /// Height and width of the app.
  ///
  /// if the values are null, child widgets size will be adopted
  final double? height, width;

  /// Infinity loading animation delay
  ///
  /// The progress indicator displays a predetermined animation when the [progress] is 0,
  /// animation speed of the predetermined animation
  final int infinityLoadingDelay;

  /// child widget
  final Widget? child;
  @override
  State<CustomShapeProgressIndicator> createState() =>
      _CustomShapeProgressIndicatorState();
}

class _CustomShapeProgressIndicatorState
    extends State<CustomShapeProgressIndicator>
    with SingleTickerProviderStateMixin {
  //
  /// Animation controller for infinity progress animation
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.infinityLoadingDelay),
      vsync: this,
    );

    /// Infinity progress animation only works when the progress is 0
    // if (widget.progress == 0) {
    _controller.repeat();
    // }
  }

  OutLineCustomPainter _backgroundShapePainter(BuildContext context) {
    return OutLineCustomPainter(
      progress: 1,
      borderColor: widget.backgroundColor ?? Theme.of(context).disabledColor,
      radius: widget.borderRadius,
      strokeWidth:
      widget.backgroundLineThickness ?? widget.progressLineThickness,
    );
  }

  OutLineCustomPainter _progressLinePainter(BuildContext context) {
    return OutLineCustomPainter(
        progress: widget.progress,
        borderColor: widget.progressLineColor ?? Theme.of(context).primaryColor,
        strokeWidth: widget.progressLineThickness,
        radius: widget.borderRadius,
        animation: widget.progress == 0 ? _controller : null);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _backgroundShapePainter(context),
      child: CustomPaint(
        painter: _progressLinePainter(context),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class OutLineCustomPainter extends CustomPainter {
  OutLineCustomPainter({
    required this.progress,
    required this.borderColor,
    this.strokeWidth,
    this.animation,
    required this.radius,
  }) : super(repaint: animation);
  double progress; // desirable value for corners side
  Color borderColor;
  double? strokeWidth;
  final Animation<double>? animation;
  double radius;

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;
    double minSide = min(height, width);
    double actualRadius = min(minSide / 2, radius + (radius * 0.15));
    double x = width - actualRadius;
    double y = height - actualRadius;
    Paint paint = Paint()
      ..color =
      progress == 0 && animation == null ? Colors.transparent : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 4.0;

    Path path = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(x, 0)
      ..quadraticBezierTo(x + actualRadius, 0, x + actualRadius, actualRadius)
      ..lineTo(x + actualRadius, y)
      ..quadraticBezierTo(
          x + actualRadius, y + actualRadius, x, y + actualRadius)
      ..lineTo(actualRadius, y + actualRadius)
      ..quadraticBezierTo(0, y + actualRadius, 0, y)
      ..lineTo(0, actualRadius)
      ..quadraticBezierTo(0, 0, actualRadius, 0)
      ..close();

    PathMetric pathMetric = path.computeMetrics().first;

    Path extractPath = pathMetric.extractPath(
      animation?.value != null
          ? (pathMetric.length * (animation?.value ?? 0) -
          100 * (0.5 - ((animation?.value ?? 0) - 0.5).abs()))
          : 0,
      animation?.value != null
          ? pathMetric.length * (animation?.value ?? 0)
          : pathMetric.length * (progress),
      startWithMoveTo: true,
    );
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant OutLineCustomPainter oldDelegate) {
    return true;
  }
}