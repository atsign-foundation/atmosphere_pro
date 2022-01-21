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
  List<AtContact> trustedContacts = [];
  bool trustedContactOperation = false;
  List<String> trustedNames = [];
  String GetTrustedContacts = 'get_trusted_contacts';
  List<AtContact> fetchedTrustedContact = [];
  BackendService backendService = BackendService.getInstance();

  addTrustedContacts(AtContact trustedContact) async {
    setStatus(AddTrustedContacts, Status.Loading);

    try {
      // trustedContacts = [];
      // await getTrustedContact();

      bool isAlreadyPresent = false;
      for (AtContact contact in trustedContacts) {
        if (contact.toString() == trustedContact.toString()) {
          isAlreadyPresent = true;
          break;
        }
      }
      if (!isAlreadyPresent) {
        trustedContacts.add(trustedContact);
      }
      setStatus(AddTrustedContacts, Status.Done);
    } catch (error) {
      setError(AddTrustedContacts, error.toString());
      setStatus(AddTrustedContacts, Status.Error);
    }
  }

  removeTrustedContacts(AtContact trustedContact) async {
    setStatus(AddTrustedContacts, Status.Loading);
    trustedContactOperation = true;

    try {
      // if (trustedContacts.contains(trustedContact)) {
      //   trustedContacts.remove(trustedContact);
      // }
      for (AtContact contact in trustedContacts) {
        if (contact.atSign == trustedContact.atSign) {
          int index = trustedContacts.indexOf(contact);
          trustedContacts.removeAt(index);
          // isAlreadyPresent = true;
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
    fetchedTrustedContact = [];
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
