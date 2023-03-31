import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_filter_type.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/header_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contacts_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';

class ListContactWidget extends StatefulWidget {
  final bool showGroups,
      showContacts,
      isShowHeader,
      isOnlyShowSearchBar,
      isShowFilterBar,
      isShowAlpha,
      isSelectMultiContacts,
      isOnlyShowContactTrusted;
  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup contact)? onTapGroup;
  final Function(List<GroupContactsModel> contacts)? onSelectContacts;
  final List<AtContact>? trustedContacts;
  final List<GroupContactsModel>? selectedContacts;
  final Color? searchBackgroundColor, searchBorderColor;
  final String? hintText;

  const ListContactWidget({
    Key? key,
    this.showGroups = false,
    this.showContacts = true,
    this.isShowHeader = true,
    this.isOnlyShowSearchBar = true,
    this.isShowFilterBar = false,
    this.isShowAlpha = true,
    this.isSelectMultiContacts = false,
    this.isOnlyShowContactTrusted = false,
    this.onTapContact,
    this.onTapGroup,
    this.onSelectContacts,
    this.trustedContacts,
    this.selectedContacts,
    this.searchBackgroundColor,
    this.searchBorderColor,
    this.hintText,
  }) : super(key: key);

  @override
  State<ListContactWidget> createState() => _ListContactWidgetState();
}

class _ListContactWidgetState extends State<ListContactWidget> {
  late GroupService _groupService;
  late TextEditingController searchController;

  ContactFilter selectedContactType = ContactFilter.all;
  bool showContacts = true;
  bool showGroups = false;

  @override
  void initState() {
    _groupService = GroupService();
    searchController = TextEditingController();
    showContacts = widget.showContacts;
    showGroups = widget.showGroups;
    _groupService.fetchGroupsAndContacts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.isShowHeader) ...[
          !widget.isOnlyShowSearchBar
              ? HeaderWidget(
                  controller: searchController,
                  onReloadCallback: () {
                    searchController.clear();
                    _groupService.fetchGroupsAndContacts();
                  },
                  onSearch: (value) {
                    setState(() {});
                  },
                  margin:
                      const EdgeInsets.only(bottom: 15, left: 27, right: 27),
                )
              : Container(
                  height: 44.toHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.searchBackgroundColor,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 32.toWidth,
                    vertical: 18.toHeight,
                  ),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color:
                              widget.searchBorderColor ?? ColorConstants.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color:
                              widget.searchBorderColor ?? ColorConstants.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.only(top: 12, left: 14),
                      hintStyle: TextStyle(
                        fontSize: 14.toFont,
                        color: ColorConstants.grey,
                        fontWeight: FontWeight.normal,
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      hintText:
                          widget.hintText ?? 'Search by atSign or nickname',
                    ),
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 14.toFont,
                      color: ColorConstants.fontPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ],
        if (widget.isShowFilterBar) ...[
          Padding(
            padding: const EdgeInsets.only(left: 31, bottom: 8),
            child: Text(
              "Filter By",
              style: TextStyle(
                fontSize: 12.toFont,
                fontWeight: FontWeight.w500,
                color: ColorConstants.grey,
              ),
            ),
          ),
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 27),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: ContactFilter.values.length,
              itemBuilder: (context, index) {
                final type = ContactFilter.values[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedContactType = type;
                      if (type == ContactFilter.contacts) {
                        showContacts = true;
                        showGroups = false;
                      } else if (type == ContactFilter.groups) {
                        showContacts = false;
                        showGroups = true;
                      } else {
                        showContacts = true;
                        showGroups = true;
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 5.toWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.toWidth,
                      vertical: 8.toHeight,
                    ),
                    decoration: BoxDecoration(
                      color: selectedContactType == type
                          ? ColorConstants.orange.withOpacity(0.2)
                          : ColorConstants.textBoxBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedContactType == type
                            ? ColorConstants.orange
                            : ColorConstants.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ContactFilter.values[index].display,
                        style: TextStyle(
                          fontSize: 15.toFont,
                          color: selectedContactType == type
                              ? ColorConstants.orange
                              : ColorConstants.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        Flexible(
          child: StreamBuilder<List<GroupContactsModel?>>(
            stream: _groupService.allContactsStream,
            initialData: _groupService.allContacts,
            builder: (context, snapshot) {
              if ((snapshot.connectionState == ConnectionState.waiting)) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // filtering contacts and groups
                var _filteredList = <GroupContactsModel?>[];
                _filteredList = getAllContactList(snapshot.data ?? []);

                if (_filteredList.isEmpty) {
                  return widget.showGroups
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 122,
                                width: 226,
                                child: Image.asset(
                                  ImageConstants.emptyBox,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "No Result",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.grey,
                                ),
                              )
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            TextStrings().contactEmpty,
                            style: TextStyle(
                              fontSize: 15.toFont,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                }

                // renders contacts according to the initial alphabet
                return Scrollbar(
                  radius: const Radius.circular(11),
                  child: ContactsWidget(
                    contacts: _filteredList,
                    searchValue: searchController.text,
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
                    padding: const EdgeInsets.only(left: 24, right: 6),
                    selectedContacts: widget.selectedContacts,
                    trustedContacts: widget.trustedContacts,
                  ),
                );
              }
            },
          ),
        ),
      ],
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
                searchController.text.toUpperCase(),
              )) {
        _filteredList.add(c);
      }

      if (showGroups &&
          c?.group != null &&
          c?.group?.displayName != null &&
          (c?.group?.displayName ?? '').toUpperCase().contains(
                searchController.text.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
    }

    return _filteredList;
  }
}
