import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart'
    hide ContactsType;
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_filter_type.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contacts_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

import 'empty_contact_widget.dart';

class ListContactWidget extends StatefulWidget {
  final bool showGroups,
      showContacts,
      isShowAlpha,
      isSelectMultiContacts,
      isOnlyShowContactTrusted;
  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup contact)? onTapGroup;
  final Function(List<GroupContactsModel> contacts)? onSelectContacts;
  final List<AtContact>? trustedContacts;
  final List<GroupContactsModel>? selectedContacts;
  final ContactsType? contactsType;
  final String searchKeywords;

  const ListContactWidget({
    Key? key,
    this.showGroups = false,
    this.showContacts = true,
    this.isShowAlpha = true,
    this.isSelectMultiContacts = false,
    this.isOnlyShowContactTrusted = false,
    this.onTapContact,
    this.onTapGroup,
    this.onSelectContacts,
    this.trustedContacts,
    this.selectedContacts,
    this.contactsType,
    this.searchKeywords = '',
  }) : super(key: key);

  @override
  State<ListContactWidget> createState() => _ListContactWidgetState();
}

class _ListContactWidgetState extends State<ListContactWidget> {
  late GroupService _groupService;

  ContactFilter selectedContactType = ContactFilter.all;
  bool showContacts = true;
  bool showGroups = false;

  @override
  void initState() {
    _groupService = GroupService();
    showContacts = widget.showContacts;
    showGroups = widget.showGroups;
    _groupService.fetchGroupsAndContacts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder<List<GroupContactsModel?>>(
      stream: _groupService.allContactsStream,
      initialData: _groupService.allContacts,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.waiting)) {
          return const Center(
            child: CircularProgressIndicator(
              color: ColorConstants.orange,
            ),
          );
        } else {
          // filtering contacts and groups
          var _filteredList = <GroupContactsModel?>[];
          _filteredList = getAllContactList(snapshot.data ?? []);

          if (_filteredList.isEmpty) {
            return EmptyContactsWidget(
              contactsType: widget.contactsType,
            );
          }
          // renders contacts according to the initial alphabet
          return Scrollbar(
            radius: const Radius.circular(11),
            child: ContactsWidget(
              contacts: _filteredList,
              searchValue: widget.searchKeywords,
              showGroups: widget.showGroups,
              showContacts: widget.showContacts,
              isShowAlpha: widget.isShowAlpha,
              isSelectMultiContacts: widget.isSelectMultiContacts,
              isOnlyShowContactTrusted: widget.isOnlyShowContactTrusted,
              onTapContact: widget.onTapContact,
              onTapGroup: widget.onTapGroup,
              onSelectContacts: widget.onSelectContacts,
              onRefresh: () async {
                await _groupService.fetchGroupsAndContacts();
              },
              contactPadding: EdgeInsets.only(left: 18, right: 28),
              selectedContacts: widget.selectedContacts,
              trustedContacts: widget.trustedContacts,
            ),
          );
        }
      },
    );
  }

  // creates a list of contacts by merging atsigns and groups.
  List<GroupContactsModel?> getAllContactList(
      List<GroupContactsModel?> allGroupContactData) {
    var _filteredList = <GroupContactsModel?>[];

    for (var c in allGroupContactData) {
      if (showContacts &&
          c?.contact != null &&
          (c?.contact?.atSign ?? '').toString().toUpperCase().contains(
                widget.searchKeywords.toUpperCase(),
              )) {
        _filteredList.add(c);
      }

      if (showGroups &&
          c?.group != null &&
          c?.group?.displayName != null &&
          (c?.group?.displayName ?? '').toUpperCase().contains(
                widget.searchKeywords.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
    }

    return _filteredList;
  }
}
