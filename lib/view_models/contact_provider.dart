import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  ContactProvider._() {
    {
      initContactImpl();
    }
  }
  static ContactProvider _instance = ContactProvider._();

  initContactImpl() async {
    atContact = await AtContactsImpl.getInstance('@alice🛠');
  }

  factory ContactProvider() => _instance;
  String Contacts = 'contacts';
  List<Map<String, dynamic>> contacts = [];
  AtContactsImpl atContact;

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

  addContact() async {
    AtContact contact = AtContact(
      atSign: '@bob🛠',
      personas: ['persona1', 'persona22', 'persona33'],
    );
    AtContactsImpl atContact = await AtContactsImpl.getInstance('@alice🛠');
    // var result = await atContact.add(contact);
    var result = await atContact.listContacts();
    print('create result : $result');
    ;
  }
}
