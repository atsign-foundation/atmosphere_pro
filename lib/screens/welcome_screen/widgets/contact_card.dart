import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactCard extends StatefulWidget {
  final AtContact contact;
  final double avatarSize, borderRadius;
  final Function()? onTap;
  final bool isSelected, isTrusted;
  final Function? deleteFunc;

  const ContactCard({
    Key? key,
    required this.contact,
    this.avatarSize = 40,
    this.borderRadius = 18,
    this.onTap,
    this.isSelected = false,
    this.isTrusted = false,
    this.deleteFunc,
  }) : super(key: key);

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  String contactName = 'UG';
  Uint8List? image;

  @override
  void initState() {
    getNameAndImage();
    super.initState();
  }

  void getNameAndImage() {
    try {
      contactName = widget.contact.atSign ?? 'UG';

      if (contactName[0] == '@') {
        contactName = contactName.substring(1);
      }

      if (widget.contact.tags != null &&
          widget.contact.tags?['image'] != null) {
        List<int> intList = widget.contact.tags!['image'].cast<int>();
        image = Uint8List.fromList(intList);
      }
    } catch (e) {
      contactName = 'UG';
      print('Error in getting image $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20.toWidth,
          12.toHeight,
          14.toWidth,
          12.toHeight,
        ),
        margin: EdgeInsets.only(bottom: 10.toHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorConstants.textBoxBg,
          ),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: widget.avatarSize,
              width: widget.avatarSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius,
                ),
              ),
              child: image != null
                  ? CustomCircleAvatar(
                      byteImage: image,
                      nonAsset: true,
                    )
                  : ContactInitial(
                      borderRadius: widget.borderRadius,
                      size: widget.avatarSize,
                      initials: contactName,
                    ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.contact.atSign ?? '',
                    style: TextStyle(
                      fontSize: 14.toFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.contact.tags?['name'] ??
                        widget.contact.atSign!.substring(1),
                    style: TextStyle(
                      fontSize: 11.toFont,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            widget.isTrusted
                ? SvgPicture.asset(
                    AppVectors.icTrustActivated,
                  )
                : const SizedBox(),
            InkWell(
              onTap: () {
                widget.deleteFunc?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SvgPicture.asset(
                  AppVectors.icClose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
