import 'dart:typed_data';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_routes.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopGroupsList extends StatefulWidget {
  final List<AtGroup> groups;
  final int expandIndex;
  final bool showBackButton;
  final Function(AtGroup) onExpand;
  final Function() onAdd;

  const DesktopGroupsList(
    this.groups, {
    Key? key,
    this.expandIndex = 0,
    this.showBackButton = true,
    required this.onExpand,
    required this.onAdd,
  }) : super(key: key);

  @override
  _DesktopGroupsListState createState() => _DesktopGroupsListState();
}

class _DesktopGroupsListState extends State<DesktopGroupsList> {
  String searchText = '';
  bool showBackIcon = true;
  List<AtGroup> _filteredList = [];
  bool isSearching = false;
  List<AtContact> trustedContactsList = [];

  @override
  void initState() {
    showBackIcon = GroupService().groupPreferece.showBackButton;
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
    if (searchText != '') {
      _filteredList = widget.groups.where((grp) {
        return grp.displayName!.contains(searchText);
      }).toList();
    } else {
      _filteredList = widget.groups;
    }
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          DesktopHeader(
            title: 'Groups',
            isTitleCentered: false,
            showBackIcon: showBackIcon,
            onBackTap: () {
              DesktopGroupSetupRoutes.exitGroupPackage();
            },
            actions: [
              isSearching
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        height: 40,
                        width: 308,
                        color: Colors.white,
                        child: TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 8),
                            border: InputBorder.none,
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: ColorConstants.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    searchText = '';
                                    isSearching = false;
                                  });
                                },
                                child: const Icon(Icons.close)),
                          ),
                        ),
                      ),
                    )
                  : IconButtonWidget(
                      icon: AppVectors.icSearch,
                      onTap: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ),
              const SizedBox(width: 12),
              IconButtonWidget(
                icon: AppVectors.icRefresh,
                onTap: () {
                  setState(() {
                    GroupService().getAllGroupsDetails();
                  });
                },
              ),
              const SizedBox(width: 12),
              buildAddGroupButton(),
            ],
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      TextStrings().noContactsFound,
                      style: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                : ListView(
                    physics: const ClampingScrollPhysics(),
                    children: buildGroupList(),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildGroupList() {
    final List<Widget> result = [];
    if (_filteredList.isNotEmpty) {
      final List<AtGroup> sortedList = sortGroupAlphabetical();
      bool isSameCharWithPrev(int i) =>
          (((sortedList[i].displayName ?? '').isNotEmpty
                  ? sortedList[i].displayName![0]
                  : ' ') !=
              ((sortedList[i - 1].displayName ?? '').isNotEmpty
                  ? sortedList[i - 1].displayName![0]
                  : ' '));

      bool isPrevCharacter(int i) => RegExp(r'^[a-z]+$').hasMatch(
          (((sortedList[i - 1].displayName ?? '').isNotEmpty
                  ? sortedList[i - 1].displayName![0]
                  : ' '))[0]
              .toLowerCase());

      for (int i = 0; i < sortedList.length; i++) {
        if (i == 0 || (isSameCharWithPrev(i) && isPrevCharacter(i))) {
          result.add(buildAlphabeticalTitle(
              (sortedList[i].displayName ?? '').isNotEmpty
                  ? sortedList[i].displayName![0]
                  : ''));
        }
        result.add(
          buildGroupCard(
            index: i,
            data: sortedList[i],
          ),
        );
      }
    }
    return result;
  }

  Widget buildGroupCard({
    required AtGroup data,
    required int index,
  }) {
    return InkWell(
      onTap: () => widget.onExpand(data),
      child: Container(
        height: 72,
        margin: const EdgeInsets.only(
          bottom: 12,
          left: 80,
          right: 80,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: data.groupPicture != null
                      ? Image.memory(
                          Uint8List.fromList(data.groupPicture.cast<int>()),
                          fit: BoxFit.cover,
                          width: 72,
                        )
                      : ContactInitial(
                          size: 72,
                          borderRadius: 0,
                          initials: ((data.displayName ?? '').isNotEmpty &&
                                  RegExp(r'^[a-z]+$').hasMatch(
                                      (data.displayName ?? '')[0]
                                          .toLowerCase()))
                              ? data.displayName!
                              : 'UG',
                        ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.displayName ?? '',
                      style: CustomTextStyles.blackW60013,
                    ),
                    Text(
                      '${data.members?.length} Members',
                      style: CustomTextStyles.blackW40011,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AppVectors.icSendGroup,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AppVectors.icOptions,
                    width: 20,
                    height: 4,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(width: 32),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildAlphabeticalTitle(String char) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 52,
        right: 52,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          char.isNotEmpty && RegExp(r'^[a-z]+$').hasMatch(char.toLowerCase())
              ? Text(
                  char.toUpperCase(),
                  style: CustomTextStyles.darkSliverBold20,
                )
              : Text(
                  'Others',
                  style: CustomTextStyles.darkSliverBold20,
                ),
          Divider(
            height: 1.toHeight,
            color: ColorConstants.dividerColor,
          )
        ],
      ),
    );
  }

  List<AtGroup> sortGroupAlphabetical() {
    final List<AtGroup> emptyTitleGroup = _filteredList
        .where((e) =>
            (e.displayName ?? '').isEmpty ||
            !RegExp(r'^[a-z]+$').hasMatch(
              (e.displayName ?? '')[0].toLowerCase(),
            ))
        .toList();
    final List<AtGroup> nonEmptyTitleGroup = _filteredList
        .where((e) =>
            (e.displayName ?? '').isNotEmpty &&
            RegExp(r'^[a-z]+$').hasMatch(
              (e.displayName ?? '')[0].toLowerCase(),
            ))
        .toList();
    nonEmptyTitleGroup.sort(
      (a, b) => (a.displayName?[0] ?? '').compareTo(
        (b.displayName?[0] ?? ''),
      ),
    );
    return [...nonEmptyTitleGroup, ...emptyTitleGroup];
  }

  Widget buildAddGroupButton() {
    return InkWell(
      onTap: widget.onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(46),
          color: ColorConstants.orange,
        ),
        child: Text(
          'Add groups',
          style: CustomTextStyles.whiteW50015,
        ),
      ),
    );
  }
}
