import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class TrustedContactProvider extends BaseModel {
  TrustedContactProvider._();
  static TrustedContactProvider _instance = TrustedContactProvider._();
  factory TrustedContactProvider() => _instance;
  String AddTrustedContacts = 'add_trusted_contacts';
  List<AtContact?> trustedContacts = [];
  var jsonValue;
  var flag;
  // List<AtContact?> new_trustedContacts = [];
  List<AtKey> new_trustedContactsKeys = [];
  List<AtKey> old_trustedContactsKeys = [];
  bool trustedContactOperation = false;
  List<String?> trustedNames = [];
  // List<String?> new_trustedNames = [];
  String GetTrustedContacts = 'get_trusted_contacts';
  String MigrateTrustedContacts = 'migrate_trusted_contacts';

  List<AtContact?> fetchedTrustedContact = [];
  // List<AtContact?> new_fetchedTrustedContact = [];
  BackendService backendService = BackendService.getInstance();

  addTrustedContacts(AtContact? trustedContact) async {
    trustedContactOperation = true;
    setStatus(AddTrustedContacts, Status.Loading);
    String at_sign_name = trustedContact!.atSign!.replaceAll("@", "");
    try {
      bool isAlreadyPresent = false;
      for (AtContact? contact in trustedContacts) {
        if (contact?.atSign.toString() == trustedContact.atSign.toString()) {
          isAlreadyPresent = true;
          break;
        }
      }
      if (!isAlreadyPresent) {
        AtKey trustedContactsKey = AtKey()
          ..key = 'trusted_contact_${at_sign_name}'
          ..metadata = Metadata();
        await AtClientManager.getInstance().atClient.put(
              trustedContactsKey,
              trustedContact.atSign,
            );
        trustedContacts.add(trustedContact);
      }

      AtContact selectedContact = AtContact(
          atSign: trustedContact.atSign); //checking if this actually works
      // print("the Contact formed using the at-sign is: ${selectedContact}");
      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      trustedContactOperation = false;
      setError(AddTrustedContacts, error.toString());
      setStatus(AddTrustedContacts, Status.Error);
    }
  }

  removeTrustedContacts(AtContact? trustedContact) async {
    setStatus(AddTrustedContacts, Status.Loading);
    trustedContactOperation = true;

    try {
      for (AtContact? contact in trustedContacts) {
        if (contact!.atSign == trustedContact!.atSign) {
          int index = trustedContacts.indexOf(contact);
          trustedContacts.removeAt(index);
          AtKey key = AtKey()
            ..key =
                'trusted_contact_${trustedContact.atSign!.replaceAll("@", "")}'
            ..metadata = Metadata();
          await AtClientManager.getInstance().atClient.delete(key);
          // print("THE KEY ${key} IS REMOVED FROM LOCAL");
          break;
        }
      }
      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      trustedContactOperation = false;
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
      // await AtClientManager.getInstance().atClient.put(
      //       trustedContactsKey,
      //       json.encode({"trustedContacts": trustedContacts}),
      //     );
      // print("trusted contacts in setTrustedContacts: ${trustedContacts}");
      AtValue old_trustedContactsKeys =
          await backendService.atClientInstance!.get(trustedContactsKey);
      //print(
      //"THE ARRAY old_trustedContactsKeys has: ${old_trustedContactsKeys.value['trustedContactsKey']}");
      jsonValue = jsonDecode(old_trustedContactsKeys.value);
      // print("IN setTrustedContacts!");
      // print(" the object is: ${jsonValue['trustedContacts']}");
      // print("CONTACTS IN trustedContacts ARRAY IS: ${trustedContacts}");
      // for (var i = 0; i < jsonValue['trustedContacts'].length; i++) {
      //   flag = true;
      //   for (var j = 0; j < trustedContacts.length && !flag; j++) {
      //     if (jsonValue['trustedContacts'][i]['atSign'] ==
      //         trustedContacts[j]!.atSign) {
      //       flag = false;
      //     } else {
      //       flag = true;
      //     }
      //   }
      //   if (flag == true) {
      //     AtKey new_trustedContactsKey = AtKey()
      //       ..key =
      //           'trusted_contact_${jsonValue['trustedContacts'][i]['atSign'].replaceAll("@", "")}'
      //       ..metadata = Metadata();
      //     await AtClientManager.getInstance().atClient.put(
      //           new_trustedContactsKey,
      //           jsonValue['trustedContacts'][i]['atSign'],
      //         );
      //     trustedContacts.add(
      //         AtContact(atSign: jsonValue['trustedContacts'][i]['atSign']));
      //     print(
      //         "MIGRATED ${jsonValue['trustedContacts'][i]['atSign']} to new format");
      //   }
      // }
      // print(
      //     "first value in old format: ${jsonValue['trustedContacts'][0]['atSign']}");
      // print("first value in new format: ${trustedContacts[0]!.atSign}");
      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      trustedContactOperation = false;
      setError(AddTrustedContacts, error.toString());
    }
  }

  migrateTrustedContact() async {
    setStatus(MigrateTrustedContacts, Status.Loading);
    print("INSIDE MIGRATION!!");
    try {
      AtKey trustedContactsKey = AtKey()
        ..key = 'trustedContactsKey'
        ..metadata = Metadata();
      AtValue old_trustedContactsKeys =
          await backendService.atClientInstance!.get(trustedContactsKey);
      jsonValue = jsonDecode(old_trustedContactsKeys.value);
      for (var i = 0; i < jsonValue['trustedContacts'].length; i++) {
        flag = true;
        var j = trustedContacts.indexWhere((element) =>
            element!.atSign == jsonValue['trustedContacts'][i]['atSign']);
        if (j == -1) {
          AtKey new_trustedContactsKey = AtKey()
            ..key =
                'trusted_contact_${jsonValue['trustedContacts'][i]['atSign'].replaceAll("@", "")}'
            ..metadata = Metadata();
          await AtClientManager.getInstance().atClient.put(
                new_trustedContactsKey,
                jsonValue['trustedContacts'][i]['atSign'],
              );
          trustedContacts.add(
              AtContact(atSign: jsonValue['trustedContacts'][i]['atSign']));
          jsonValue['trustedContacts'].removeAt(i);
        }
      }

      await AtClientManager.getInstance().atClient.put(
            trustedContactsKey,
            json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
          );
      print("AFTER MIGRATION: ${trustedContacts}");
      print("AFTER MIGRATION old array: ${jsonValue['trustedContacts']}");

      setStatus(MigrateTrustedContacts, Status.Done);
    } catch (e) {
      print('ERROR=====>$e');
      setError(MigrateTrustedContacts, e.toString());
    }
  }

  getTrustedContact() async {
    fetchedTrustedContact = [];
    setStatus(GetTrustedContacts, Status.Loading);

    new_trustedContactsKeys = await AtClientManager.getInstance()
        .atClient
        .getAtKeys(regex: 'trusted_contact_');
    try {
      for (var new_key in new_trustedContactsKeys) {
        AtValue keyValue =
            await backendService.atClientInstance!.get(new_key).catchError((e) {
          print('error in get in getTrustedContact : $e ');
          return AtValue();
        });
        // print("value in addTrustedContact key ${new_key}: ${keyValue}");
        //  new AtContact(atSign: keyValue.value);
        fetchedTrustedContact.add(AtContact(atSign: keyValue.value));
      }
      trustedContacts = [];
      trustedContacts = fetchedTrustedContact;
      print("trustedContacts in getTrustedContacts: ${trustedContacts}");
      setStatus(GetTrustedContacts, Status.Done);
    } catch (e) {
      print('ERROR=====>$e');
      setError(GetTrustedContacts, e.toString());
    }
  }
}
