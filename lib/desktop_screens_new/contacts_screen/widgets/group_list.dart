import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_empty_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/error_screen.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class GroupList extends StatefulWidget {
  final Function() onBack;

  const GroupList({required this.onBack});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  bool shouldUpdate = false;
  List<AtGroup>? previousData;
  late DesktopGroupsScreenProvider groupsProvider;

  @override
  void initState() {
    groupsProvider = context.read<DesktopGroupsScreenProvider>();
    super.initState();
    GroupService().getAllGroupsDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24),
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConstants.boxGrey,
      ),
      child: Column(
        children: [
          header(),
          SizedBox(height: 12),
          Expanded(
            child: Consumer<DesktopGroupsScreenProvider>(
                builder: (context, provider, child) {
              return StreamBuilder(
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
                              DesktopSetupRoutes.nested_push(
                                  DesktopRoutes.DESKTOP_GROUP);
                            }),
                          );
                        } else {
                          return ListView.separated(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              itemBuilder: (context, index) {
                                return buildGroupItemList(
                                  data: snapshot.data![index],
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 12);
                              },
                              itemCount: snapshot.data!.length);
                        }
                      } else {
                        return Center(
                          child: DesktopEmptyGroup(
                            provider.groupCardState == GroupCardState.add,
                            onCreateBtnTap: () {
                              provider.setGroupCardState(GroupCardState.add);
                            },
                          ),
                        );
                      }
                    }
                  }
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Groups',
            style: CustomTextStyles.darkSliverWW50015,
          ),
          InkWell(
            onTap: widget.onBack,
            child: SvgPicture.asset(
              AppVectors.icArrow,
              color: ColorConstants.darkSliver,
              width: 20,
              height: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget buildGroupItemList({
    required AtGroup data,
  }) {
    return InkWell(
      onTap: () {
        groupsProvider.setSelectedAtGroup(data);
        groupsProvider.setGroupCardState(GroupCardState.expanded);
        DesktopSetupRoutes.nested_push(DesktopRoutes.DESKTOP_GROUP);
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      height: 72,
                    )
                  : ContactInitial(
                      size: 72,
                      borderRadius: 0,
                      initials: ((data.displayName ?? '').isNotEmpty &&
                              RegExp(r'^[a-z]+$').hasMatch(
                                  (data.displayName ?? '')[0].toLowerCase()))
                          ? data.displayName!
                          : 'UG',
                    ),
            ),
            SizedBox(width: 16),
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
      ),
    );
  }
}

Function areListsEqual = const DeepCollectionEquality.unordered().equals;
