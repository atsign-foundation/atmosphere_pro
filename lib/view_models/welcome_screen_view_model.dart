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
  bool isShowOverlay = true;

  void resetData() {
    selectedContacts = [];
    setStatus(updateContacts, Status.Done);
  }

  void changeBottomNavigationIndex(int index) {
    selectedBottomNavigationIndex = index;
    notifyListeners();
  }

  void _addToContactsList(GroupContactsModel _obj) {
    selectedContacts.add(_obj);
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
        _addToContactsList(_obj!);
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

  void changeOverlayStatus(bool overlayStatus) {
    isShowOverlay = overlayStatus;
    notifyListeners();
  }

  void resetSelectedContactsStatus() {
    hasSelectedContactsChanged = false;
  }
}
