import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_card_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/group_card_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class ContactsWidget extends StatefulWidget {
  final bool showGroups,
      showContacts,
      isShowAlpha,
      isSelectMultiContacts,
      isOnlyShowContactTrusted;

  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup group)? onTapGroup;
  final Function(List<GroupContactsModel> contacts)? onSelectContacts;
  final List<GroupContactsModel>? selectedContacts;
  final List<AtContact>? trustedContacts;
  final List<GroupContactsModel?> contacts;
  final String searchValue;
  final Function? onRefresh;
  final EdgeInsetsGeometry? padding;

  const ContactsWidget({
    Key? key,
    required this.contacts,
    this.showGroups = false,
    this.showContacts = true,
    this.isShowAlpha = true,
    this.isSelectMultiContacts = false,
    this.isOnlyShowContactTrusted = false,
    this.searchValue = '',
    this.onTapContact,
    this.onTapGroup,
    this.onSelectContacts,
    this.trustedContacts,
    this.selectedContacts,
    this.onRefresh,
    this.padding,
  }) : super(key: key);

  @override
  State<ContactsWidget> createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends State<ContactsWidget> {
  List<GroupContactsModel> listContactSelected = [];

  @override
  void initState() {
    if ((widget.selectedContacts ?? []).isNotEmpty) {
      listContactSelected.addAll(widget.selectedContacts!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        physics: const ClampingScrollPhysics(),
        itemCount: 27,
        shrinkWrap: true,
        itemBuilder: (context, alphabetIndex) {
          List<GroupContactsModel?> contactsForAlphabet = [];
          List<GroupContactsModel> trustedContacts = [];
          var currentChar =
              String.fromCharCode(alphabetIndex + 65).toUpperCase();

          if (alphabetIndex == 26) {
            currentChar = 'Others';
          }

          if (widget.isOnlyShowContactTrusted) {
            for (var element in (widget.trustedContacts ?? [])) {
              trustedContacts.add(
                GroupContactsModel(
                  contact: element,
                ),
              );
            }
          }

          final listContact = widget.isOnlyShowContactTrusted
              ? trustedContacts
              : widget.contacts;

          contactsForAlphabet = getContactsForAlphabets(
            listContact,
            currentChar,
            alphabetIndex,
          );

          if (contactsForAlphabet.isEmpty) {
            return const SizedBox();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isShowAlpha) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 9,
                    right: 8,
                    bottom: 10,
                    top: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        currentChar,
                        style: TextStyle(
                          fontSize: 20.toFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16.toWidth),
                      Expanded(
                        child: Divider(
                          color: ColorConstants.dividerGrey,
                          height: 1.toHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              contactListBuilder(contactsForAlphabet)
            ],
          );
        },
      ),
    );
  }

  Widget contactListBuilder(
    List<GroupContactsModel?> contactsForAlphabet,
  ) {
    return ListView.builder(
      itemCount: contactsForAlphabet.length,
      padding: widget.padding ?? EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final contact = contactsForAlphabet[index]!.contact;
        return (contactsForAlphabet[index]!.contact != null)
            ? ContactCardWidget(
                contact: contact!,
                isTrusted: _checkTrustedContact(contact),
                isSelected: _checkContactSelected(
                  contactsForAlphabet[index]!,
                ),
                onTap: () {
                  widget.isSelectMultiContacts
                      ? _onSelectContact(
                          contactsForAlphabet[index]!,
                        )
                      : widget.onTapContact?.call(contact);
                },
              )
            : GroupCardWidget(
                group: contactsForAlphabet[index]!.group!,
                isSelected: _checkContactSelected(
                  contactsForAlphabet[index]!,
                ),
                onTap: () {
                  widget.isSelectMultiContacts
                      ? _onSelectContact(
                          contactsForAlphabet[index]!,
                        )
                      : widget.onTapGroup?.call(
                          contactsForAlphabet[index]!.group!,
                        );
                },
              );
      },
    );
  }

  // creates a list of contacts by merging atsigns and groups.
  List<GroupContactsModel?> getAllContactList(
      List<GroupContactsModel?> allGroupContactData) {
    var _filteredList = <GroupContactsModel?>[];
    for (var c in allGroupContactData) {
      if (widget.showContacts &&
          c?.contact != null &&
          (c?.contact?.atSign ?? '').toString().toUpperCase().contains(
                widget.searchValue.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
      if (widget.showGroups &&
          c?.group != null &&
          c?.group?.displayName != null &&
          (c?.group?.displayName ?? '').toUpperCase().contains(
                widget.searchValue.toUpperCase(),
              )) {
        _filteredList.add(c);
      }
    }

    return _filteredList;
  }

  /// returns list of atsigns, that matches with [currentChar] in [_filteredList]
  List<GroupContactsModel?> getContactsForAlphabets(
      List<GroupContactsModel?> _filteredList,
      String currentChar,
      int alphabetIndex) {
    var contactsForAlphabet = <GroupContactsModel?>[];

    /// contacts, groups that does not starts with alphabets
    if (alphabetIndex == 26) {
      for (var c in _filteredList) {
        if (widget.showContacts &&
            c?.contact != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              (c?.contact?.atSign?[1] ?? '').toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (widget.showGroups &&
            c?.group != null &&
            (c?.group?.displayName ?? '').isNotEmpty) {
          if (!RegExp(r'^[a-z]+$').hasMatch(
            (c?.group?.displayName?[0] ?? '').toLowerCase(),
          )) {
            contactsForAlphabet.add(c);
          }
        }
      }
    } else {
      for (var c in _filteredList) {
        if (widget.showContacts && c?.contact != null) {
          if (c?.contact?.atSign?[1].toUpperCase() == currentChar) {
            contactsForAlphabet.add(c);
          }
        }
      }

      for (var c in _filteredList) {
        if (widget.showGroups &&
            c?.group != null &&
            (c?.group?.displayName ?? '').isNotEmpty) {
          if (c?.group?.displayName?[0].toUpperCase() == currentChar) {
            contactsForAlphabet.add(c);
          }
        }
      }
    }

    return contactsForAlphabet;
  }

  void _onSelectContact(GroupContactsModel contact) {
    if (listContactSelected.isEmpty) {
      listContactSelected.add(contact);
    } else {
      bool isAdd = true;
      GroupContactsModel? contactExists;

      for (var element in listContactSelected) {
        contactExists = element;
        if (contact.contactType == ContactsType.CONTACT) {
          if (contact.contact?.atSign == element.contact?.atSign) {
            isAdd = false;
            break;
          }
        } else {
          if (contact.group?.groupId == element.group?.groupId) {
            isAdd = false;
            break;
          }
        }
      }

      if (!isAdd) {
        listContactSelected.remove(contactExists);
      } else {
        listContactSelected.add(contact);
      }
    }

    widget.onSelectContacts?.call(
      listContactSelected,
    );

    setState(() {});
  }

  bool _checkContactSelected(GroupContactsModel contact) {
    bool isSelected = false;
    for (var element in listContactSelected) {
      if (contact.contactType == ContactsType.CONTACT) {
        if (contact.contact?.atSign == element.contact?.atSign) {
          isSelected = true;
        }
      } else {
        if (contact.group?.groupId == element.group?.groupId) {
          isSelected = true;
        }
      }
    }

    return isSelected;
  }

  bool _checkTrustedContact(AtContact contact) {
    bool isTrusted = false;
    for (var element in (widget.trustedContacts ?? [])) {
      if (contact.atSign == element.atSign) {
        isTrusted = true;
      }
    }

    return isTrusted;
  }
}
