/// This is a custom Circle Avatar with a border of secondary color
/// [size] is set to [50] as default

import 'dart:typed_data';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? image;
  final double size;
  final bool nonAsset;
  final Uint8List? byteImage;

  const CustomCircleAvatar(
      {Key? key,
      this.image,
      this.size = 50,
      this.nonAsset = false,
      this.byteImage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.toWidth),
      ),
      child: CircleAvatar(
        radius: (size - 5).toFont,
        backgroundColor: Colors.transparent,
        backgroundImage: nonAsset
            ? Image.memory(
                byteImage!,
                errorBuilder: (BuildContext _context, _, __) {
                  return Container(
                    child: Icon(
                      Icons.image,
                      size: 30.toFont,
                    ),
                  );
                },
              ).image
            : AssetImage(image!),
      ),
    );
  }
}

class CustomCircleAvatarV2 extends StatelessWidget {
  final String? image;
  final double size;
  final bool nonAsset;
  final Uint8List? byteImage;

  const CustomCircleAvatarV2({
    Key? key,
    this.image,
    this.size = 50,
    this.nonAsset = false,
    this.byteImage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: size.toFont,
        width: size.toFont,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.toWidth * 0.2),
          image: DecorationImage(
            image: nonAsset
                ? Image.memory(
                    byteImage!,
                    errorBuilder: (BuildContext _context, _, __) {
                      return Container(
                        child: Icon(
                          Icons.image,
                          size: size.toFont,
                        ),
                      );
                    },
                  ).image
                : AssetImage(image!),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.light_grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ));
  }
}
