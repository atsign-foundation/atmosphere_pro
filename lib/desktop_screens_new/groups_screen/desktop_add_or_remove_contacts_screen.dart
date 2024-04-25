import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_contacts_list.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopAddOrRemoveContactsScreen extends StatefulWidget {
  const DesktopAddOrRemoveContactsScreen();

  @override
  State<DesktopAddOrRemoveContactsScreen> createState() =>
      _DesktopAddOrRemoveContactsScreenState();
}

class _DesktopAddOrRemoveContactsScreenState
    extends State<DesktopAddOrRemoveContactsScreen> {
  final _groupService = GroupService();
  late DesktopGroupsScreenProvider _groupsProvider =
      context.read<DesktopGroupsScreenProvider>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _groupService.fetchGroupsAndContacts(isDesktop: true);

      _groupService.selectedGroupContacts =
          _groupsProvider.selectedAtGroup?.members
                  ?.map(
                    (e) => GroupContactsModel(
                      contact: e,
                      contactType: ContactsType.CONTACT,
                    ),
                  )
                  .toList() ??
              [];
      _groupService.selectedContactsSink
          .add(_groupService.selectedGroupContacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 572,
            child: buildHalfLeftWidget(),
          ),
          Expanded(
            flex: 441,
            child: buildHalfRightWidget(),
          ),
        ],
      ),
    );
  }

  Widget buildHalfLeftWidget() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.background,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(47),
        ),
      ),
      child: ListView(
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: buildAppbar(),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: DesktopGroupContactsList(
              asSelectionScreen: true,
              initialData: _groupsProvider.selectedAtGroup?.members
                  ?.map(
                    (e) => GroupContactsModel(
                      contact: e,
                      contactType: ContactsType.CONTACT,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppbar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            await DesktopSetupRoutes.nested_push(
              DesktopRoutes.DESKTOP_GROUP,
            );
          },
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: SvgPicture.asset(
                AppVectors.icBack,
                width: 8,
                height: 16,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 28),
        Text(
          'Add or Remove Contacts',
          style: CustomTextStyles.blackW50020,
        )
      ],
    );
  }

  Widget buildHalfRightWidget() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(56, 40, 24, 0),
          children: [
            Text(
              _groupsProvider.selectedGroupName ?? '',
              style: CustomTextStyles.blackW50020,
            ),
            SizedBox(height: 28),
            DesktopCoverImagePicker(
              selectedImage: _groupsProvider.selectedGroupImage,
              isEdit: false,
            ),
            SizedBox(height: 52),
            StreamBuilder<List<GroupContactsModel?>>(
              stream: _groupService.selectedContactsStream,
              initialData: _groupsProvider.selectedAtGroup?.members
                  ?.map(
                    (e) => GroupContactsModel(
                      contact: e,
                      contactType: ContactsType.CONTACT,
                    ),
                  )
                  .toList(),
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        '${snapshot.data?.length} ${(snapshot.data?.length ?? 0) > 1 ? 'Members' : 'Member'}',
                        style: CustomTextStyles.raisinBlackW50015,
                      ),
                    ),
                    const SizedBox(height: 28),
                    DesktopGroupContactsList(
                      showMembersOnly: true,
                      asSelectionScreen: false,
                      initialData: snapshot.data,
                      showSelectedBorder: false,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(56, 16, 24, 52),
            child: InkWell(
              onTap: () async {
                await updateMembers(context);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ColorConstants.orange,
                  borderRadius: BorderRadius.circular(135),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Update Group',
                        style: CustomTextStyles.whiteBold16,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> updateMembers(BuildContext context) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    if (_groupService.selectedGroupContacts.isEmpty) {
      await showMyDialog(context, _groupsProvider.selectedAtGroup!);
    } else {
      AtGroup group = _groupsProvider.selectedAtGroup!;
      group.members = _groupService.selectedGroupContacts
          .where((e) =>
              e!.contactType == ContactsType.CONTACT && e.contact != null)
          .map((e) => e!.contact!)
          .toSet();
      final result = await GroupService().updateGroup(group);
      if (result is AtGroup) {
        _groupService.selectedGroupContacts = [];
        await _groupsProvider.setSelectedAtGroup(result);
        await _groupService.fetchGroupsAndContacts(isDesktop: true);
        await DesktopSetupRoutes.nested_push(
          DesktopRoutes.DESKTOP_GROUP,
        );
      } else if (result != null) {
        if (result.runtimeType == AlreadyExistsException) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(TextConstants().GROUP_ALREADY_EXISTS)));
        } else if (result.runtimeType == InvalidAtSignException) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result.content)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> showMyDialog(BuildContext context, AtGroup group) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Uint8List? groupPicture;
        if (group.groupPicture != null) {
          List<int> intList = group.groupPicture.cast<int>();
          groupPicture = Uint8List.fromList(intList);
        }
        return ConfirmationDialog(
          title: '${group.displayName}',
          heading: 'Are you sure you want to delete this group?',
          onYesPressed: () async {
            var result = await GroupService().deleteGroup(group);

            if (!mounted) return;
            if (result != null && result) {
              Navigator.pop(context);
              await _groupsProvider.setSelectedAtGroup(null);
              _groupsProvider.setGroupCardState(GroupCardState.disable);
              await DesktopSetupRoutes.nested_push(
                DesktopRoutes.DESKTOP_GROUP,
              );
            } else {
              CustomToast().show(TextConstants().SERVICE_ERROR, context);
            }
          },
          image: groupPicture,
        );
      },
    );
  }
}
