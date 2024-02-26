import 'package:flutter/material.dart';

class CustomEllipsisTextWidget extends StatelessWidget {
  const CustomEllipsisTextWidget({
    Key? key,
    required this.text,
    required this.ellipsis,
    this.style = const TextStyle(color: Colors.black),
    this.maxWidth = double.infinity,
    this.minWidth = 0,
    this.maxLines = 2,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final String ellipsis;
  final int maxLines;
  final double maxWidth, minWidth;
  final TextDirection textDirection;
  final TextAlign textAlign;

  Size getTextSize() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign,
    )..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    return textPainter.size;
  }

  double getTextLineHeight() {
    return getTextSize().height;
  }

  @override
  Widget build(BuildContext context) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign,
    )..layout(
        minWidth: minWidth,
        maxWidth: maxWidth,
      );

    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, size) {
          var span = TextSpan(
            text: text,
            style: style,
          );

          var tp = TextPainter(
            maxLines: maxLines,
            textAlign: textAlign,
            textDirection: TextDirection.ltr,
            text: span,
          );

          tp.layout(maxWidth: size.maxWidth);

          var exceeded = tp.didExceedMaxLines;

          return exceeded
              ? SizedBox(
                  height: tp.height,
                  child: CustomPaint(
                    size: Size(
                      textPainter.size.width,
                      getTextLineHeight(),
                    ),
                    painter: EllipsisTextPainter(
                      text: TextSpan(
                        text: text,
                        style: style,
                      ),
                      ellipsis: ellipsis,
                      maxLines: maxLines,
                      textAlign: textAlign,
                    ),
                  ),
                )
              : Text(
                  text,
                  style: style,
                  textAlign: textAlign,
                );
        },
      ),
    );
  }
}

class EllipsisTextPainter extends CustomPainter {
  final TextSpan text;
  final int maxLines;
  final String ellipsis;
  final TextAlign textAlign;

  EllipsisTextPainter({
    required this.text,
    required this.ellipsis,
    required this.maxLines,
    required this.textAlign,
  }) : super();

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter painter = TextPainter(
      text: text,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    )..ellipsis = ellipsis;

    painter.layout(maxWidth: size.width);
    painter.paint(canvas, const Offset(0, 0));
  }
}
