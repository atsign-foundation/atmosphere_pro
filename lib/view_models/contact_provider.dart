import 'dart:async';
import 'dart:convert';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  List<AtContact> contactList = [];
  List<AtContact> blockContactList = [];
  List<AtContact> selectedContacts = [];
  List<AtContact> trustedContacts = [];
  List<AtContact> fetchedTrustedContact = [];
  List<String> allContactsList = [];
  List<String> trustedNames = [];

  String selectedAtsign;
  BackendService backendService = BackendService.getInstance();

  String Contacts = 'contacts';
  String AddContacts = 'add_contacts';
  String GetContacts = 'get_contacts';
  String DeleteContacts = 'delete_contacts';
  String BlockContacts = 'block_contacts';
  String SelectContact = 'select_contacts';
  String AddTrustedContacts = 'add_trusted_contacts';
  String GetTrustedContacts = 'get_trusted_contacts';
  bool limitReached = false;
  bool trustedContactOperation = false;

  ContactProvider() {
    initContactImpl();
  }
  // static ContactProvider _instance = ContactProvider._();
  Completer completer;

  initContactImpl() async {
    try {
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

  List<Map<String, dynamic>> contacts = [];
  static AtContactsImpl atContact;

  Future getContacts() async {
    Completer c = Completer();
    try {
      setStatus(GetContacts, Status.Loading);
      contactList = [];
      allContactsList = [];
      await completer.future;
      contactList = await atContact.listContacts();
      List<AtContact> tempContactList = [...contactList];

      int range = contactList.length;

      for (int i = 0; i < range; i++) {
        print("is blocked => ${contactList[i].blocked}");
        allContactsList.add(contactList[i].atSign);
        if (contactList[i].blocked) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort(
          (a, b) => a.atSign.substring(1).compareTo(b.atSign.substring(1)));

      setStatus(GetContacts, Status.Done);
      c.complete(true);
    } catch (e) {
      print("error here => $e");
      setStatus(GetContacts, Status.Error);
      c.complete(true);
    }
    return c.future;
  }

  blockUnblockContact({String atSign, bool blockAction}) async {
    try {
      setStatus(BlockContacts, Status.Loading);
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
        await getContacts();
      } else {
        fetchBlockContactList();
      }
    } catch (error) {
      setError(BlockContacts, error.toString());
    }
  }

  fetchBlockContactList() async {
    try {
      setStatus(BlockContacts, Status.Loading);
      blockContactList = await atContact.listBlockedContacts();
      print("block contact list => $blockContactList");
      setStatus(BlockContacts, Status.Done);
    } catch (error) {
      setError(BlockContacts, error.toString());
    }
  }

  deleteAtsignContact({String atSign}) async {
    try {
      setStatus(DeleteContacts, Status.Loading);
      var result = await atContact.delete(atSign);
      print("delete result => $result");
      await getContacts();
      setStatus(DeleteContacts, Status.Done);
    } catch (error) {
      setError(DeleteContacts, error.toString());
    }
  }

  bool isContactPresent = false;
  bool isLoading = false;
  String getAtSignError = '';
  bool checkAtSign;

  Future addContact({String atSign}) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;
      setError(AddContacts, '_error');
      isLoading = false;
      return true;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }
    Completer c = Completer();
    try {
      isContactPresent = false;
      isLoading = true;
      getAtSignError = '';
      AtContact contact = AtContact();
      setStatus(AddContacts, Status.Loading);

      checkAtSign = await backendService.checkAtsign(atSign);
      if (!checkAtSign) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
        setError(AddContacts, '_error');
        isLoading = false;
      } else {
        contactList.forEach((element) async {
          if (element.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            return true;
          }
          isLoading = false;
        });
      }
      if (!isContactPresent && checkAtSign) {
        var details = await backendService.getContactDetails(atSign);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );
        var result = await atContact
            .add(contact)
            .catchError((e) => print('error to add contact => $e'));
        print(result);
        isLoading = false;
        Navigator.pop(NavService.navKey.currentContext);
        await getContacts();
      }
      c.complete(true);
      isLoading = false;
      setStatus(AddContacts, Status.Done);
    } catch (e) {
      c.complete(true);
      setStatus(AddContacts, Status.Error);
    }
    return c.future;
  }

  selectContacts(AtContact contact) {
    setStatus(SelectContact, Status.Loading);
    try {
      if (selectedContacts.length <= 3) {
        selectedContacts.add(contact);
      } else {
        limitReached = true;
      }

      setStatus(SelectContact, Status.Done);
    } catch (error) {
      setError(SelectContact, error.toString());
    }
  }

  removeContacts(AtContact contact) {
    setStatus(SelectContact, Status.Loading);

    try {
      selectedContacts.remove(contact);
      if (selectedContacts.length <= 3) {
        limitReached = false;
      } else {
        limitReached = true;
      }
      setStatus(SelectContact, Status.Done);
    } catch (error) {
      setError(SelectContact, error.toString());
    }
  }

  addTrustedContacts(AtContact contact) async {
    setStatus(AddTrustedContacts, Status.Loading);

    try {
      // trustedContacts = [];
      // await getTrustedContact();
      if (!trustedContacts.contains(contact)) {
        trustedContacts.add(contact);
      }
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      setError(AddTrustedContacts, error.toString());
    }
  }

  removeTrustedContacts(AtContact contact) async {
    setStatus(AddTrustedContacts, Status.Loading);

    try {
      if (trustedContacts.contains(contact)) {
        trustedContacts.remove(contact);
      }

      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      setError(AddTrustedContacts, error.toString());
    }
  }

  setTrustedContact() async {
    trustedContactOperation = true;
    setStatus(AddTrustedContacts, Status.Loading);
    try {
      AtKey trustedContactsKey = AtKey()
        ..key = 'trustedContactsKey'
        ..metadata = Metadata();
      await AtClientManager.getInstance().atClient.put(
            trustedContactsKey,
            json.encode({"trustedContacts": trustedContacts}),
          );

      // getTrustedContact();
      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      trustedContactOperation = false;
      setError(AddTrustedContacts, error.toString());
    }
  }

  getTrustedContact() async {
    setStatus(GetTrustedContacts, Status.Loading);

    try {
      AtKey trustedContactsKey = AtKey()
        ..key = 'trustedContactsKey'
        ..metadata = Metadata();

      AtValue keyValue =
          await AtClientManager.getInstance().atClient.get(trustedContactsKey);

      var jsonValue;
      if (keyValue.value != null) {
        jsonValue = jsonDecode(keyValue.value);
        jsonValue['trustedContacts'].forEach((contact) {
          final c = AtContact.fromJson(contact);
          fetchedTrustedContact.add(c);
          trustedNames.add(c.atSign);
        });
      }

      trustedContacts = [];
      trustedContacts = fetchedTrustedContact;

      setStatus(GetTrustedContacts, Status.Done);
    } catch (error) {
      print('ERROR=====>$error');
      setError(GetTrustedContacts, error.toString());
    }
  }
}
