// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_custom_app_bar.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_contacts_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_name_text_field.dart';
import 'package:atsign_atmosphere_pro/services/picker_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DesktopGroupsDetail extends StatefulWidget {
  Function(bool) onBackArrowTap;

  DesktopGroupsDetail({
    Key? key,
    required this.onBackArrowTap,
  }) : super(key: key);

  @override
  _DesktopGroupsDetailState createState() => _DesktopGroupsDetailState();
}

class _DesktopGroupsDetailState extends State<DesktopGroupsDetail> {
  late TextEditingController groupNameController;
  late DesktopGroupsScreenProvider groupProvider;

  @override
  void initState() {
    groupProvider = context.read<DesktopGroupsScreenProvider>();
    groupNameController =
        TextEditingController(text: groupProvider.selectedGroupName);
    super.initState();
  }

  void resetGroupName() {
    groupNameController = TextEditingController(
        text: groupProvider.selectedAtGroup?.groupName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopGroupsScreenProvider>(
        builder: (context, provider, child) {
      if (provider.isAddingContacts) {
        GroupService().fetchGroupsAndContacts(isDesktop: true);
        if ((provider.selectedAtGroup?.members ?? {}).isNotEmpty) {
          for (var i in provider.selectedAtGroup?.members ?? {}) {
            GroupService().addGroupContact(
              GroupContactsModel(
                contact: i,
                contactType: ContactsType.CONTACT,
              ),
            );
          }
        }
      } else {
        GroupService().selectedGroupContacts.clear();
      }
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: DesktopCustomAppBar(
            showTitle: true,
            centerTitle: false,
            titleText: provider.isEditing
                ? 'Edit'
                : provider.selectedAtGroup?.displayName,
            titleTextStyle: CustomTextStyles.blackW50020,
            leadingIcon: InkWell(
              onTap: provider.isEditing
                  ? () async {
                      await provider.setIsEditing(false);
                      if (provider.isAddingContacts) {
                        provider.setIsAddingContact();
                      }
                      resetGroupName();
                    }
                  : () => widget.onBackArrowTap(false),
              child: SizedBox(
                height: 24,
                width: 24,
                child: Center(
                  child: SvgPicture.asset(
                    AppVectors.icBack,
                    width: 8,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            showLeadingIcon: true,
            showTrailingIcon: true,
            onTrailingIconPressed: provider.isEditing
                ? () async {
                    await updateGroup();
                  }
                : () {
                    groupProvider.setShowEditOptionsStatus();
                  },
            trailingIcon: provider.isEditing
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 52, vertical: 8),
                    margin: const EdgeInsets.only(right: 28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(46),
                      color: ColorConstants.orange,
                    ),
                    child: Text(
                      'Save',
                      style: CustomTextStyles.whiteW50015,
                    ),
                  )
                : SvgPicture.asset(
                    AppVectors.icOptions,
                    width: 16,
                    fit: BoxFit.fitWidth,
                    color: provider.showEditOptions
                        ? ColorConstants.orange
                        : Colors.black,
                  ),
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 132),
                children: [
                  if (provider.isEditing) ...[
                    DesktopGroupNameTextField(
                      groupNameController: groupNameController,
                      onChanged: (value) {
                        provider.setSelectedGroupName(value ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropTarget(
                    onDragDone: provider.isEditing
                        ? (details) async {
                            if (details.files.length > 1) {
                              SnackbarService().showSnackbar(
                                context,
                                TextStrings.dropOneFileWarning,
                                bgColor: ColorConstants.redAlert,
                              );
                            } else {
                              await provider.setSelectedGroupImage(
                                await File(details.files.first.path)
                                    .readAsBytes(),
                              );
                            }
                          }
                        : null,
                    child: DesktopCoverImagePicker(
                      selectedImage: provider.selectedGroupImage,
                      isEdit: provider.isEditing,
                      onPickImage: () async {
                        await PickerService.pickImage(
                          onPickedImage: (result) {
                            provider.setSelectedGroupImage(result);
                          },
                        );
                      },
                      onCancel: () {
                        provider.setSelectedGroupImage(Uint8List(0));
                      },
                    ),
                  ),
                  SizedBox(height: provider.isEditing ? 16 : 20),
                  if (!provider.isEditing) buildTransferFileButton(),
                  const SizedBox(height: 36),
                  provider.isEditing
                      ? SizedBox(height: 8)
                      : Center(
                          child: Text(
                            '${provider.selectedAtGroup?.members?.length} ${(provider.selectedAtGroup?.members?.length ?? 0) > 1 ? 'Members' : 'Member'}',
                            style: CustomTextStyles.raisinBlackW50015,
                          ),
                        ),
                  const SizedBox(height: 28),
                  DesktopGroupContactsList(
                    asSelectionScreen: false,
                    showMembersOnly: !provider.isEditing,
                    showSelectedBorder: provider.isEditing,
                    initialData: provider.isAddingContacts
                        ? []
                        : provider.selectedAtGroup?.members
                            ?.map((e) => GroupContactsModel(
                                  contact: e,
                                ))
                            .toList(),
                  ),
                ],
              ),
              if (!provider.isEditing)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 52),
                    child: buildEditMembers(),
                  ),
                ),
              if (provider.showEditOptions) ...[
                Positioned.fill(
                  child: InkWell(
                    onTap: () {
                      groupProvider.setShowEditOptionsStatus();
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 20,
                  right: 20,
                  child: buildEditOptionsDialog(),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget buildEditMembers() {
    return InkWell(
      onTap: () async {
        await DesktopSetupRoutes.nested_push(
          DesktopRoutes.DESKTOP_ADD_OR_REMOVE_CONTACTS,
        );
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: ColorConstants.editMembersButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Edit Members',
          style: CustomTextStyles.dimGrayW50015,
        ),
      ),
    );
  }

  Widget buildEditOptionsDialog() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              await groupProvider.setIsEditing(true);
              groupProvider.setShowEditOptionsStatus();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit Group',
                    style: CustomTextStyles.blackW40015,
                  ),
                  SizedBox(width: 12),
                  SvgPicture.asset(
                    AppVectors.icPencil,
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: 0,
            color: Colors.black,
            thickness: 1,
          ),
          InkWell(
            onTap: () async {
              groupProvider.setShowEditOptionsStatus();
              await showMyDialog(
                context,
                groupProvider.selectedAtGroup!,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Delete Group',
                    style: CustomTextStyles.blackW40015,
                  ),
                  SizedBox(width: 12),
                  SvgPicture.asset(
                    AppVectors.icDeleteGroup,
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTransferFileButton() {
    return InkWell(
      onTap: () async {
        Provider.of<FileTransferProvider>(context, listen: false)
            .selectedContacts = [
          GroupContactsModel(
            group: groupProvider.selectedAtGroup,
            contactType: ContactsType.GROUP,
          ),
        ];
        Provider.of<FileTransferProvider>(context, listen: false).notify();
        await DesktopSetupRoutes.nested_pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Transfer File",
                style: CustomTextStyles.whiteBold12,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  AppVectors.icSendGroup,
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              Navigator.of(context).pop();
              await groupProvider.setSelectedAtGroup(null);
              groupProvider.setGroupCardState(GroupCardState.disable);
            } else {
              CustomToast().show(TextConstants().SERVICE_ERROR, context);
            }
          },
          image: groupPicture,
        );
      },
    );
  }

  updateGroup() async {
    String groupName = groupNameController.text;
    Uint8List? groupImage = groupProvider.selectedGroupImage;
    // ignore: unnecessary_null_comparison
    if (groupName != null) {
      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        var group = AtGroup(
          groupName != groupProvider.selectedAtGroup?.displayName
              ? groupName
              : groupProvider.selectedAtGroup?.displayName,
          groupId: groupProvider.selectedAtGroup?.groupId,
          description: groupProvider.selectedAtGroup?.description,
          displayName: groupName != groupProvider.selectedAtGroup?.displayName
              ? groupName
              : groupProvider.selectedAtGroup?.displayName,
          groupPicture:
              groupImage != groupProvider.selectedAtGroup?.groupPicture &&
                      groupImage!.isNotEmpty
                  ? groupImage
                  : groupProvider.selectedAtGroup?.groupPicture,
          members: GroupService().selectedGroupContacts.isEmpty
              ? groupProvider.selectedAtGroup?.members
              : Set.from(GroupService()
                  .selectedGroupContacts
                  .map((element) => element?.contact)),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );
        var result = await GroupService().updateGroup(group);
        if (result is AtGroup) {
          if (mounted) {
            widget.onBackArrowTap.call(true);

            GroupService().selectedGroupContacts = [];
            GroupService()
                .selectedContactsSink
                .add(GroupService().selectedGroupContacts);
          }
        } else if (result != null) {
          if (mounted) {
            if (result.runtimeType == AlreadyExistsException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(TextConstants().GROUP_ALREADY_EXISTS)));
            } else if (result.runtimeType == InvalidAtSignException) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result.content)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(TextConstants().EMPTY_NAME)));
      }
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
    }
  }
}
