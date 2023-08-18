import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/add_contacts_group_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/horizontal_circular_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_custom_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopGroupContactsList extends StatefulWidget {
  final bool asSelectionScreen;
  final bool singleSelection;
  final ValueChanged<List<GroupContactsModel?>>? onContactsTap;
  final ValueChanged<List<GroupContactsModel?>>? selectedList;
  final bool showContacts;
  final bool showGroups;
  final List<GroupContactsModel?>? initialData;

  const DesktopGroupContactsList({
    Key? key,
    this.asSelectionScreen = false,
    this.singleSelection = false,
    this.onContactsTap,
    this.showContacts = true,
    this.showGroups = false,
    this.selectedList,
    this.initialData,
  }) : super(key: key);

  @override
  State<DesktopGroupContactsList> createState() =>
      _DesktopGroupContactsListState();
}

class _DesktopGroupContactsListState extends State<DesktopGroupContactsList> {
  String searchText = '';
  bool blockingContact = false;
  bool deletingContact = false;
  bool showTrustedContacts = false;
  List<AtContact> trustedContactsList = [];

  @override
  void initState() {
    GroupService().getTrustedContacts().then((value) {
      if (GroupService().trustedContacts.isNotEmpty) {
        if (trustedContactsList.isNotEmpty) {
          trustedContactsList.clear();
        }
        setState(() {
          trustedContactsList.addAll(GroupService().trustedContacts);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: buildSearchField(),
            ),
            const SizedBox(width: 12),
            IconButtonWidget(
              icon: AppVectors.icTrust,
              backgroundColor: ColorConstants.iconButtonColor,
              isSelected: showTrustedContacts,
              onTap: () {
                setState(() {
                  showTrustedContacts = !showTrustedContacts;
                });
              },
            )
          ],
        ),
        const SizedBox(height: 20),
        (widget.asSelectionScreen)
            ? (widget.singleSelection)
                ? Container()
                : HorizontalCircularList(onContactsTap: widget.onContactsTap)
            : Container(),
        (widget.initialData ?? []).isNotEmpty
            ? buildContactsList(widget.initialData)
            : StreamBuilder<List<GroupContactsModel?>>(
                stream: GroupService().allContactsStream,
                initialData: GroupService().allContacts,
                builder: (context, snapshot) {
                  if ((snapshot.connectionState == ConnectionState.waiting)) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if ((snapshot.data == null || snapshot.data!.isEmpty)) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            TextStrings().noContacts,
                            style: CustomTextStyles.blackBold(),
                          ),
                          const SizedBox(height: 20.0),
                          CustomButton(
                            fontColor: Colors.white,
                            buttonColor: ColorConstants.ORANGE,
                            buttonText: 'Add',
                            height: 40,
                            width: 115,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const AddContactDialog(),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return buildContactsList(showTrustedContacts
                          ? trustedContactsList
                              .map((e) => GroupContactsModel(
                                    contact: e,
                                    contactType: ContactsType.CONTACT,
                                  ))
                              .toList()
                          : snapshot.data);
                    }
                  }
                })
      ],
    );
  }

  Widget buildContactsList(List<GroupContactsModel?>? data) {
    // filtering contacts and groups
    var _filteredList = <GroupContactsModel?>[];
    _filteredList = getAllContactList(data ?? []);

    if (_filteredList.isEmpty) {
      return Center(
        child: Text(
          TextStrings().noContactsFound,
          style: TextStyle(
            fontSize: 15.toFont,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    // renders contacts according to the initial alphabet
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80.toHeight),
      itemCount: 27,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, alphabetIndex) {
        var contactsForAlphabet = <GroupContactsModel?>[];
        var currentChar = String.fromCharCode(alphabetIndex + 65).toUpperCase();

        if (alphabetIndex == 26) {
          currentChar = 'Others';
        }

        contactsForAlphabet = getContactsForAlphabets(
          _filteredList,
          currentChar,
          alphabetIndex,
        );

        if (_filteredList.isEmpty) {
          return Center(
            child: Text(TextStrings().noContactsFound),
          );
        }

        if (contactsForAlphabet.isEmpty) {
          return Container();
        }

        return Column(
          children: [
            Row(
              children: [
                Text(
                  currentChar,
                  style: TextStyle(
                    color: ColorConstants.darkSliver,
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16.toWidth),
                Expanded(
                  child: Divider(
                    color: ColorConstants.boxGrey,
                    height: 1.toHeight,
                  ),
                ),
              ],
            ),
            contactListBuilder(contactsForAlphabet)
          ],
        );
      },
    );
  }

  Widget buildSearchField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: (text) => setState(() {
          searchText = text;
        }),
        decoration: InputDecoration(
          filled: true,
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(
            fontSize: 14.toFont,
            color: ColorConstants.grey,
            fontWeight: FontWeight.w500,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 24, top: 20, bottom: 20),
            child: SvgPicture.asset(
              AppVectors.icSearch,
              width: 20,
              height: 20,
              color: ColorConstants.grey,
              fit: BoxFit.cover,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 14.toFont,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<GroupContactsModel?> getAllContactList(
      List<GroupContactsModel?> allGroupContactData) {
    var _filteredList = <GroupContactsModel?>[];
    for (var c in allGroupContactData) {
      if (widget.showContacts &&
          c!.contact != null &&
          c.contact!.atSign
              .toString()
              .toUpperCase()
              .contains(searchText.toUpperCase())) {
        _filteredList.add(c);
      }
      if (widget.showGroups &&
          c!.group != null &&
          c.group!.displayName != null &&
          c.group!.displayName!
              .toUpperCase()
              .contains(searchText.toUpperCase())) {
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
            c!.contact != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              c.contact!.atSign![1].toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (widget.showGroups &&
            c!.group != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              c.group!.displayName![0].toLowerCase(),
            )) {
          contactsForAlphabet.add(c);
        }
      }
    } else {
      for (var c in _filteredList) {
        if (c!.contact != null &&
            c.contact?.atSign![1].toUpperCase() == currentChar) {
          contactsForAlphabet.add(c);
        }
      }
      for (var c in _filteredList) {
        if (c!.group != null &&
            c.group?.displayName![0].toUpperCase() == currentChar) {
          contactsForAlphabet.add(c);
        }
      }
    }

    return contactsForAlphabet;
  }

  Widget contactListBuilder(
    List<GroupContactsModel?> contactsForAlphabet,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      itemCount: contactsForAlphabet.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, _) => Divider(
        color: ColorConstants.dividerColor,
        height: 1.toHeight,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            right: 24,
            bottom: 12,
            top: 12,
          ),
          child: (contactsForAlphabet[index]!.contact != null)
              ? Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        label: TextStrings().block,
                        backgroundColor: ColorConstants.inputFieldColor,
                        icon: Icons.block,
                        onPressed: (context) async {
                          blockUnblockContact(
                              contactsForAlphabet[index]!.contact!);
                        },
                      ),
                      SlidableAction(
                        label: TextStrings().delete,
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        onPressed: (context) async {
                          deleteAtSign(contactsForAlphabet[index]!.contact!);
                        },
                      ),
                    ],
                  ),
                  child: DesktopCustomListTile(
                    key: UniqueKey(),
                    onTap: () {},
                    asSelectionTile: widget.asSelectionScreen,
                    selectSingle: widget.singleSelection,
                    item: contactsForAlphabet[index],
                    selectedList: (s) {
                      widget.selectedList!(s);
                    },
                    onTrailingPressed: () {
                      if (contactsForAlphabet[index]!.contact != null) {
                        Navigator.pop(context);

                        GroupService()
                            .addGroupContact(contactsForAlphabet[index]);
                        widget.selectedList!(
                            GroupService().selectedGroupContacts);
                      }
                    },
                    isTrusted: trustedContactsList.any((element) =>
                        element.atSign ==
                        contactsForAlphabet[index]?.contact?.atSign),
                  ),
                )
              : DesktopCustomListTile(
                  key: UniqueKey(),
                  onTap: () {},
                  asSelectionTile: widget.asSelectionScreen,
                  selectSingle: widget.singleSelection,
                  item: contactsForAlphabet[index],
                  selectedList: (s) {
                    widget.selectedList!(s);
                  },
                  onTrailingPressed: () {
                    if (contactsForAlphabet[index]!.group != null) {
                      Navigator.pop(context);

                      GroupService()
                          .addGroupContact(contactsForAlphabet[index]);
                      widget
                          .selectedList!(GroupService().selectedGroupContacts);
                    }
                  },
                  isTrusted: trustedContactsList.any((element) =>
                      element.atSign ==
                      contactsForAlphabet[index]?.contact?.atSign),
                ),
        );
      },
    );
  }

  blockUnblockContact(AtContact contact,
      {bool closeBottomSheet = false}) async {
    setState(() {
      blockingContact = true;
    });
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().blockContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await ContactService()
        .blockUnblockContact(contact: contact, blockAction: true);
    await GroupService().fetchGroupsAndContacts();
    setState(() {
      blockingContact = true;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }

  deleteAtSign(AtContact contact, {bool closeBottomSheet = false}) async {
    setState(() {
      deletingContact = true;
    });
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().deleteContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await ContactService().deleteAtSign(atSign: contact.atSign!);
    if (_res) {
      await GroupService().removeContact(contact.atSign!);
    }
    setState(() {
      deletingContact = false;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }
}
