import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class GradientOutlineInputBorder extends InputBorder {
  const GradientOutlineInputBorder({
    required this.gradient,
    this.width = 1.0,
    this.gapPadding = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  final double width;

  final BorderRadius borderRadius;

  final Gradient gradient;

  final double gapPadding;

  @override
  InputBorder copyWith({BorderSide? borderSide}) {
    return this;
  }

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        borderRadius
            .resolve(textDirection)
            .toRRect(rect)
            .deflate(borderSide.width),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        double? gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection? textDirection,
      }) {
    final paint = _getPaint(rect);
    final outer = borderRadius.toRRect(rect);
    final center = outer.deflate(borderSide.width / 2.0);
    if (gapStart == null || gapExtent <= 0.0 || gapPercentage == 0.0) {
      canvas.drawRRect(center, paint);
    } else {
      final extent =
      lerpDouble(0.0, gapExtent + gapPadding * 2.0, gapPercentage)!;
      switch (textDirection!) {
        case TextDirection.rtl:
          final path = _gapBorderPath(
            canvas,
            center,
            math.max(0, gapStart + gapPadding - extent),
            extent,
          );
          canvas.drawPath(path, paint);
          break;

        case TextDirection.ltr:
          final path = _gapBorderPath(
            canvas,
            center,
            math.max(0, gapStart - gapPadding),
            extent,
          );
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GradientOutlineInputBorder(
      width: width * t,
      borderRadius: borderRadius * t,
      gradient: gradient,
    );
  }

  Paint _getPaint(Rect rect) {
    return Paint()
      ..strokeWidth = width
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke;
  }

  Path _gapBorderPath(
      Canvas canvas,
      RRect center,
      double start,
      double extent,
      ) {
    // When the corner radii on any side add up to be greater than the
    // given height, each radius has to be scaled to not exceed the
    // size of the width/height of the RRect.
    final scaledRRect = center.scaleRadii();

    final tlCorner = Rect.fromLTWH(
      scaledRRect.left,
      scaledRRect.top,
      scaledRRect.tlRadiusX * 2.0,
      scaledRRect.tlRadiusY * 2.0,
    );
    final trCorner = Rect.fromLTWH(
      scaledRRect.right - scaledRRect.trRadiusX * 2.0,
      scaledRRect.top,
      scaledRRect.trRadiusX * 2.0,
      scaledRRect.trRadiusY * 2.0,
    );
    final brCorner = Rect.fromLTWH(
      scaledRRect.right - scaledRRect.brRadiusX * 2.0,
      scaledRRect.bottom - scaledRRect.brRadiusY * 2.0,
      scaledRRect.brRadiusX * 2.0,
      scaledRRect.brRadiusY * 2.0,
    );
    final blCorner = Rect.fromLTWH(
      scaledRRect.left,
      scaledRRect.bottom - scaledRRect.blRadiusY * 2.0,
      scaledRRect.blRadiusX * 2.0,
      scaledRRect.blRadiusX * 2.0,
    );

    const cornerArcSweep = math.pi / 2.0;
    final tlCornerArcSweep = start < scaledRRect.tlRadiusX
        ? math.asin((start / scaledRRect.tlRadiusX).clamp(-1.0, 1.0))
        : math.pi / 2.0;

    final path = Path()
      ..addArc(tlCorner, math.pi, tlCornerArcSweep)
      ..moveTo(scaledRRect.left + scaledRRect.tlRadiusX, scaledRRect.top);

    if (start > scaledRRect.tlRadiusX) {
      path.lineTo(scaledRRect.left + start, scaledRRect.top);
    }

    const trCornerArcStart = (3 * math.pi) / 2.0;
    const trCornerArcSweep = cornerArcSweep;
    if (start + extent < scaledRRect.width - scaledRRect.trRadiusX) {
      path
        ..relativeMoveTo(extent, 0)
        ..lineTo(scaledRRect.right - scaledRRect.trRadiusX, scaledRRect.top)
        ..addArc(trCorner, trCornerArcStart, trCornerArcSweep);
    } else if (start + extent < scaledRRect.width) {
      final dx = scaledRRect.width - (start + extent);
      final sweep = math.acos(dx / scaledRRect.trRadiusX);
      path.addArc(trCorner, trCornerArcStart + sweep, trCornerArcSweep - sweep);
    }

    return path
      ..moveTo(scaledRRect.right, scaledRRect.top + scaledRRect.trRadiusY)
      ..lineTo(scaledRRect.right, scaledRRect.bottom - scaledRRect.brRadiusY)
      ..addArc(brCorner, 0, cornerArcSweep)
      ..lineTo(scaledRRect.left + scaledRRect.blRadiusX, scaledRRect.bottom)
      ..addArc(blCorner, math.pi / 2.0, cornerArcSweep)
      ..lineTo(scaledRRect.left, scaledRRect.top + scaledRRect.tlRadiusY);
  }
}