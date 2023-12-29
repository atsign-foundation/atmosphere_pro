import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactCardWidget extends StatefulWidget {
  final AtContact contact;
  final double avatarSize, borderRadius;
  final Function()? onTap;
  final bool isSelected, isTrusted;
  final Widget? suffixIcon;

  const ContactCardWidget({
    Key? key,
    required this.contact,
    this.avatarSize = 40,
    this.borderRadius = 18,
    this.onTap,
    this.isSelected = false,
    this.isTrusted = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<ContactCardWidget> createState() => _ContactCardWidgetState();
}

class _ContactCardWidgetState extends State<ContactCardWidget> {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 13, 12, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? ColorConstants.orange
                  : ColorConstants.textBoxBg,
            ),
            color: widget.isSelected
                ? ColorConstants.orange.withOpacity(0.2)
                : Colors.white,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.contact.tags?['nickname'] ??
                          widget.contact.atSign!.substring(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              widget.isTrusted
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(
                        AppVectors.icTrustActivated,
                      ),
                    )
                  : widget.suffixIcon ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
