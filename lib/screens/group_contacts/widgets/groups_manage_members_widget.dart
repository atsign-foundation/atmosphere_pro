import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_member_item_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/groups_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class GroupsManageMembersWidget extends StatefulWidget {
  const GroupsManageMembersWidget();

  @override
  State<GroupsManageMembersWidget> createState() =>
      _GroupsManageMembersWidgetState();
}

class _GroupsManageMembersWidgetState extends State<GroupsManageMembersWidget> {
  TextEditingController searchController = TextEditingController();
  late TrustedContactProvider trustedContactProvider =
      context.read<TrustedContactProvider>();
  late GroupsProvider groupsProvider = context.read<GroupsProvider>();

  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _groupService.fetchGroupsAndContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: GroupsAppBar(title: 'Manage Members'),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 28),
                Padding(
                  padding: EdgeInsets.only(left: 36, right: 20),
                  child: buildSearchWidget(),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Selector<GroupsProvider, Tuple2<String, bool>>(
                    builder: (context, value, child) {
                      return ListView.separated(
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 32,
                          right: 32,
                          bottom: 112,
                        ),
                        itemBuilder: (context, index) {
                          return buildContactList(
                            filterContacts(
                              data: _groupService.allContacts
                                  .where((e) => e?.contact != null)
                                  .map((e) => e!.contact!)
                                  .toList(),
                              searchKeyword: value.item1,
                              showTrustedMembers: value.item2,
                            ),
                          )[index];
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 12);
                        },
                        itemCount: buildContactList(
                          filterContacts(
                            data: _groupService.allContacts
                                .where((e) => e?.contact != null)
                                .map((e) => e!.contact!)
                                .toList(),
                            searchKeyword: value.item1,
                            showTrustedMembers: value.item2,
                          ),
                        ).length,
                      );
                    },
                    selector: (_, p) => Tuple2<String, bool>(
                      p.searchKeyword,
                      p.showTrustedMembers,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 28,
              left: 48,
              right: 48,
              child: buildSelectContactButton(),
            ),
          ],
        ),
      ),
    );
  }

  List<AtContact> filterContacts(
      {required List<AtContact> data,
      required bool showTrustedMembers,
      required String searchKeyword}) {
    List<AtContact> sampleList = data;

    if (showTrustedMembers) {
      sampleList = sampleList
          .where((element) => trustedContactProvider.trustedContacts
              .any((e) => e.atSign == element.atSign))
          .map((e) => e)
          .toList();
    } else if (searchKeyword.isNotEmpty) {
      sampleList = sampleList
          .where((element) => (element.atSign ?? '').contains(searchKeyword))
          .map((e) => e)
          .toList();
    }
    return sampleList;
  }

  Widget buildSearchWidget() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            maxLines: 1,
            onChanged: (value) {
              groupsProvider.changeSearchKeyword(value);
            },
            style: CustomTextStyles.blackW50014,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 20,
                top: 20,
                bottom: 20,
                right: 24,
              ),
              hintText: 'Search',
              hintStyle: CustomTextStyles.greyW50014,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              suffixIcon: Icon(
                Icons.search,
                size: 20,
                color: ColorConstants.grey,
              ),
            ),
            controller: searchController,
          ),
        ),
        SizedBox(width: 12),
        InkWell(
          onTap: () {
            groupsProvider.setShowTrustedMembersStatus();
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorConstants.iconButtonColor,
              shape: BoxShape.circle,
            ),
            child: Selector<GroupsProvider, bool>(
              builder: (context, value, child) {
                return SvgPicture.asset(
                  AppVectors.icTrust,
                  width: 24,
                  height: 20,
                  color: value ? ColorConstants.orange : Colors.black,
                  fit: BoxFit.cover,
                );
              },
              selector: (_, p) => p.showTrustedMembers,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildContactList(List<AtContact> list) {
    final List<Widget> result = [];
    if (list.isNotEmpty) {
      final List<AtContact> sortedList = sortGroupAlphabetical(list);
      bool isSameCharWithPrev(int i) =>
          (((sortedList[i].atSign ?? '').isNotEmpty
                  ? sortedList[i].atSign![1]
                  : ' ') !=
              ((sortedList[i - 1].atSign ?? '').isNotEmpty
                  ? sortedList[i - 1].atSign![1]
                  : ' '));

      bool isPrevCharacter(int i) => RegExp(r'^[a-z]+$').hasMatch(
          (((sortedList[i - 1].atSign ?? '').isNotEmpty
                  ? sortedList[i - 1].atSign![1]
                  : ' '))[0]
              .toLowerCase());

      for (int i = 0; i < sortedList.length; i++) {
        if (i == 0 || (isSameCharWithPrev(i) && isPrevCharacter(i))) {
          result.add(buildAlphabeticalTitle(
              (sortedList[i].atSign ?? '').isNotEmpty
                  ? sortedList[i].atSign![1]
                  : ''));
        }
        result.add(
          Selector<GroupsProvider, bool>(
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GroupsMemberItemWidget(
                  member: sortedList[i],
                  isTrusted: trustedContactProvider.trustedContacts.any(
                    (element) => element.atSign == sortedList[i].atSign,
                  ),
                  isSelected: value,
                  onTap: () {
                    groupsProvider.addOrRemoveMember(sortedList[i]);
                  },
                ),
              );
            },
            selector: (_, p) => p.members.any(
              (element) => element.atSign == sortedList[i].atSign,
            ),
          ),
        );
      }
    }
    return result;
  }

  Widget buildAlphabeticalTitle(String char) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
          SizedBox(width: 20),
          Divider(
            height: 1.toHeight,
            color: ColorConstants.dividerColor,
          )
        ],
      ),
    );
  }

  List<AtContact> sortGroupAlphabetical(List<AtContact> list) {
    final List<AtContact> emptyTitleContact = list
        .where((e) =>
            (e.atSign ?? '').isEmpty ||
            !RegExp(r'^[a-z]+$').hasMatch(
              (e.atSign ?? '')[1].toLowerCase(),
            ))
        .toList();
    final List<AtContact> nonEmptyTitleContact = list
        .where((e) =>
            (e.atSign ?? '').isNotEmpty &&
            RegExp(r'^[a-z]+$').hasMatch(
              (e.atSign ?? '')[1].toLowerCase(),
            ))
        .toList();
    nonEmptyTitleContact.sort(
      (a, b) => (a.atSign?[1] ?? '').compareTo(
        (b.atSign?[1] ?? ''),
      ),
    );
    return [...nonEmptyTitleContact, ...emptyTitleContact];
  }

  Widget buildSelectContactButton() {
    return InkWell(
      onTap: () async {
        await groupsProvider.updateMembers(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Selector<GroupsProvider, Tuple2<int, bool>>(
          builder: (context, value, child) {
            return value.item2
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      text: 'Selects Contact ',
                      style: CustomTextStyles.whiteBold16,
                      children: [
                        TextSpan(
                          text: '(${value.item1})',
                          style: CustomTextStyles.whiteW40016,
                        ),
                      ],
                    ),
                  );
          },
          selector: (_, p) => Tuple2<int, bool>(
            p.members.length,
            p.isLoading,
          ),
        ),
      ),
    );
  }
}
