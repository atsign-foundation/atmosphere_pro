import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class DesktopCustomPersonVerticalTile extends StatelessWidget {
  final String? title, subTitle;
  final bool showCancelIcon, showImage;
  final Uint8List? image;
  final double size;

  DesktopCustomPersonVerticalTile(
      {required this.title,
      required this.subTitle,
      this.showCancelIcon = true,
      this.showImage = false,
      this.image,
      this.size = 50});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: [
            showImage
                ? CircleAvatar(
                    radius: (size / 2).toFont,
                    backgroundColor: Colors.transparent,
                    backgroundImage: Image.memory(
                      image!,
                      errorBuilder: (BuildContext _context, _, __) {
                        return Container(
                          child: Icon(
                            Icons.image,
                            size: 30.toFont,
                          ),
                        );
                      },
                    ).image,
                  )
                : ContactInitial(
                    initials: title ?? ' ',
                    size: 50,
                    maxSize: (80.0 - 30.0),
                    minSize: 50,
                  ),
            showCancelIcon
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.cancel),
                  )
                : SizedBox(),
          ],
        ),
        SizedBox(width: 10.toHeight),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title!,
                style: CustomTextStyles.desktopPrimaryRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5.toHeight),
              subTitle != null
                  ? Text(
                      subTitle!,
                      style: CustomTextStyles.secondaryRegular12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : SizedBox(),
            ],
          ),
        )
      ],
    );
  }
}
