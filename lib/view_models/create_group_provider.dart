import 'dart:io';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupProvider extends BaseModel {
  bool isLoading = false;
  Uint8List? selectedImageByteData;
  List<AtContact> listContact = [];
  GroupService groupService = GroupService();
  String groupName = '';
  String searchKeyword = '';

  Future<void> selectCoverImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      selectedImageByteData = await File(image.path).readAsBytes();
      notifyListeners();
    }
  }

  void resetData() {
    listContact = [];
    notifyListeners();
  }

  void removeSelectedImage() {
    selectedImageByteData = null;
  }

  void setGroupName(String name) {
    groupName = name;
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    notifyListeners();
  }

  void addGroupContacts(List<GroupContactsModel> list) {
    listContact = [];
    for (var element in list) {
      listContact.add(element.contact!);
    }
    notifyListeners();
  }

  Future<void> createGroup({
    required Function(dynamic) whenComplete,
    required Function() whenNameIsEmpty,
  }) async {
    if (groupName.isNotEmpty) {
      isLoading = true;
      notifyListeners();

      var group = AtGroup(
        groupName.trim(),
        description: 'group desc',
        displayName: groupName.trim(),
        members: Set.from(listContact),
        createdBy: groupService.currentAtsign,
        updatedBy: groupService.currentAtsign,
      );

      if (selectedImageByteData != null) {
        group.groupPicture = selectedImageByteData;
      }

      var result = await groupService.createGroup(group);

      isLoading = false;
      notifyListeners();

      whenComplete(result);
    } else {
      whenNameIsEmpty;
    }
  }
}
