import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/circular_icon.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class DesktopContactCard extends StatefulWidget {
  final AtContact contact;
  const DesktopContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  State<DesktopContactCard> createState() => _DesktopContactCardState();
}

class _DesktopContactCardState extends State<DesktopContactCard> {
  String contactName = 'UG';
  Uint8List? image;
  late TrustedContactProvider trustedProvider;
  bool isTrusted = false;

  @override
  void initState() {
    trustedProvider = context.read<TrustedContactProvider>();
    getNameAndImage();
    checkTrustedContact();
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

  checkTrustedContact() {
    for (AtContact contact in trustedProvider.trustedContacts) {
      if (contact.atSign == widget.contact.atSign) {
        isTrusted = true;
      }
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
              isTrusted
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(
                        AppVectors.icTrustActivated,
                      ),
                    )
                  : SizedBox(),
              InkWell(
                onTap: () async {
                  Provider.of<FileTransferProvider>(context, listen: false)
                      .selectedContacts = [
                    GroupContactsModel(
                        contact: widget.contact,
                        contactType: ContactsType.CONTACT),
                  ];
                  Provider.of<FileTransferProvider>(context, listen: false)
                      .notify();

                  await DesktopSetupRoutes.nested_pop();
                },
                child: CircularIcon(
                  icon: Icons.send_rounded,
                  iconColor: Color(0xFFEAA743),
                ),
              ),

              // CircularIcon(
              //   icon: Icons.keyboard_control,
              //   iconColor: ColorConstants.gray,
              // ),
            ],
          )
        ],
      ),
    );
  }
}
