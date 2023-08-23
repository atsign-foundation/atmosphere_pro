import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/circular_icon.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DesktopContactCard extends StatefulWidget {
  final AtContact contact;
  const DesktopContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  State<DesktopContactCard> createState() => _DesktopContactCardState();
}

class _DesktopContactCardState extends State<DesktopContactCard> {
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
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.white),
        color: Colors.white,
      ),
      // height: 70,
      child: Row(
        children: [
          image != null
              ? CustomCircleAvatar(
                  byteImage: image,
                  nonAsset: true,
                )
              : ContactInitial(
                  size: 50,
                  initials: contactName,
                ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            children: [
              CircularIcon(
                icon: Icons.send_rounded,
                iconColor: Color(0xFFEAA743),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: SvgPicture.asset(
                  AppVectors.icTrustActivated,
                ),
              ),
              CircularIcon(
                icon: Icons.keyboard_control,
                iconColor: ColorConstants.gray,
              ),
            ],
          )
        ],
      ),
    );
  }
}
