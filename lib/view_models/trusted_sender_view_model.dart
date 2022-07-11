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
  List<AtKey> new_trustedContactsKeys = [];
  List<AtKey> old_trustedContactsKeys = [];
  bool trustedContactOperation = false;
  List<String?> trustedNames = [];
  String GetTrustedContacts = 'get_trusted_contacts';
  String MigrateTrustedContacts = 'migrate_trusted_contacts';

  List<AtContact?> fetchedTrustedContact = [];
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

      AtValue old_trustedContactsKeys =
          await backendService.atClientInstance!.get(trustedContactsKey);

      jsonValue = jsonDecode(old_trustedContactsKeys.value);

      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      trustedContactOperation = false;
      setError(AddTrustedContacts, error.toString());
    }
  }

  migrateTrustedContact() async {
    setStatus(MigrateTrustedContacts, Status.Loading);
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
          await AtClientManager.getInstance().atClient.put(
                trustedContactsKey,
                json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
              );
        } else {
          // in case we have to delete the at-sign trusted contacts which exists both in old format and new format
          jsonValue['trustedContacts'].removeAt(i);
          await AtClientManager.getInstance().atClient.put(
                trustedContactsKey,
                json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
              );
        }
      }
      print("migration OLD FORMAT ARRAY= ${jsonValue['trustedContacts']}");
      print("migration NEW FORMAT ARRAY= ${trustedContacts}");

      // await AtClientManager.getInstance().atClient.put(
      //       trustedContactsKey,
      //       json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
      //     );

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
        fetchedTrustedContact.add(AtContact(atSign: keyValue.value));
      }
      trustedContacts = [];
      trustedContacts = fetchedTrustedContact;
      setStatus(GetTrustedContacts, Status.Done);
    } catch (e) {
      print('ERROR=====>$e');
      setError(GetTrustedContacts, e.toString());
    }
  }
}
