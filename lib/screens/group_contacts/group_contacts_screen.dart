import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/cover_image_picker.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_edit_options_widget.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_manage_members_widget.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_member_list_view.dart';
import 'package:atsign_atmosphere_pro/services/picker_service.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/groups_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class GroupContactsScreen extends StatefulWidget {
  final AtGroup group;

  const GroupContactsScreen({required this.group});

  @override
  State<GroupContactsScreen> createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  late TextEditingController groupNameController =
      TextEditingController(text: _groupsProvider.atGroup?.groupName ?? '');
  late final _groupsProvider = context.read<GroupsProvider>();
  late final _welcomeProvider = context.read<WelcomeScreenProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _groupsProvider.init(widget.group);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_groupsProvider.isEditingName) {
          groupNameController.text = _groupsProvider.atGroup?.groupName ?? '';
          _groupsProvider.setIsEditingName();
        } else if (_groupsProvider.isEditingImage) {
          await _groupsProvider
              .setGroupPicture(_groupsProvider.atGroup?.groupPicture);
          _groupsProvider.setIsEditingImage();
        } else {
          Navigator.pop(
            context,
            _groupsProvider.needRefresh,
          );
          _groupsProvider.reset();
        }
      },
      child: Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: GroupsAppBar(
          title: context.watch<GroupsProvider>().isEditingName
              ? 'Edit'
              : _groupsProvider.atGroup?.groupName ?? '',
          onBack: () async {
            if (_groupsProvider.isEditingName) {
              groupNameController.text =
                  _groupsProvider.atGroup?.groupName ?? '';
              _groupsProvider.setIsEditingName();
            } else if (_groupsProvider.isEditingImage) {
              await _groupsProvider
                  .setGroupPicture(_groupsProvider.atGroup?.groupPicture);
              _groupsProvider.setIsEditingImage();
            } else {
              Navigator.pop(
                context,
                _groupsProvider.needRefresh,
              );
              _groupsProvider.reset();
            }
          },
          actions: [
            Selector<GroupsProvider, Tuple3<bool, bool, bool>>(
              builder: (context, value, child) {
                return value.item1 || value.item2
                    ? SvgPicture.asset(
                        AppVectors.icOptions,
                        width: 16,
                        fit: BoxFit.cover,
                        color: Colors.black,
                      )
                    : InkWell(
                        onTap: () {
                          _groupsProvider.setShowEditOptions();
                        },
                        child: SvgPicture.asset(
                          AppVectors.icPencil,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          color: value.item3
                              ? ColorConstants.orangeColor
                              : Colors.black,
                        ),
                      );
              },
              selector: (_, p) => Tuple3<bool, bool, bool>(
                p.isEditingName,
                p.isEditingImage,
                p.showEditOptions,
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
                  Selector<GroupsProvider, Tuple3<bool, bool, dynamic>>(
                    builder: (context, value, child) {
                      return value.item1
                          ? buildEditGroupNameWidget()
                          : CoverImagePicker(
                              showOptions: value.item2,
                              onTap: () async {
                                if (value.item2) {
                                  await PickerService.pickImage(
                                    onPickedImage: (result) async {
                                      if (result.isNotEmpty) {
                                        await AppUtils.checkGroupImageSize(
                                          image: result,
                                          onSatisfy: (value) {
                                            _groupsProvider
                                                .setGroupPicture(result);
                                          },
                                        );
                                      }
                                    },
                                  );
                                }
                              },
                              groupImage: value.item3,
                              height: 120,
                              onCancel: () async {
                                await _groupsProvider.setGroupPicture(null);
                              },
                            );
                    },
                    selector: (_, p) => Tuple3<bool, bool, dynamic>(
                      p.isEditingName,
                      p.isEditingImage,
                      p.groupPicture,
                    ),
                  ),
                  Selector<GroupsProvider, Tuple2<bool, bool>>(
                    builder: (context, value, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: value.item1 || value.item2 ? 24 : 12,
                          ),
                          value.item1 || value.item2
                              ? Selector<GroupsProvider,
                                  Tuple3<bool, bool, bool>>(
                                  builder: (context, value, child) {
                                    return GroupsCustomButton(
                                      title: 'Save',
                                      onTap: () async {
                                        if (value.item2) {
                                          await _groupsProvider.updateGroupName(
                                            context,
                                            name: groupNameController.text,
                                          );
                                          return;
                                        }
                                        if (value.item3) {
                                          await _groupsProvider
                                              .updateGroupPicture(context);
                                          return;
                                        }
                                      },
                                      borderRadius: 5,
                                      isLoading: value.item1,
                                    );
                                  },
                                  selector: (_, p) => Tuple3<bool, bool, bool>(
                                    p.isLoading,
                                    p.isEditingName,
                                    p.isEditingImage,
                                  ),
                                )
                              : GroupsCustomButton(
                                  title: 'Transfer File',
                                  suffix: SvgPicture.asset(
                                    AppVectors.icTransfer,
                                    width: 24,
                                    height: 16,
                                    fit: BoxFit.cover,
                                  ),
                                  onTap: () {
                                    _welcomeProvider.selectedContacts = [
                                      GroupContactsModel(
                                        group: _groupsProvider.atGroup,
                                        contactType: ContactsType.GROUP,
                                      ),
                                    ];
                                    Navigator.pop(
                                      context,
                                      _groupsProvider.needRefresh,
                                    );
                                    _welcomeProvider
                                        .changeBottomNavigationIndex(0);
                                  },
                                  borderRadius: 7,
                                ),
                        ],
                      );
                    },
                    selector: (_, p) => Tuple2<bool, bool>(
                      p.isEditingName,
                      p.isEditingImage,
                    ),
                  ),
                  Expanded(
                    child: Selector<GroupsProvider, Set<AtContact>>(
                      builder: (context, value, child) {
                        return GroupsMemberListView(
                          members: value,
                        );
                      },
                      selector: (_, p) => p.atGroup?.members ?? {},
                    ),
                  ),
                ],
              ),
              Selector<GroupsProvider, bool>(
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: InkWell(
                        onTap: () {
                          _groupsProvider.setShowEditOptions();
                        },
                      ),
                    ),
                  );
                },
                selector: (_, p) => p.showEditOptions,
              ),
              Selector<GroupsProvider, bool>(
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: Container(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: GroupsEditOptionsWidget(
                        onEditName: () {
                          _groupsProvider.setShowEditOptions();
                          _groupsProvider.setIsEditingName();
                        },
                        onCoverImage: () {
                          _groupsProvider.setShowEditOptions();
                          _groupsProvider.setIsEditingImage();
                        },
                        onManageMembers: () {
                          _groupsProvider.setShowEditOptions();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupsManageMembersWidget(),
                            ),
                          );
                        },
                        onDelete: () async {
                          await _groupsProvider
                              .showDeleteConfirmDialog(context);
                        },
                      ),
                    ),
                  );
                },
                selector: (_, p) => p.showEditOptions,
              )
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
}
