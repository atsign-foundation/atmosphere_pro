import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/group_card_state.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopGroupsScreenProvider extends ChangeNotifier {
  bool isSearching = false;
  GroupCardState groupCardState = GroupCardState.disable;
  AtGroup? selectedAtGroup;
  String searchGroupText = '';
  String searchContactText = '';
  bool showTrustedContacts = false;
  bool isEditing = false;
  bool isAddingContacts = false;
  Uint8List? selectedGroupImage;
  String? selectedGroupName;
  bool showEditOptions = false;

  void reset() {
    searchGroupText = '';
    searchContactText = '';
    showTrustedContacts = false;
    isEditing = false;
    isAddingContacts = false;
    groupCardState = GroupCardState.disable;
    showEditOptions = false;
    notifyListeners();
  }

  void setIsSearching(bool status) {
    isSearching = status;
    notifyListeners();
  }

  void setGroupCardState(GroupCardState state) {
    groupCardState = state;
    notifyListeners();
  }

  Future<void> setSelectedAtGroup(AtGroup? atGroup) async {
    selectedAtGroup = atGroup;
    setSelectedGroupName(selectedAtGroup?.groupName ?? '');
    if (selectedAtGroup?.groupPicture != null) {
      await setSelectedGroupImage(
        Uint8List.fromList(selectedAtGroup?.groupPicture.cast<int>()),
      );
    } else {
      await setSelectedGroupImage(Uint8List(0));
    }
    notifyListeners();
  }

  void setSearchGroupText(String text) {
    searchGroupText = text;
    notifyListeners();
  }

  void setSearchContactText(String text) {
    searchContactText = text;
    notifyListeners();
  }

  void setShowTrustedContacts() {
    showTrustedContacts = !showTrustedContacts;
    notifyListeners();
  }

  Future<void> setIsEditing(bool status) async {
    isEditing = status;
    if (selectedAtGroup?.groupPicture != null) {
      await setSelectedGroupImage(
          Uint8List.fromList(selectedAtGroup?.groupPicture.cast<int>()));
    } else {
      await setSelectedGroupImage(Uint8List(0));
    }
    notifyListeners();
  }

  void setIsAddingContact() {
    isAddingContacts = !isAddingContacts;
    notifyListeners();
  }

  Future<void> setSelectedGroupImage(Uint8List data) async {
    if (data.isNotEmpty) {
      await AppUtils.checkGroupImageSize(
        image: data,
        onSatisfy: (value) {
          selectedGroupImage = value;
        },
      );
    } else {
      selectedGroupImage = data;
    }
    notifyListeners();
  }

  void setSelectedGroupName(String name) {
    if (name.isNotEmpty) {
      selectedGroupName = name;
      notifyListeners();
    }
  }

  void setShowEditOptionsStatus() {
    showEditOptions = !showEditOptions;
    notifyListeners();
  }
}
