import 'dart:typed_data';
import 'package:at_contacts_group_flutter/widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class DesktopCustomPersonVerticalTile extends StatefulWidget {
  final String? imageLocation, title, subTitle, atSign;
  final bool isTopRight, isAssetImage;
  final IconData? icon;
  final Function? onCrossPressed;
  final Uint8List? imageIntList;

  DesktopCustomPersonVerticalTile(
      {this.imageLocation,
      this.title,
      this.subTitle,
      this.isTopRight = false,
      this.icon,
      this.onCrossPressed,
      this.isAssetImage = true,
      this.imageIntList,
      this.atSign});

  @override
  _DesktopCustomPersonVerticalTileState createState() =>
      _DesktopCustomPersonVerticalTileState();
}

class _DesktopCustomPersonVerticalTileState
    extends State<DesktopCustomPersonVerticalTile> {
  Uint8List? image;
  String? contactName;

  @override
  void initState() {
    super.initState();
    // getAtsignImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: 60.toHeight,
                width: 60.toHeight,
                child: widget.isAssetImage && widget.imageLocation != null
                    ? CustomCircleAvatar(
                        size: 60.toHeight,
                        image: widget.imageLocation,
                      )
                    : image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.toFont)),
                            child: Image.memory(
                              image!,
                              width: 50.toFont,
                              height: 50.toFont,
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
                            initials: widget.subTitle ?? ' ',
                          ),
              ),
              widget.icon != null
                  ? Positioned(
                      top: widget.isTopRight ? 0 : null,
                      bottom: !widget.isTopRight ? 0 : null,
                      right: 0,
                      child: GestureDetector(
                        onTap: widget.onCrossPressed as void Function()?,
                        child: Container(
                          height: 20.toHeight,
                          width: 20.toHeight,
                          decoration: BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          child: Icon(
                            Icons.close,
                            size: 15.toHeight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(height: 2),
          contactName != null
              ? Text(
                  contactName!,
                  style: CustomTextStyles.greyText16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                )
              : SizedBox(),
          SizedBox(height: 2),
          widget.subTitle != null
              ? SizedBox(
                  width: 120,
                  child: Text(
                    widget.subTitle!,
                    style: CustomTextStyles.greyText15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(),
          SizedBox(height: 2),
        ],
      ),
    );
  }
}
