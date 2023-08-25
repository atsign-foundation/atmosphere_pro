// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_custom_app_bar.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_floating_add_contact_button.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_contacts_list.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/desktop_group_name_text_field.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/desktop_groups_screen_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DesktopGroupsDetail extends StatefulWidget {
  Function() onBackArrowTap;

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
                  ? () {
                      provider.setIsEditing(false);
                      if (provider.isAddingContacts) {
                        provider.setIsAddingContact();
                      }
                      resetGroupName();
                    }
                  : () => widget.onBackArrowTap(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SvgPicture.asset(
                  AppVectors.icBack,
                  width: 8,
                  height: 20,
                ),
              ),
            ),
            showLeadingIcon: true,
            showTrailingIcon: provider.isEditing,
            trailingIcon: InkWell(
              onTap: () async {
                await updateGroup();
              },
              child: Container(
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
              ),
            ),
          ),
          body: Stack(
            children: [
              ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  DesktopCoverImagePicker(
                    selectedImage: provider.selectedGroupImage,
                    isEdit: provider.isEditing,
                    onSelected: (value) {
                      provider.setSelectedGroupImage(value);
                    },
                    onCancel: () {
                      provider.setSelectedGroupImage(Uint8List(0));
                    },
                  ),
                  SizedBox(height: provider.isEditing ? 16 : 20),
                  buildDetailOptions(
                    isAddingContacts: provider.isAddingContacts,
                    isEditing: provider.isEditing,
                  ),
                  const SizedBox(height: 12),
                  DesktopGroupContactsList(
                    asSelectionScreen: provider.isAddingContacts,
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
              if (provider.isAddingContacts)
                const DesktopFloatingAddContactButton(),
            ],
          ),
        ),
      );
    });
  }

  Widget buildDetailOptions({
    required bool isEditing,
    required bool isAddingContacts,
  }) {
    return isEditing
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonWidget(
                icon: AppVectors.icDesktopAdd,
                isSelected: isAddingContacts,
                onTap: () {
                  groupProvider.setIsAddingContact();
                },
                backgroundColor: ColorConstants.iconButtonColor,
              ),
              const SizedBox(width: 20),
              IconButtonWidget(
                icon: AppVectors.icShare,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                onTap: () {},
                backgroundColor: ColorConstants.iconButtonColor,
              ),
              const SizedBox(width: 20),
              IconButtonWidget(
                icon: AppVectors.icDelete,
                onTap: () async {
                  await showMyDialog(
                    context,
                    groupProvider.selectedAtGroup!,
                  );
                },
                backgroundColor: ColorConstants.iconButtonColor,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  Provider.of<FileTransferProvider>(context, listen: false)
                      .selectedContacts = [
                    GroupContactsModel(
                      group: groupProvider.selectedAtGroup,
                      contactType: ContactsType.GROUP,
                    ),
                  ];
                  Provider.of<FileTransferProvider>(context, listen: false)
                      .notify();
                  await DesktopSetupRoutes.nested_pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
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
                        SvgPicture.asset(
                          AppVectors.icTransfer,
                          width: 16,
                          height: 12,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButtonWidget(
                    icon: AppVectors.icEdit,
                    backgroundColor: ColorConstants.iconButtonColor,
                    onTap: () => groupProvider.setIsEditing(true),
                  ),
                  const SizedBox(width: 24),
                  IconButtonWidget(
                    icon: AppVectors.icDelete,
                    backgroundColor: ColorConstants.iconButtonColor,
                    onTap: () async {
                      await showMyDialog(
                        context,
                        groupProvider.selectedAtGroup!,
                      );
                    },
                  ),
                ],
              ),
            ],
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
            widget.onBackArrowTap.call();

            GroupService().emptySelectedGroupContact();
          }
        } else if (result != null) {
          if (mounted) {
            if (result.runtimeType == AlreadyExistsException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(TextConstants().GROUP_ALREADY_EXISTS)));
            } else if (result.runtimeType == InvalidAtSignException) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result.message)));
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
