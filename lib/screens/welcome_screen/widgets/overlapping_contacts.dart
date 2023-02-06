import 'dart:typed_data';

/// This is a custom widget to display the selected contacts
/// in a row with overlapping profile pictures
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

import '../../../utils/colors.dart';

class OverlappingContacts extends StatefulWidget {
  final List<GroupContactsModel?> selectedList;
  final ValueChanged<bool>? onChnage;

  const OverlappingContacts(
      {Key? key, required this.selectedList, this.onChnage})
      : super(key: key);

  @override
  _OverlappingContactsState createState() => _OverlappingContactsState();
}

class _OverlappingContactsState extends State<OverlappingContacts> {
  bool isExpanded = false;
  Map _atsignImages = {};

  @override
  void initState() {
    for (var index = 0; index < widget.selectedList!.length; index++) {
      Uint8List? image;
      if (widget.selectedList![index]?.contact?.tags != null &&
          widget.selectedList![index]?.contact?.tags!['image'] != null) {
        image = CommonUtilityFunctions()
            .getContactImage(widget.selectedList![index]!.contact!);
      }
      _atsignImages[widget.selectedList![index]?.contact?.atSign] = image;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      setState(() {
        isExpanded = !isExpanded;
      });
    }, child: Consumer<WelcomeScreenProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 80.toHeight * widget.selectedList.length,
          width: 350.toWidth > 350 ? 350 : 350.toWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorConstants.textBoxBg),
          ),
          child: ListView.builder(
            itemCount: widget.selectedList.length,
            itemBuilder: (context, index) {
              Uint8List? image =
                  _atsignImages[widget.selectedList![index]?.contact?.atSign];

              return ContactListTile(
                isSelected: provider.selectedContacts
                    .contains(provider.selectedContacts[index]),
                onAdd: () {},
                onRemove: () {
                  provider.removeContacts(provider.selectedContacts[index]);
                  widget.onChnage!(true);
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
                            provider.selectedContacts[index].group?.groupName,
                      ),
              );
            },
          ),
        );
      },
    ));
  }
}
