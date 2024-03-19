import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_toast.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupsProvider extends ChangeNotifier {
  AtGroup? atGroup;
  bool showEditOptions = false;
  bool isEditingName = false;
  bool isEditingImage = false;
  dynamic groupPicture;
  Set<AtContact> members = {};
  bool isLoading = false;
  bool needRefresh = false;
  bool showTrustedMembers = false;
  String searchKeyword = '';

  Future<void> init(AtGroup data) async {
    atGroup = data;
    members = atGroup?.members ?? {};
    if (atGroup?.groupPicture != null) {
      await setGroupPicture(
        Uint8List.fromList(atGroup?.groupPicture.cast<int>()),
      );
    }
    notifyListeners();
  }

  void reset() {
    showEditOptions = false;
    isEditingName = false;
    isEditingImage = false;
    groupPicture = null;
    members.clear();
    atGroup = null;
    isLoading = false;
    needRefresh = false;
    notifyListeners();
  }

  void resetManageMembers() {
    showTrustedMembers = false;
    searchKeyword = '';
    notifyListeners();
  }

  void setShowEditOptions() {
    showEditOptions = !showEditOptions;
    notifyListeners();
  }

  void setIsEditingName() {
    isEditingName = !isEditingName;
    notifyListeners();
  }

  void setIsEditingImage() {
    isEditingImage = !isEditingImage;
    notifyListeners();
  }

  Future<void> setGroupPicture(Uint8List? data) async {
    if (data != null) {
      await AppUtils.checkGroupImageSize(
        image: data,
        onSatisfy: (value) {
          groupPicture = value;
        },
      );
    } else {
      groupPicture = null;
    }
    notifyListeners();
  }

  Future<void> updateGroupName(
    BuildContext context, {
    required String name,
  }) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(TextConstants().EMPTY_NAME)));
    } else {
      AtGroup group = atGroup!;
      group.groupName = name.trim();
      group.displayName = name.trim();
      final result = await GroupService().updateGroup(group);
      if (result is AtGroup) {
        atGroup = result;

        isEditingName = false;
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
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateGroupPicture(BuildContext context) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    AtGroup group = atGroup!;
    group.groupPicture = groupPicture;

    final result = await GroupService().updateGroup(group);
    if (result is AtGroup) {
      atGroup = result;
      isEditingImage = false;
      if (!needRefresh) {
        needRefresh = true;
      }
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateMembers(BuildContext context) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    if (members.isEmpty) {
      await showDeleteConfirmDialog(context);
    } else {
      AtGroup group = atGroup!;
      group.members = members;
      final result = await GroupService().updateGroup(group);
      if (result is AtGroup) {
        atGroup = result;
        resetManageMembers();
        Navigator.pop(context);
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
    isLoading = false;
    notifyListeners();
  }

  void addOrRemoveMember(AtContact member) {
    final membersList = members;
    if (membersList.any((element) => element.atSign == member.atSign)) {
      print('remove');
      membersList.removeWhere(
        (element) => element.atSign == member.atSign,
      );
      print(membersList);
    } else {
      print('add');
      membersList.add(member);
    }
    setMembers(membersList);
  }

  void setMembers(Set<AtContact> data) {
    members = data;
    notifyListeners();
  }

  void setShowTrustedMembersStatus() {
    showTrustedMembers = !showTrustedMembers;
    notifyListeners();
  }

  void changeSearchKeyword(String text) {
    searchKeyword = text;
    notifyListeners();
  }

  Future<void> showDeleteConfirmDialog(BuildContext context) async {
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
                'Are you sure you want to delete ${atGroup?.groupName ?? ''}?',
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
                      onTap: () async {
                        final result =
                            await GroupService().deleteGroup(atGroup!);
                        if (result != null && result) {
                          reset();
                          resetManageMembers();
                          await GroupService().fetchGroupsAndContacts();
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName(Routes.WELCOME_SCREEN),
                          );
                        } else {
                          CustomToast().show(
                            TextConstants().SERVICE_ERROR,
                            context,
                          );
                        }
                      },
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
