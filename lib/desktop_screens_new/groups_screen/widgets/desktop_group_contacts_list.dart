import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/add_contacts_group_dialog.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_custom_list_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopGroupContactsList extends StatefulWidget {
  final bool asSelectionScreen;
  final List<GroupContactsModel?>? initialData;
  final bool showMembersOnly;
  final bool showSelectedBorder;

  const DesktopGroupContactsList({
    Key? key,
    this.asSelectionScreen = false,
    this.initialData,
    this.showMembersOnly = false,
    this.showSelectedBorder = true,
  }) : super(key: key);

  @override
  State<DesktopGroupContactsList> createState() =>
      _DesktopGroupContactsListState();
}

class _DesktopGroupContactsListState extends State<DesktopGroupContactsList> {
  late GroupService _groupService;
  late DesktopGroupsScreenProvider groupProvider;
  late TrustedContactProvider trustedProvider;
  late TextEditingController searchController;
  bool blockingContact = false;
  bool deletingContact = false;

  @override
  void initState() {
    _groupService = GroupService();
    groupProvider = context.read<DesktopGroupsScreenProvider>();
    trustedProvider = context.read<TrustedContactProvider>();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      groupProvider.setSearchContactText('');
      if (groupProvider.showTrustedContacts) {
        groupProvider.setShowTrustedContacts();
      }
      _groupService.selectedContactsSink.add(widget.initialData ?? []);
    });
    super.initState();
  }

  void setSelectedContactsList(List<GroupContactsModel?> list) {
    _groupService.setSelectedContacts(list.map((e) => e?.contact).toList());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopGroupsScreenProvider>(
        builder: (context, provider, child) {
      return Column(
        children: [
          if (!widget.showMembersOnly) ...[
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
                  isSelected: provider.showTrustedContacts,
                  onTap: () {
                    provider.setShowTrustedContacts();
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
          !widget.asSelectionScreen
              ? buildContactsList(widget.initialData)
              : StreamBuilder<List<GroupContactsModel?>>(
                  stream: _groupService.allContactsStream,
                  initialData: _groupService.allContacts,
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
                                  builder: (context) =>
                                      const AddContactDialog(),
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return buildContactsList(
                          provider.showTrustedContacts
                              ? trustedProvider.trustedContacts
                                  .map((e) => GroupContactsModel(
                                        contact: e,
                                        contactType: ContactsType.CONTACT,
                                      ))
                                  .toList()
                              : snapshot.data,
                        );
                      }
                    }
                  })
        ],
      );
    });
  }

  Widget buildContactsList(List<GroupContactsModel?>? data) {
    // filtering contacts and groups
    var _filteredList = <GroupContactsModel?>[];
    _filteredList = getAllContactList(data ?? []);
    bool isFirst = true;

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
          Widget separator = SizedBox();
          if (widget.showMembersOnly &&
              getContactsForAlphabets(
                _filteredList,
                String.fromCharCode(alphabetIndex + 1 + 65).toUpperCase(),
                alphabetIndex + 1,
              ).isNotEmpty) {
            if (isFirst &&
                getContactsForAlphabets(
                  _filteredList,
                  String.fromCharCode(alphabetIndex -1 + 65).toUpperCase(),
                  alphabetIndex - 1,
                ).isNotEmpty) {
              isFirst = false;
            } else {
              separator = Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: ColorConstants.boxGrey,
                  thickness: 1.toHeight,
                  height: 0,
                ),
              );
            }
          } else if (!widget.showMembersOnly &&
              getContactsForAlphabets(
                _filteredList,
                String.fromCharCode(alphabetIndex + 1 + 65).toUpperCase(),
                alphabetIndex + 1,
              ).isNotEmpty) {
            if (isFirst &&
                getContactsForAlphabets(
                  _filteredList,
                  String.fromCharCode(alphabetIndex -1 + 65).toUpperCase(),
                  alphabetIndex - 1,
                ).isNotEmpty) {
              isFirst = false;
            } else {
              separator = SizedBox(height: 16);
            }
          }
          return separator;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.showMembersOnly) ...[
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
                      thickness: 1.toHeight,
                      height: 0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            contactListBuilder(contactsForAlphabet),
            if (widget.showMembersOnly &&
                getContactsForAlphabets(
                  _filteredList,
                  String.fromCharCode(alphabetIndex + 1 + 65).toUpperCase(),
                  alphabetIndex + 1,
                ).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: ColorConstants.boxGrey,
                  thickness: 1.toHeight,
                  height: 0,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildSearchField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onChanged: (text) => groupProvider.setSearchContactText(text),
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
      if (c!.contact != null &&
          c.contact!.atSign
              .toString()
              .toUpperCase()
              .contains(groupProvider.searchContactText.toUpperCase())) {
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
        if (c!.contact != null &&
            !RegExp(r'^[a-z]+$').hasMatch(
              c.contact!.atSign![1].toLowerCase(),
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
      padding: EdgeInsets.symmetric(
        horizontal: widget.showMembersOnly ? 0 : 28,
      ),
      itemCount: contactsForAlphabet.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
          color: ColorConstants.boxGrey,
          thickness: 1.toHeight,
          height: 0,
        ),
      ),
      itemBuilder: (context, index) {
        return (contactsForAlphabet[index]!.contact != null)
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
                child: StreamBuilder<List<GroupContactsModel?>>(
                    initialData: widget.initialData,
                    stream: _groupService.selectedContactsStream,
                    builder: (context, snapshot) {
                      return DesktopCustomListTile(
                        key: UniqueKey(),
                        onTap: () {},
                        asSelectionTile: widget.asSelectionScreen,
                        selectSingle: false,
                        item: contactsForAlphabet[index],
                        selectedList: (s) {
                          setSelectedContactsList(s);
                        },
                        selectedContact: snapshot.data ?? [],
                        onTrailingPressed: () {
                          if (contactsForAlphabet[index]!.contact != null) {
                            Navigator.pop(context);

                            _groupService
                                .addGroupContact(contactsForAlphabet[index]);
                            setSelectedContactsList(
                                _groupService.selectedGroupContacts);
                          }
                        },
                        isTrusted: trustedProvider.trustedContacts.any(
                            (element) =>
                                element.atSign ==
                                contactsForAlphabet[index]?.contact?.atSign),
                        showSelectedBorder: widget.showSelectedBorder,
                      );
                    }),
              )
            : StreamBuilder<List<GroupContactsModel?>>(
                initialData: widget.initialData,
                stream: _groupService.selectedContactsStream,
                builder: (context, snapshot) {
                  return DesktopCustomListTile(
                    key: UniqueKey(),
                    onTap: () {},
                    asSelectionTile: widget.asSelectionScreen,
                    selectSingle: false,
                    item: contactsForAlphabet[index],
                    selectedList: (s) {
                      setSelectedContactsList(s);
                    },
                    selectedContact: snapshot.data ?? [],
                    onTrailingPressed: () {
                      if (contactsForAlphabet[index]!.group != null) {
                        Navigator.pop(context);

                        _groupService
                            .addGroupContact(contactsForAlphabet[index]);
                        setSelectedContactsList(
                            _groupService.selectedGroupContacts);
                      }
                    },
                    isTrusted: trustedProvider.trustedContacts.any((element) =>
                        element.atSign ==
                        contactsForAlphabet[index]?.contact?.atSign),
                    showSelectedBorder: widget.showSelectedBorder,
                  );
                });
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
    await _groupService.fetchGroupsAndContacts();
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
      await _groupService.removeContact(contact.atSign!);
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
