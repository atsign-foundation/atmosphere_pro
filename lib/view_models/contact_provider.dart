import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  ContactProvider._();
  static ContactProvider _instance = ContactProvider._();
  factory ContactProvider() => _instance;
  String Contacts = 'contacts';
  List<Map<String, dynamic>> contacts = [];

  getContacts() async {
    setStatus(Contacts, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      contacts = [];
      for (int i = 0; i < 10; i++) {
        contacts.add({
          'name': 'User $i',
        });
      }
    });
    setStatus(Contacts, Status.Done);
  }
}
