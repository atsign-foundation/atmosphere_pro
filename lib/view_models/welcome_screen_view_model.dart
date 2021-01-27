import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class WelcomeScreenProvider extends BaseModel {
  WelcomeScreenProvider._();
  static WelcomeScreenProvider _instance = WelcomeScreenProvider._();
  factory WelcomeScreenProvider() => _instance;
  List<AtContact> selectedContacts = [];
  String updateContacts = 'update_contacts';
  updateSelectedContacts(List<AtContact> updatedList) {
    try {
      setStatus(updateContacts, Status.Loading);
      // selectedContacts = [];

      selectedContacts = updatedList;
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  addContacts(AtContact contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      // selectedContacts = [];

      selectedContacts.add(contact);
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }

  removeContacts(AtContact contact) {
    try {
      setStatus(updateContacts, Status.Loading);
      // selectedContacts = [];

      selectedContacts.remove(contact);
      setStatus(updateContacts, Status.Done);
    } catch (error) {
      setError(updateContacts, error.toString());
    }
  }
}
