import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  List<AtContact> contactList;
  List<AtContact> blockContactList;
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
    contactList = await atContact.listContacts();
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

  blockUnBLockContact({String atSign, bool blockAction}) async {
    try {
      setStatus(Contacts, Status.Loading);
      if (atSign[0] != '@') {
        atSign = '@' + atSign;
      }
      AtContact contact = AtContact(
        atSign: atSign,
        personas: ['persona1', 'persona22', 'persona33'],
      );

      contact.type = ContactType.Institute;
      contact.blocked = blockAction;
      var updateResult = await atContact.update(contact);
      setStatus(Contacts, Status.Error);
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }

  fetchBlockList() async {
    try {
      setStatus(Contacts, Status.Loading);
      blockContactList = await atContact.listBlockedContacts();
      setStatus(Contacts, Status.Done);
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }

  addContact({String atSign}) async {
    try {
      setStatus(Contacts, Status.Loading);
      if (atSign[0] != '@') {
        atSign = '@' + atSign;
      }
      AtContact contact = AtContact(
        atSign: atSign,
        personas: ['persona1', 'persona22', 'persona33'],
      );
      var result = await atContact.add(contact);
      print('create result : ${result}');
      setStatus(Contacts, Status.Error);
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }
}
