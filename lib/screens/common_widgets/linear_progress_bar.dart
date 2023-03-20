import 'package:flutter/material.dart';

/// Instantly animating progress bar.
/// Requires [duration] to set filling duration timer
/// [color] or [gradient] to fill the progress bar. Only one parameter is allowed.
/// Optional [backgroundColor], defaults to transparent
/// Optional [width] defaults to 200.0
/// Optional [height] defaults to 10.0
/// Optional [curve] defaults to [Curves.linear]

const int _kIndeterminateLinearDuration = 1800;

class ProgressBarAnimation extends StatefulWidget {
  const ProgressBarAnimation({
    Key? key,
    this.width = double.infinity,
    this.height = 10.0,
    this.color,
    this.gradient,
    this.backgroundColor = Colors.transparent,
    this.curve = Curves.linear,
    this.value,
  }) : super(key: key);

  final double? value;

  ///progress bar width
  final double width;

  ///progress bar height
  final double height;

  ///progress bar color
  final Color? color;

  ///progress bar gradient
  final Gradient? gradient;

  ///progress bar backgroundColor
  final Color backgroundColor;

  ///progress bar animation curve
  final Curve curve;

  @override
  State<ProgressBarAnimation> createState() => _ProgressBarAnimationState();
}

class _ProgressBarAnimationState extends State<ProgressBarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          foregroundPainter: ProgressPainter(
            value: widget.value,
            color: widget.color,
            gradient: widget.gradient,
            animationValue: _controller.value,
          ),
          painter: BackgroundPainter(
            backgroundColor: widget.backgroundColor,
          ),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  const BackgroundPainter({required this.backgroundColor});

  ///progress bar backgroundColor
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = backgroundColor;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Offset.zero & size, Radius.circular(size.height / 2)),
        paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => false;
}

class ProgressPainter extends CustomPainter {
  const ProgressPainter({
    this.value,
    this.gradient,
    this.color,
    required this.animationValue,
  });

  ///current progress bar value
  final double? value;

  ///progress bar gradient infill
  final Gradient? gradient;

  ///progress bar gradient color
  final Color? color;

  final double animationValue;

  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (gradient != null) {
      paint.shader = gradient?.createShader(Offset.zero & size);
    }

    if (color != null) {
      paint.color = color!;
    }

    void drawBar(double x, double width) {
      if (width <= 0.0) {
        return;
      }

      if (value != null) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Offset(x, 0.0) & Size(width, size.height),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          paint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Offset(x, 0.0) & Size(width, size.height),
            Radius.circular(size.height / 2),
          ),
          paint,
        );
      }
    }

    if (value != null) {
      drawBar(0.0, value!.clamp(0.0, 1.0) * size.width);
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 =
          size.width * line1Head.transform(animationValue) - x1;

      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 =
          size.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return value != oldDelegate.value ||
        animationValue != oldDelegate.animationValue;
  }
}
