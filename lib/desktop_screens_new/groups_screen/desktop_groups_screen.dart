import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_empty_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/error_screen.dart';
import 'package:at_utils/at_logger.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_add_group.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_groups_detail.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_groups_list.dart';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class DesktopGroupsScreen extends StatefulWidget {
  final bool showBackButton;

  const DesktopGroupsScreen({Key? key, this.showBackButton = true})
      : super(key: key);

  @override
  State<DesktopGroupsScreen> createState() => _DesktopGroupsScreenState();
}

class _DesktopGroupsScreenState extends State<DesktopGroupsScreen> {
  bool createBtnTapped = false;
  List<AtContact?> selectedContactList = [];
  bool shouldUpdate = false;
  List<AtGroup>? previousData;

  AtSignLogger atSignLogger = AtSignLogger('DesktopGroupInitialScreen');

  @override
  void initState() {
    try {
      super.initState();
      GroupService().groupPreferece.showBackButton = widget.showBackButton;
      GroupService().getAllGroupsDetails();
    } catch (e) {
      atSignLogger.severe('Error in init of Group_list $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F8F8),
      child: StreamBuilder(
        stream: GroupService().atGroupStream,
        builder: (BuildContext context, AsyncSnapshot<List<AtGroup>> snapshot) {
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
                  return createBtnTapped
                      ? NestedNavigators(
                          snapshot.data!,
                          () {
                            setState(() {
                              createBtnTapped = false;
                            });
                          },
                          shouldUpdate: shouldUpdate,
                          key: UniqueKey(),
                          expandIndex: 0,
                        )
                      : DesktopEmptyGroup(createBtnTapped, onCreateBtnTap: () {
                          setState(() {
                            createBtnTapped = true;
                          });
                        });
                } else {
                  return NestedNavigators(
                    snapshot.data!,
                    () {
                      setState(() {
                        createBtnTapped = false;
                      });
                    },
                    shouldUpdate: shouldUpdate,
                    key: UniqueKey(),
                    expandIndex: GroupService().expandIndex ?? 0,
                  );
                }
              } else {
                return DesktopEmptyGroup(createBtnTapped, onCreateBtnTap: () {
                  setState(() {
                    createBtnTapped = true;
                  });
                });
              }
            }
          }
        },
      ),
    );
  }
}

class NestedNavigators extends StatefulWidget {
  final List<AtGroup> data;
  final Function initialRouteOnArrowBackTap;
  final bool shouldUpdate;
  final int expandIndex;

  const NestedNavigators(this.data, this.initialRouteOnArrowBackTap,
      {Key? key, this.shouldUpdate = false, required this.expandIndex})
      : super(key: key);

  @override
  _NestedNavigatorsState createState() => _NestedNavigatorsState();
}

class _NestedNavigatorsState extends State<NestedNavigators> {
  GroupCardState groupCardState = GroupCardState.disable;
  AtGroup? selectedAtGroup;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.data.isEmpty
            ? const DesktopEmptyGroup(true)
            : DesktopGroupsList(
                widget.data,
                key: UniqueKey(),
                expandIndex: widget.expandIndex,
                onExpand: (value) {
                  setState(() {
                    selectedAtGroup = value;
                    groupCardState = GroupCardState.expanded;
                  });
                },
                onAdd: () {
                  setState(() {
                    groupCardState = GroupCardState.add;
                  });
                },
              ),
        if (groupCardState != GroupCardState.disable)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      groupCardState = GroupCardState.disable;
                    });
                  },
                ),
              ),
              Expanded(
                child: buildGroupCard(),
              ),
            ],
          )
      ],
    );
  }

  Widget buildGroupCard() {
    switch (groupCardState) {
      case GroupCardState.add:
        return DesktopAddGroup(
          asSelectionScreen: true,
          singleSelection: false,
          showGroups: false,
          showContacts: true,
          selectedList: (selectedContactList) {
            GroupService().setSelectedContacts(
                selectedContactList.map((e) => e?.contact).toList());
          },
          onDoneTap: () {
            setState(() {
              groupCardState = GroupCardState.disable;
            });
          },
        );
      case GroupCardState.expanded:
        return DesktopGroupsDetail(
          group: selectedAtGroup!,
          onBackArrowTap: () {
            setState(() {
              groupCardState = GroupCardState.disable;
            });
          },
        );
      default:
        return SizedBox();
    }
  }
}

Function areListsEqual = const DeepCollectionEquality.unordered().equals;
