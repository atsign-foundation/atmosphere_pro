import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class AddContactProvider extends BaseModel {
  String addContactStatus = 'add_contact_status';
  ContactService contactService = ContactService();
  bool isVerify = false;
  String atSignError = '';

  void initData() {
    contactService.resetData();
    isVerify = false;
    atSignError = '';
  }

  void changeVerifyStatus(bool verify) {
    if (verify) atSignError = '';
    isVerify = verify;
    notifyListeners();
  }

  Future<bool?> addContact({
    required String atSign,
    required String nickname,
  }) async {
    setStatus(addContactStatus, Status.Loading);
    try {
      await Future.delayed(Duration(seconds: 2));
      var response = await contactService.addAtSign(
        atSign: atSign,
        nickName: nickname,
      );

      if (response && (contactService.checkAtSign ?? false)) {
        setStatus(addContactStatus, Status.Done);
        return true;
      } else {
        atSignError = contactService.getAtSignError;
        setStatus(addContactStatus, Status.Done);
      }
    } catch (e) {
      setStatus(addContactStatus, Status.Error);
    }
    return null;
  }
}
