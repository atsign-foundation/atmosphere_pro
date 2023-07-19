import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopContactTile extends StatelessWidget {
  const DesktopContactTile({
    Key? key,
    required this.title,
    required this.subTitle,
    this.showImage = false,
    this.image,
  }) : super(key: key);

  final String? title, subTitle;
  final bool showImage;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          showImage
              ? Container(
                  height: 60,
                  width: 60,
                  child: Image.memory(
                    image!,
                    fit: BoxFit.fill,
                    errorBuilder: (BuildContext _context, _, __) {
                      return Container(
                        child: Icon(
                          Icons.image,
                          size: 30.toFont,
                        ),
                      );
                    },
                  ),
                )
              : ContactInitial(
                  initials: title ?? ' ',
                  size: 60,
                  maxSize: (80.0 - 20.0),
                  minSize: 60,
                  borderRadius: 0,
                ),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 10.toHeight),
              Text(
                title!,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subTitle != null
                  ? Text(
                      subTitle!,
                      style: CustomTextStyles.desktopPrimaryRegular12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : SizedBox(),
              SizedBox(width: 10.toHeight),
            ],
          ),
          Spacer(),
          Icon(
            Icons.send_outlined,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {},
            child: Icon(
              Icons.verified_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Icon(
            Icons.more_horiz_outlined,
            color: ColorConstants.MILD_GREY,
            size: 24,
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}
