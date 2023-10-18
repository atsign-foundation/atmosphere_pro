import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_empty_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/error_screen.dart';
import 'package:at_utils/at_logger.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_add_group.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_groups_detail.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_groups_list.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class DesktopGroupsScreen extends StatefulWidget {
  const DesktopGroupsScreen({Key? key}) : super(key: key);

  @override
  State<DesktopGroupsScreen> createState() => _DesktopGroupsScreenState();
}

class _DesktopGroupsScreenState extends State<DesktopGroupsScreen> {
  bool createBtnTapped = false;
  bool shouldUpdate = false;
  List<AtGroup>? previousData;

  AtSignLogger atSignLogger = AtSignLogger('DesktopGroupInitialScreen');
  late DesktopGroupsScreenProvider groupsProvider;

  @override
  void initState() {
    groupsProvider = context.read<DesktopGroupsScreenProvider>();
    try {
      super.initState();
      GroupService().getAllGroupsDetails();
    } catch (e) {
      atSignLogger.severe('Error in init of Group_list $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopGroupsScreenProvider>(
        builder: (context, provider, child) {
      return Container(
        color: ColorConstants.background,
        child: Stack(
          children: [
            StreamBuilder(
              stream: GroupService().atGroupStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<AtGroup>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasError) {
                    return ErrorScreen(onPressed: () {
                      GroupService().getAllGroupsDetails();
                    });
                  } else {
                    if (snapshot.hasData) {
                      if ((previousData == null) ||
                          (!areListsEqual(previousData, snapshot.data))) {
                        shouldUpdate = true;
                        previousData = snapshot.data;
                      } else {
                        shouldUpdate = false;
                      }

                      if (snapshot.data!.isEmpty) {
                        return Center(
                          child: DesktopEmptyGroup(
                              provider.groupCardState == GroupCardState.add,
                              onCreateBtnTap: () {
                            provider.setGroupCardState(GroupCardState.add);
                          }),
                        );
                      } else {
                        return DesktopGroupsList(
                          snapshot.data!,
                          key: UniqueKey(),
                          expandIndex: GroupService().expandIndex ?? 0,
                          onExpand: (value) {
                            provider.setSelectedAtGroup(value);
                            provider.setGroupCardState(GroupCardState.expanded);
                          },
                          onAdd: () {
                            provider.setGroupCardState(GroupCardState.add);
                          },
                        );
                      }
                    } else {
                      return Center(
                        child: DesktopEmptyGroup(
                            provider.groupCardState == GroupCardState.add,
                            onCreateBtnTap: () {
                          provider.setGroupCardState(GroupCardState.add);
                        }),
                      );
                    }
                  }
                }
              },
            ),
            if (provider.groupCardState != GroupCardState.disable)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provider.reset();
                      },
                    ),
                  ),
                  Expanded(
                    child: buildGroupCard(provider.groupCardState),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget buildGroupCard(GroupCardState state) {
    switch (state) {
      case GroupCardState.add:
        return DesktopAddGroup(
          onDoneTap: () {
            groupsProvider.reset();
          },
        );
      case GroupCardState.expanded:
        return DesktopGroupsDetail(
          onBackArrowTap: () {
            groupsProvider.reset();
          },
        );
      default:
        return SizedBox();
    }
  }
}

Function areListsEqual = const DeepCollectionEquality.unordered().equals;
