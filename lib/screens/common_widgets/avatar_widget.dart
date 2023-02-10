import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_contacts_group_flutter/widgets/contact_initial.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatefulWidget {
  final AtContact contact;
  final double? borderRadius;
  final double size;

  const AvatarWidget({
    Key? key,
    this.size = 40,
    this.borderRadius,
    required this.contact,
  }) : super(key: key);

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
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
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: image != null
          ? CustomCircleAvatar(
              byteImage: image,
              nonAsset: true,
            )
          : ContactInitial(
              borderRadius: widget.borderRadius,
              size: widget.size,
              initials: contactName,
            ),
    );
  }
}
