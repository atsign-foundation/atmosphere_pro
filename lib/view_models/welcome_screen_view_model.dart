import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class WelcomeScreenProvider extends BaseModel {
  WelcomeScreenProvider._();
  static WelcomeScreenProvider _instance = WelcomeScreenProvider._();
  factory WelcomeScreenProvider() => _instance;
  List<GroupContactsModel> selectedContacts = [];
  String updateContacts = 'update_contacts';
  String onboard = 'onboard';
  String selectGroupContacts = 'select_group_contacts';
  String autoAcceptToggle = 'toogle_auto_accept';
  bool isAutoAccept = false, isExpanded = false, scrollToBottom = false;
  bool hasSelectedContactsChanged = false, authenticating = false;
  bool isSelectionItemChanged = false;
  String? groupName;
  int selectedBottomNavigationIndex = 0;

  void resetData() {
    selectedContacts = [];
    setStatus(updateContacts, Status.Done);
  }

  void changeBottomNavigationIndex(int index){
    selectedBottomNavigationIndex = index;
    notifyListeners();
  }

  void _addtoContactsList(GroupContactsModel _obj) {
    if (selectedContacts.indexWhere(
            (element) => element.contact!.atSign == _obj.contact!.atSign) ==
        -1) {
      selectedContacts.add(_obj);
    }
  }

  updateSelectedContacts(List<GroupContactsModel?> updatedList,
      {bool notifyListeners = true}) {
    try {
      groupName = null;
      selectedContacts = [];
      if (notifyListeners) {
        setStatus(updateContacts, Status.Loading);
      }

      for (var _obj in updatedList) {
        if (_obj?.contact != null) {
          _addtoContactsList(_obj!);
        } else if (_obj!.group != null) {
          groupName = _obj.group!.groupName;

          /// add groups as contacts
          /// this helps to remove contacts as well
          _obj.group!.members?.forEach((element) {
            _addtoContactsList(GroupContactsModel(contact: element));
          });
        }
      }

      hasSelectedContactsChanged = true;
      scrollToBottom = true; // to scroll welcome screen to the bottom
      if (notifyListeners) {
        setStatus(updateContacts, Status.Done);
      }
    } catch (error) {
      if (notifyListeners) {
        setError(updateContacts, error.toString());
      }
    }
  }

  addContacts(GroupContactsModel contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      selectedContacts.add(contact);
      hasSelectedContactsChanged = true;
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  removeContacts(GroupContactsModel? contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      selectedContacts.remove(contact);
      hasSelectedContactsChanged = true;

      // when contacts is being modifed we reset group name
      groupName = null;
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  onboardingLoad({String? atSign}) {
    try {
      authenticating = true;
      setStatus(onboard, Status.Loading);
      BackendService.getInstance().checkToOnboard(atSign: atSign);
      authenticating = false;
      setStatus(onboard, Status.Done);
    } catch (error) {
      authenticating = false;
      setError(onboard, error.toString());
    }
  }

  void resetSelectedContactsStatus() {
    hasSelectedContactsChanged = false;
  }
}
