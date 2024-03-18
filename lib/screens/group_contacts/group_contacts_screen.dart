import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_edit_options_widget.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_manage_members_widget.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_member_list_view.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupContactsScreen extends StatefulWidget {
  final AtGroup group;

  const GroupContactsScreen({required this.group});

  @override
  State<GroupContactsScreen> createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  bool showEditOptions = false;
  bool isEditingName = false;
  bool isEditingImage = false;
  late TextEditingController groupNameController =
      TextEditingController(text: widget.group.groupName);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isEditingName,
      onPopInvoked: (didPop) {
        if (isEditingName) {
          groupNameController.text = widget.group.groupName ?? '';
          setState(() {
            isEditingName = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: GroupsAppBar(
          title: isEditingName ? 'Edit' : widget.group.groupName ?? '',
          onBack: () {
            if (isEditingName) {
              groupNameController.text = widget.group.groupName ?? '';
              setState(() {
                isEditingName = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          actions: [
            isEditingName || isEditingImage
                ? SvgPicture.asset(
                    AppVectors.icOptions,
                    width: 16,
                    fit: BoxFit.cover,
                    color: Colors.black,
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        showEditOptions = !showEditOptions;
                      });
                    },
                    child: SvgPicture.asset(
                      AppVectors.icPencil,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      color: showEditOptions
                          ? ColorConstants.orangeColor
                          : Colors.black,
                    ),
                  ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 20),
                  isEditingName
                      ? buildEditGroupNameWidget()
                      : CoverImagePicker(
                          showOptions: isEditingImage,
                          onTap: () {},
                          groupImage: widget.group.groupPicture,
                          height: 120,
                        ),
                  SizedBox(height: isEditingName || isEditingImage ? 24 : 12),
                  isEditingName || isEditingImage
                      ? GroupsCustomButton(
                          title: 'Save',
                          onTap: () {},
                          borderRadius: 5,
                        )
                      : GroupsCustomButton(
                          title: 'Transfer File',
                          suffix: SvgPicture.asset(
                            AppVectors.icTransfer,
                            width: 24,
                            height: 16,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {},
                          borderRadius: 7,
                        ),
                  Expanded(
                    child: GroupsMemberListView(
                      members: widget.group.members!,
                    ),
                  ),
                ],
              ),
              if (showEditOptions) ...[
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showEditOptions = false;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: GroupsEditOptionsWidget(
                    onEditName: () {
                      setState(() {
                        showEditOptions = false;
                        isEditingName = true;
                      });
                    },
                    onCoverImage: () {
                      setState(() {
                        showEditOptions = false;
                        isEditingImage = true;
                      });
                    },
                    onManageMembers: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupsManageMembersWidget(),
                        ),
                      );
                    },
                    onDelete: () async {
                      await showDeleteConfirmDialog();
                    },
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditGroupNameWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Group Name',
            style: CustomTextStyles.blackW5008,
          ),
          SizedBox(height: 4),
          TextField(
            maxLines: 1,
            style: CustomTextStyles.blackW50014,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 28,
                top: 16,
                bottom: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              suffix: InkWell(
                onTap: () {
                  groupNameController.clear();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SvgPicture.asset(
                    AppVectors.icCancel,
                    color: Colors.black,
                    height: 8,
                    width: 8,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            controller: groupNameController,
          )
        ],
      ),
    );
  }

  Future<void> showDeleteConfirmDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete',
                style: CustomTextStyles.blackBold(size: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to delete ${widget.group.groupName}?',
                style: CustomTextStyles.blackW40013,
                textAlign: TextAlign.center,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Note',
                      style: CustomTextStyles.blackItalicW40013,
                    ),
                    TextSpan(
                      text: ': this action cannot be undone.',
                      style: CustomTextStyles.blackW40013,
                    )
                  ],
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 36,
                        width: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          'Cancel',
                          style: CustomTextStyles.blackUnderlineW40012,
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 36,
                        width: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: ColorConstants.bottomBlack,
                        ),
                        child: Text(
                          'Move',
                          style: CustomTextStyles.whiteBold12,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
