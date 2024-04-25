/// A custom list tile to display the contacts
/// takes in a function @param [onTap] to define what happens on tap of the tile
/// @param [onTrailingPresses] to set the behaviour for trailing icon
/// @param [asSelectionTile] to toggle whether the tile is selectable to select contacts
/// @param [contact] for details of the contact
/// @param [contactService] to get an instance of [AtContactsImpl]

// ignore_for_file: avoid_print

import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_utils/at_logger.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopCustomListTile extends StatefulWidget {
  final Function? onTap;
  final Function? onTrailingPressed;
  final bool asSelectionTile;
  final GroupContactsModel? item;
  final bool selectSingle;
  final ValueChanged<List<GroupContactsModel?>>? selectedList;
  final bool isTrusted;
  final List<GroupContactsModel?> selectedContact;
  final bool showSelectedBorder;

  const DesktopCustomListTile({
    Key? key,
    this.onTap,
    this.onTrailingPressed,
    this.asSelectionTile = false,
    this.item,
    this.selectSingle = false,
    this.selectedList,
    required this.isTrusted,
    this.selectedContact = const [],
    required this.showSelectedBorder,
  }) : super(key: key);

  @override
  _DesktopCustomListTileState createState() => _DesktopCustomListTileState();
}

class _DesktopCustomListTileState extends State<DesktopCustomListTile> {
  bool isSelected = false;
  bool isLoading = false;
  late GroupService _groupService;
  AtContact? localContact;
  AtGroup? localGroup;
  AtSignLogger atSignLogger = AtSignLogger('CustomListTile');
  String? initials = 'UG';
  Uint8List? image;

  @override
  void initState() {
    _groupService = GroupService();
    // ignore: omit_local_variable_types

    getIsSelectedValue(widget.selectedContact);
    super.initState();
  }

  getIsSelectedValue(List<GroupContactsModel?> selectedGroupContacts) {
    isSelected = false;
    for (GroupContactsModel? groupContact in selectedGroupContacts) {
      if (groupContact!.contact != null &&
          widget.item!.contact != null &&
          groupContact.contact!.atSign == widget.item!.contact!.atSign) {
        isSelected = true;
      } else if (groupContact.group != null &&
          widget.item!.group != null &&
          groupContact.group!.groupId == widget.item!.group!.groupId) {
        isSelected = true;
      }
    }
  }

  getNameAndImage() {
    try {
      if (widget.item?.contact != null) {
        initials = widget.item?.contact?.atSign;
        if ((initials?[0] ?? 'not@') == '@') {
          initials = initials?.substring(1);
        }

        if (widget.item?.contact?.tags != null &&
            widget.item?.contact?.tags!['image'] != null) {
          List<int> intList = widget.item?.contact?.tags!['image'].cast<int>();
          image = Uint8List.fromList(intList);
        }
      } else {
        if (widget.item?.group?.groupPicture != null) {
          image =
              Uint8List.fromList(widget.item?.group?.groupPicture?.cast<int>());
        }

        initials = widget.item?.group?.displayName;
      }
    } catch (e) {
      initials = 'UG';
      print('Error in getting image $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    getNameAndImage();

    return InkWell(
      onTap: () {
        if (widget.asSelectionTile) {
          if (widget.selectSingle) {
            _groupService.selectedGroupContacts = [];
            _groupService.addGroupContact(widget.item);
            widget.selectedList!([widget.item]);
            Navigator.pop(context);
          } else if (!widget.selectSingle) {
            if (mounted) {
              setState(() {
                if (isSelected) {
                  _groupService.removeGroupContact(widget.item);
                } else {
                  _groupService.addGroupContact(widget.item);
                }
                isSelected = !isSelected;
              });
            }
          }
        } else {
          widget.onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && widget.showSelectedBorder
                ? ColorConstants.orange
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            (isLoading)
                ? const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: (image != null)
                        ? Image.memory(
                            image!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : ContactInitial(
                            size: 72,
                            borderRadius: 0,
                            initials: (initials ?? 'UG'),
                          ),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item?.contact?.atSign ??
                          '${widget.item?.group?.members?.length} Members',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.toFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((widget.item?.contact?.tags?["nickname"] ?? '')
                        .isNotEmpty)
                      Text(
                        widget.item?.contact?.tags?["nickname"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.toFont,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.isTrusted)
              SvgPicture.asset(
                AppVectors.icTrust,
                width: 24,
                height: 20,
                color: ColorConstants.orange,
              ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
