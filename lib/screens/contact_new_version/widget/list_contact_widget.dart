import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart'
    hide ContactsType;
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contacts_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

import 'empty_contact_widget.dart';

class ListContactWidget extends StatefulWidget {
  final bool isShowAlpha, isSelectMultiContacts;
  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup contact)? onTapGroup;
  final Function(List<GroupContactsModel> contacts)? onSelectContacts;
  final List<AtContact>? trustedContacts;
  final List<GroupContactsModel>? selectedContacts;
  final ListContactType? contactsType;
  final String searchKeywords;
  final Function()? onTapAddButton;

  const ListContactWidget({
    Key? key,
    this.isShowAlpha = true,
    this.isSelectMultiContacts = false,
    this.onTapContact,
    this.onTapGroup,
    this.onSelectContacts,
    this.trustedContacts,
    this.selectedContacts,
    this.contactsType,
    this.searchKeywords = '',
    this.onTapAddButton,
  }) : super(key: key);

  @override
  State<ListContactWidget> createState() => _ListContactWidgetState();
}

class _ListContactWidgetState extends State<ListContactWidget>
    with AutomaticKeepAliveClientMixin<ListContactWidget> {
  late GroupService _groupService;
  late ScrollController scrollController;
  bool showContacts = false;
  bool showGroups = false;

  @override
  void initState() {
    _groupService = GroupService();

    if (widget.contactsType == ListContactType.all) {
      showContacts = true;
      showGroups = true;
    } else if (widget.contactsType == ListContactType.groups) {
      showContacts = false;
      showGroups = true;
    } else {
      showContacts = true;
      showGroups = false;
    }

    scrollController = ScrollController();
    // _groupService.fetchGroupsAndContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);
    return StreamBuilder<List<GroupContactsModel?>>(
      stream: _groupService.allContactsStream,
      initialData: _groupService.allContacts,
      builder: (context, snapshot) {
        // if ((snapshot.connectionState == ConnectionState.waiting)) {
        //   return const Center(
        //     child: CircularProgressIndicator(
        //       color: ColorConstants.orange,
        //     ),
        //   );
        // } else {
        // filtering contacts and groups
        var _filteredList = <GroupContactsModel?>[];
        List<GroupContactsModel> trustedContacts = [];
        _filteredList = getAllContactList(snapshot.data ?? []);

        if (_filteredList.isEmpty) {
          return EmptyContactsWidget(
            contactsType: widget.contactsType,
            onTapAddButton: widget.onTapAddButton ?? () {},
          );
        }

        if (widget.contactsType == ListContactType.trusted) {
          for (var element in (widget.trustedContacts ?? [])) {
            trustedContacts.add(
              GroupContactsModel(
                contact: element,
              ),
            );
          }

          if (trustedContacts.isEmpty) {
            return EmptyContactsWidget(
              contactsType: widget.contactsType,
              onTapAddButton: widget.onTapAddButton ?? () {},
            );
          }
        }

        // renders contacts according to the initial alphabet
        return Column(
          children: [
            if (widget.contactsType == ListContactType.trusted) ...[
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  'Files that are sent from contacts you ‘trust’ will automatically be downloaded in History',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.darkSliver,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
            ],
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                radius: const Radius.circular(11),
                child: ContactsWidget(
                  scrollController: scrollController,
                  contacts: _filteredList,
                  contactsType: widget.contactsType,
                  isShowAlpha: widget.isShowAlpha,
                  isSelectMultiContacts: widget.isSelectMultiContacts,
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
              ),
            ),
          ],
        );
        // }
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

  @override
  bool get wantKeepAlive => true;
}
