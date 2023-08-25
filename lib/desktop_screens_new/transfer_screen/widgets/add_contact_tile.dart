import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class AddContactTile extends StatelessWidget {
  const AddContactTile({
    Key? key,
    required this.title,
    required this.subTitle,
    this.showImage = false,
    this.image,
    this.isSelected = false,
    this.showDivider = false,
    this.hasBackground = false,
    this.isTrusted = false,
  }) : super(key: key);

  final String? title, subTitle;
  final bool showImage;
  final Uint8List? image;
  final bool isSelected;
  final bool showDivider;
  final bool hasBackground;
  final bool isTrusted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: hasBackground ? Colors.white : null,
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2.0)
                : null,
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
                      initials: (title?.isEmpty ?? true) ? '@UG' : title,
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
              isTrusted ? Icon(
                Icons.verified_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ) : const SizedBox(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
        showDivider
            ? Divider(
                thickness: 1,
              )
            : SizedBox(),
      ],
    );
  }
}
