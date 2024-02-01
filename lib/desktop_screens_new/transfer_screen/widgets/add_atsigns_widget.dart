import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/add_contacts_screen.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_add_group.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/transfer_screen/widgets/add_contact_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddAtSignsWidget extends StatefulWidget {
  final List<AtContact> trustedContacts;
  final List<GroupContactsModel> selectedContacts;
  final Function(List<GroupContactsModel>) addSelectedContactList;

  const AddAtSignsWidget({
    required this.trustedContacts,
    required this.selectedContacts,
    required this.addSelectedContactList,
  });

  @override
  State<AddAtSignsWidget> createState() => _AddAtSignsWidgetState();
}

class _AddAtSignsWidgetState extends State<AddAtSignsWidget> {
  TextEditingController searchController = TextEditingController();
  List<GroupContactsModel?> filteredContactList = [
    ...GroupService().allContacts
  ];
  late List<GroupContactsModel> selectedList = [...widget.selectedContacts];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      elevation: 5.0,
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        width: 400.toWidth,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Add atSigns",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonButton(
                          'Add contact',
                          () async {
                            await showAddContactDialog().then((value) async {
                              if (value) {
                                if (searchController.text.isNotEmpty) {
                                  searchController.clear();
                                }
                                await GroupService()
                                    .fetchGroupsAndContacts(isDesktop: true);
                                filteredContactList = [
                                  ...GroupService().allContacts
                                ];
                                setState(() {});
                              }
                            });
                          },
                          color: Color(0xFFF07C50),
                          border: 20,
                          height: 40,
                          width: 136,
                          fontSize: 18,
                          removePadding: true,
                        ),
                        CommonButton(
                          'Add group',
                          () async {
                            await showAddGroupDialog().then((value) async {
                              if (value) {
                                if (searchController.text.isNotEmpty) {
                                  searchController.clear();
                                }
                                await GroupService()
                                    .fetchGroupsAndContacts(isDesktop: true);
                                filteredContactList = [
                                  ...GroupService().allContacts
                                ];
                                setState(() {});
                              }
                            });
                          },
                          color: Color(0xFFF07C50),
                          border: 20,
                          height: 40,
                          width: 136,
                          fontSize: 18,
                          removePadding: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              if (searchController.text.isEmpty) {
                                filteredContactList = [
                                  ...GroupService().allContacts
                                ];
                              } else {
                                filteredContactList = [];
                                for (var contact
                                    in GroupService().allContacts) {
                                  if (contact?.contactType ==
                                      ContactsType.CONTACT) {
                                    if ((contact?.contact?.atSign
                                            ?.contains(value)) ??
                                        false) {
                                      filteredContactList.add(contact);
                                    }
                                  } else if (contact?.contactType ==
                                      ContactsType.GROUP) {
                                    if ((contact?.group?.groupName
                                            ?.contains(value)) ??
                                        false) {
                                      filteredContactList.add(contact);
                                    }
                                  }
                                }
                              }
                              setState(() {});
                            },
                            controller: searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              hintText: "Search...",
                              suffixIcon: Icon(
                                Icons.search,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),

                  SizedBox(height: 30),

                  // contact list
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredContactList.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var groupContactModel = filteredContactList[index];
                      late AtContact contact;
                      var isTrusted = false;
                      Uint8List? byteImage;
                      String initialLetter = '';

                      if (groupContactModel?.contactType ==
                          ContactsType.CONTACT) {
                        contact = groupContactModel!.contact!;
                        for (var ts in widget.trustedContacts) {
                          if (ts.atSign == (contact.atSign)) {
                            isTrusted = true;
                          }
                        }
                        if (initialLetter != contact.atSign?[1]) {
                          initialLetter = contact.atSign?[1] ?? "";
                        } else {
                          initialLetter = "";
                        }
                        byteImage =
                            CommonUtilityFunctions().getCachedContactImage(
                          contact.atSign!,
                        );
                      } else {
                        if ((groupContactModel?.group?.groupName?.isNotEmpty ??
                                false) &&
                            initialLetter !=
                                groupContactModel?.group?.groupName?[0]) {
                          initialLetter =
                              groupContactModel?.group?.groupName?[0] ?? "";
                        } else {
                          initialLetter = "";
                        }

                        List<int>? intList =
                            groupContactModel?.group?.groupPicture?.cast<int>();
                        byteImage = intList != null
                            ? Uint8List.fromList(intList)
                            : null;
                      }

                      return Column(
                        children: [
                          initialLetter != ""
                              ? Row(
                                  children: [
                                    Text(
                                      initialLetter,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF717171),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, top: 5, bottom: 5),
                            child: InkWell(
                              onTap: () =>
                                  addSelectedContacts(groupContactModel!),
                              child: groupContactModel?.contactType ==
                                      ContactsType.CONTACT
                                  ? AddContactTile(
                                      title: contact.atSign,
                                      subTitle: contact.tags?["nickname"],
                                      image: byteImage,
                                      showImage: byteImage != null,
                                      isSelected:
                                          isSelected(groupContactModel!),
                                      showDivider: true,
                                      isTrusted: isTrusted,
                                    )
                                  : AddContactTile(
                                      title:
                                          groupContactModel?.group?.groupName,
                                      subTitle:
                                          '${groupContactModel?.group?.members?.length} member(s)',
                                      image: byteImage,
                                      showImage: byteImage != null,
                                      isSelected:
                                          isSelected(groupContactModel!),
                                      showDivider: true,
                                      isTrusted: false,
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.addSelectedContactList.call(selectedList);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  margin: EdgeInsets.only(bottom: 20),
                  width: double.maxFinite,
                  child: Text(
                    "Add atSigns ${selectedList.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isSelected(GroupContactsModel groupContactsModel) {
    for (GroupContactsModel contact in selectedList) {
      if ((groupContactsModel.contactType == ContactsType.CONTACT &&
              contact.contact?.atSign == groupContactsModel.contact?.atSign) ||
          (groupContactsModel.contactType == ContactsType.GROUP &&
              contact.group?.groupId == groupContactsModel.group?.groupId)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> showAddContactDialog() async {
    bool shouldRefresh = false;
    await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            elevation: 5.0,
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              width: 400.toWidth,
              child: DesktopAddContactScreen(
                onBack: (value) async {
                  Navigator.pop(context);
                  if (value) {
                    shouldRefresh = value;
                  }
                },
              ),
            ),
          );
        });
    return shouldRefresh;
  }

  Future<bool> showAddGroupDialog() async {
    bool shouldRefresh = false;
    await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            elevation: 5.0,
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              width: 400.toWidth,
              child: DesktopAddGroup(
                onDoneTap: (value) {
                  Navigator.pop(context);
                  if (value) {
                    shouldRefresh = value;
                  }
                },
              ),
            ),
          );
        });
    return shouldRefresh;
  }

  void addSelectedContacts(GroupContactsModel groupContactModel) {
    if (isSelected(groupContactModel)) {
      selectedList.removeWhere(
        (element) =>
            (element.contactType == ContactsType.CONTACT &&
                element.contact?.atSign == groupContactModel.contact?.atSign) ||
            (element.contactType == ContactsType.GROUP &&
                element.group?.groupId == groupContactModel.group?.groupId),
      );
    } else {
      selectedList.add(groupContactModel);
    }
    setState(() {});
  }
}
