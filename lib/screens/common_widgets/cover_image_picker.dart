import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoverImagePicker extends StatelessWidget {
  final Function() onTap;
  final Uint8List? groupImage;
  final double height;
  final EdgeInsetsGeometry margin;
  final bool showOptions;
  final Function()? onCancel;

  const CoverImagePicker({
    required this.onTap,
    required this.groupImage,
    required this.height,
    this.margin = const EdgeInsets.symmetric(horizontal: 28),
    this.showOptions = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        margin: margin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorConstants.dividerContextMenuColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            groupImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      groupImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Insert Cover Image",
                        style: CustomTextStyles.greyW50014,
                      ),
                      SizedBox(height: 8),
                      Image.asset(
                        ImageConstants.icImage,
                        width: 48,
                        height: 32,
                      ),
                    ],
                  ),
            if (showOptions)
              Positioned(
                top: 12,
                right: 12,
                left: 12,
                child: Row(
                  children: [
                    if (groupImage != null)
                      InkWell(
                        onTap: onCancel,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white54.withOpacity(0.5),
                          ),
                          child: SvgPicture.asset(
                            AppVectors.icCancel,
                            width: 16,
                            height: 16,
                            color: Colors.black,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white54.withOpacity(0.5),
                      ),
                      child: SvgPicture.asset(
                        AppVectors.icEdit,
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
