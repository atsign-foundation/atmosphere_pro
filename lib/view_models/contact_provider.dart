import 'dart:async';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  List<AtContact> contactList = [];
  List<AtContact> blockContactList = [];
  List<String> allContactsList = [];
  String selectedAtsign;
  BackendService backendService = BackendService.getInstance();
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
      atContact =
          await AtContactsImpl.getInstance(backendService.currentAtsign);
      completer.complete(true);
      setStatus(Contacts, Status.Done);
    } catch (error) {
      print("error =>  $error");
      setError(Contacts, error.toString());
    }
  }

  // factory ContactProvider() => _instance;

  String Contacts = 'contacts';
  List<Map<String, dynamic>> contacts = [];
  static AtContactsImpl atContact;

  Future getContacts() async {
    Completer c = Completer();
    try {
      setStatus(Contacts, Status.Loading);
      contactList = [];
      allContactsList = [];
      await completer.future;
      contactList = await atContact.listContacts();
      List<AtContact> tempContactList = [...contactList];
      print("list =>  $contactList");
      int range = contactList.length;

      for (int i = 0; i < range; i++) {
        print("is blocked => ${contactList[i].blocked}");
        allContactsList.add(contactList[i].atSign);
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
      c.complete(true);
    } catch (e) {
      print("error here => $e");
      setStatus(Contacts, Status.Error);
      c.complete(true);
    }
    return c.future;
  }

  blockUnblockContact({String atSign, bool blockAction}) async {
    try {
      setStatus(Contacts, Status.Loading);
      if (atSign[0] != '@') {
        atSign = '@' + atSign;
      }
      AtContact contact = AtContact(
        atSign: atSign,
        // personas: ['persona1', 'persona22', 'persona33'],
      );

      // contact.type = ContactType.Institute;
      contact.blocked = blockAction;
      await atContact.update(contact);
      if (blockAction == true) {
        getContacts();
      } else {
        fetchBlockContactList();
      }
    } catch (error) {
      setError(Contacts, error.toString());
    }
  }

  fetchBlockContactList() async {
    try {
      setStatus(Contacts, Status.Loading);
      blockContactList = await atContact.listBlockedContacts();
      print("block contact list => $blockContactList");
      setStatus(Contacts, Status.Done);
    } catch (error) {
      setError(Contacts, error.toString());
    }
  }

  deleteAtsignContact({String atSign}) async {
    try {
      setStatus(Contacts, Status.Loading);
      var result = await atContact.delete('$atSign');
      print("delete result => $result");
      getContacts();
      setStatus(Contacts, Status.Done);
    } catch (error) {
      setError(Contacts, error.toString());
    }
  }

  Future addContact({String atSign}) async {
    Completer c = Completer();
    try {
      setStatus(Contacts, Status.Loading);
      if (atSign[0] != '@') {
        atSign = '@' + atSign;
      }
      AtContact contact = AtContact(
        atSign: atSign,
        // personas: ['persona1', 'persona22', 'persona33'],
      );
      var result = await atContact.add(contact);
      print('create result : ${result}');
      await getContacts();
      c.complete(true);
    } catch (e) {
      c.complete(true);
      setStatus(Contacts, Status.Error);
    }
    return c.future;
  }
}
