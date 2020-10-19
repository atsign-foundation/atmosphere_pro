import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class AddContactProvider extends BaseModel {
  AddContactProvider._();
  static AddContactProvider _instance = AddContactProvider._();
  factory AddContactProvider() => _instance;
  String AddContacts = 'addContacts';
  List<Map<String, dynamic>> addContacts = [];

  getAddContacts() async {
    setStatus(AddContacts, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      addContacts = [];
      for (int i = 0; i < 10; i++) {
        addContacts.add({
          'name': 'User $i',
        });
      }
    });
    setStatus(AddContacts, Status.Done);
  }
}
