import 'dart:async';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  List<AtContact> contactList = [];
  List<AtContact> blockContactList = [];
  String selectedAtsign = '';
  ContactProvider() {
    initContactImpl();
  }
  // static ContactProvider _instance = ContactProvider._();
  Completer completer;

  initContactImpl() async {
    try {
      print("callled here");
      setStatus(Contacts, Status.Loading);
      completer = Completer();
      atContact = await AtContactsImpl.getInstance('@alice🛠');
      completer.complete(true);
    } catch (e) {
      print("error =>  $e");
    }
  }

  // factory ContactProvider() => _instance;

  String Contacts = 'contacts';
  List<Map<String, dynamic>> contacts = [];
  static AtContactsImpl atContact;

  getContacts() async {
    try {
      setStatus(Contacts, Status.Loading);
      contactList = [];
      await completer.future;
      contactList = await atContact.listContacts();
      List<AtContact> tempContactList = [...contactList];
      print("list =>  $contactList");
      int range = contactList.length;

      for (int i = 0; i < range; i++) {
        print("is blocked => ${contactList[i].blocked}");
        if (contactList[i].blocked) {
          print("herererr");
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort(
          (a, b) => a.atSign.substring(1).compareTo(b.atSign.substring(1)));
      print("list =>  $contactList");
      setStatus(Contacts, Status.Done);
    } catch (e) {
      print("error here => $e");
      setStatus(Contacts, Status.Error);
    }
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
      await atContact.update(contact);
      if (blockAction == true) {
        getContacts();
      } else {
        fetchBlockContactList();
      }
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }

  fetchBlockContactList() async {
    try {
      setStatus(Contacts, Status.Loading);
      blockContactList = await atContact.listBlockedContacts();
      print("block contact list => $blockContactList");
      setStatus(Contacts, Status.Done);
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }

  deleteAtsignContact({String atSign}) async {
    try {
      setStatus(Contacts, Status.Loading);
      var result = await atContact.delete('$atSign');
      print("delete result => $result");
      getContacts();
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
      getContacts();
    } catch (e) {
      setStatus(Contacts, Status.Error);
    }
  }
}
