import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class DesktopTooltip extends StatefulWidget {
  final String content;
  final JustTheController controller;
  final AxisDirection axisDirection;

  const DesktopTooltip({
    required this.content,
    required this.controller,
    this.axisDirection = AxisDirection.right,
  });

  @override
  State<DesktopTooltip> createState() => _DesktopTooltipState();
}

class _DesktopTooltipState extends State<DesktopTooltip> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        return JustTheTooltip(
          controller: widget.controller,
          backgroundColor: ColorConstants.tooltipBackground,
          borderRadius: BorderRadius.circular(5),
          triggerMode: TooltipTriggerMode.tap,
          isModal: true,
          preferredDirection: AxisDirection.down,
          margin: EdgeInsets.zero,
          elevation: 0,
          tailBaseWidth: 0,
          tailLength: 0,
          offset: 32,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            constraints: BoxConstraints(maxWidth: 372),
            child: Text(
              widget.content,
              style: TextStyle(
                color: ColorConstants.redText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value == TooltipStatus.isShowing
                  ? ColorConstants.tooltipBackground
                  : ColorConstants.iconButtonColor,
            ),
            child: SvgPicture.asset(
              AppVectors.icTooltip,
              width: 12,
              height: 16,
              fit: BoxFit.cover,
              color: value == TooltipStatus.isShowing
                  ? ColorConstants.orange
                  : ColorConstants.disableTooltipColor,
            ),
          ),
        );
      },
    );
  }
}
