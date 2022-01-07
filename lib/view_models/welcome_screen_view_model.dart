import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
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
  HiveService _hiveService = HiveService();
  bool isAutoAccept = false,
      isExpanded = false,
      isSelectionItemChanged = false,
      _showSwitchAtsignMenu = false;

  bool get showSwitchAtsignMenu => _showSwitchAtsignMenu;

  updateSwitchAtsignMenu() {
    _showSwitchAtsignMenu = !_showSwitchAtsignMenu;
    notifyListeners();
  }

  updateSelectedContacts(List<GroupContactsModel> updatedList) {
    try {
      setStatus(updateContacts, Status.Loading);
      selectedContacts = updatedList;
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  addContacts(GroupContactsModel contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      selectedContacts.add(contact);
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  removeContacts(GroupContactsModel contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      selectedContacts.remove(contact);
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  bool authenticating = false;
  onboardingLoad({String atSign}) {
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

  toggleAutoAccept(bool toggle) async {
    try {
      setStatus(autoAcceptToggle, Status.Loading);
      await _hiveService.writeData(MixedConstants.AUTO_ACCEPT_TOGGLE_BOX,
          MixedConstants.AUTO_ACCEPT_TOGGLE_KEY, toggle);

      setStatus(autoAcceptToggle, Status.Done);
    } catch (e) {
      setError(autoAcceptToggle, e);
    }
  }

  getToggleStatus() async {
    try {
      setStatus(autoAcceptToggle, Status.Loading);
      isAutoAccept = await _hiveService.readData(
        MixedConstants.AUTO_ACCEPT_TOGGLE_BOX,
        MixedConstants.AUTO_ACCEPT_TOGGLE_KEY,
      );
      if (isAutoAccept == null) {
        toggleAutoAccept(false);
      }
      isAutoAccept = await _hiveService.readData(
        MixedConstants.AUTO_ACCEPT_TOGGLE_BOX,
        MixedConstants.AUTO_ACCEPT_TOGGLE_KEY,
      );
      BackendService.getInstance().autoAcceptFiles = isAutoAccept;
      setStatus(autoAcceptToggle, Status.Done);
    } catch (e) {
      setError(autoAcceptToggle, e);
    }
  }
}
