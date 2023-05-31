import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_card_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/group_card_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class ContactsWidget extends StatefulWidget {
  final bool isShowAlpha, isSelectMultiContacts;

  final Function(AtContact contact)? onTapContact;
  final Function(AtGroup group)? onTapGroup;
  final Function(List<GroupContactsModel> contacts)? onSelectContacts;
  final List<GroupContactsModel>? selectedContacts;
  final List<AtContact>? trustedContacts;
  final List<GroupContactsModel?> contacts;
  final Function? onRefresh;
  final EdgeInsetsGeometry? padding, contactPadding;
  final ListContactType? contactsType;

  const ContactsWidget({
    Key? key,
    required this.contacts,
    this.isShowAlpha = true,
    this.isSelectMultiContacts = false,
    this.onTapContact,
    this.onTapGroup,
    this.onSelectContacts,
    this.trustedContacts,
    this.selectedContacts,
    this.onRefresh,
    this.padding,
    this.contactPadding,
    this.contactsType,
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
      color: ColorConstants.orange,
      onRefresh: () async {
        widget.onRefresh?.call();
        setState(() {});
      },
      child: ListView.builder(
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

          if (widget.contactsType == ListContactType.trusted) {
            for (var element in (widget.trustedContacts ?? [])) {
              trustedContacts.add(
                GroupContactsModel(
                  contact: element,
                ),
              );
            }
          }

          final listContact = widget.contactsType == ListContactType.trusted
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

          return Padding(
            padding: widget.contactPadding ?? EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isShowAlpha) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            currentChar,
                            style: TextStyle(
                              fontSize: 20.toFont,
                              fontWeight: FontWeight.bold,
                            ),
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
            ),
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
      padding: widget.padding ?? EdgeInsets.only(left: 24),
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

  /// returns list of atsigns, that matches with [currentChar] in [_filteredList]
  List<GroupContactsModel?> getContactsForAlphabets(
      List<GroupContactsModel?> _filteredList,
      String currentChar,
      int alphabetIndex) {
    var contactsForAlphabet = <GroupContactsModel?>[];

    /// contacts, groups that does not starts with alphabets
    if (alphabetIndex == 26) {
      for (var c in _filteredList) {
        if (c?.contact != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              (c?.contact?.atSign?[1] ?? '').toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (c?.group != null && (c?.group?.displayName ?? '').isNotEmpty) {
          if (!RegExp(r'^[a-z]+$').hasMatch(
            (c?.group?.displayName?[0] ?? '').toLowerCase(),
          )) {
            contactsForAlphabet.add(c);
          }
        }
      }
    } else {
      for (var c in _filteredList) {
        if (c?.contact != null) {
          if (c?.contact?.atSign?[1].toUpperCase() == currentChar) {
            contactsForAlphabet.add(c);
          }
        }
      }

      for (var c in _filteredList) {
        if (c?.group != null && (c?.group?.displayName ?? '').isNotEmpty) {
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
