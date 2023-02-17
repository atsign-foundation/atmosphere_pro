import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';

/// This is a custom widget to display the selected contacts
/// in a row with overlapping profile pictures
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/contact_card.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OverlappingContacts extends StatefulWidget {
  final List<GroupContactsModel?> selectedList;
  final ValueChanged<bool>? onchange;

  const OverlappingContacts({
    Key? key,
    required this.selectedList,
    this.onchange,
  }) : super(key: key);

  @override
  _OverlappingContactsState createState() => _OverlappingContactsState();
}

class _OverlappingContactsState extends State<OverlappingContacts> {
  bool isExpanded = false;
  Map _atsignImages = {};
  late TrustedContactProvider trustedProvider;

  @override
  void initState() {
    trustedProvider = context.read<TrustedContactProvider>();
    for (var index = 0; index < widget.selectedList.length; index++) {
      Uint8List? image;
      if (widget.selectedList[index]?.contact?.tags != null &&
          widget.selectedList[index]?.contact?.tags!['image'] != null) {
        image = CommonUtilityFunctions()
            .getContactImage(widget.selectedList[index]!.contact!);
      }
      _atsignImages[widget.selectedList[index]?.contact?.atSign] = image;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeScreenProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: widget.selectedList.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Uint8List? image =
                _atsignImages[widget.selectedList[index]?.contact?.atSign];

            return widget.selectedList[index]?.contact != null
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 4),
                        child: ContactCard(
                          key: Key(
                              widget.selectedList[index]!.contact!.atSign ??
                                  ''),
                          contact: widget.selectedList[index]!.contact!,
                          isTrusted: _checkTrustedContact(
                              widget.selectedList[index]!.contact!),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: InkWell(
                          onTap: () {
                            provider.removeContacts(
                                provider.selectedContacts[index]);
                          },
                          child: SvgPicture.asset(
                            AppVectors.icClose,
                          ),
                        ),
                      )
                    ],
                  )
                : ContactListTile(
                    isSelected: provider.selectedContacts
                        .contains(provider.selectedContacts[index]),
                    onAdd: () {},
                    onRemove: () {
                      provider.removeContacts(provider.selectedContacts[index]);
                      widget.onchange!(true);
                    },
                    name: provider.selectedContacts[index].contact?.atSign
                            ?.substring(1) ??
                        provider.selectedContacts[index].group?.groupName
                            ?.substring(0),
                    atSign: provider.selectedContacts[index].contact?.atSign ??
                        '${provider.selectedContacts[index].group?.members?.length.toString()} Members',
                    image: (image != null)
                        ? CustomCircleAvatar(
                            byteImage: image,
                            nonAsset: true,
                          )
                        : ContactInitial(
                            initials: provider
                                    .selectedContacts[index].contact?.atSign ??
                                provider
                                    .selectedContacts[index].group?.groupName,
                          ),
                  );
          },
        );
      },
    );
  }

  bool _checkTrustedContact(AtContact contact) {
    bool isTrusted = false;
    for (var element in trustedProvider.trustedContacts) {
      if (contact.atSign == element.atSign) {
        isTrusted = true;
      }
    }

    return isTrusted;
  }
}
