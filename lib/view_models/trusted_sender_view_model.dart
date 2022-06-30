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
  List<AtContact?> new_trustedContacts = [];
  List<AtKey?> new_trustedContactsKeys = [];
  bool trustedContactOperation = false;
  List<String?> trustedNames = [];
  List<String?> new_trustedNames = [];
  String GetTrustedContacts = 'get_trusted_contacts';
  List<AtContact?> fetchedTrustedContact = [];
  List<AtContact?> new_fetchedTrustedContact = [];
  BackendService backendService = BackendService.getInstance();

  addTrustedContacts(AtContact? trustedContact) async {
    trustedContactOperation = true;

    setStatus(AddTrustedContacts, Status.Loading);
    String at_sign_name = trustedContact!.atSign!.replaceAll("@", "");
    try {
      bool isAlreadyPresent = false;
      for (AtContact? contact in new_trustedContacts) {
        if (contact.toString() == trustedContact.toString()) {
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
              // trustedContact,
            );
        trustedContacts.add(trustedContact);
        new_trustedContactsKeys = await AtClientManager.getInstance()
            .atClient
            .getAtKeys(regex: 'trusted_contact_');
        print("the key created now is : ${trustedContactsKey}");
        print("new_trustedContactskey is :${new_trustedContactsKeys}");
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
      // AtKey trustedContactsKey = AtKey()
      //   ..key = 'trustedContactsKey'
      //   ..metadata = Metadata();
      // await AtClientManager.getInstance().atClient.put(
      //       trustedContactsKey,
      //       json.encode({"trustedContacts": trustedContacts}),
      //     );
      // print(
      //     "trusted contacts key in setTrustedContacts: ${trustedContactsKey}");
      print("inside setTrustedContacts!");
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
    // fetchedTrustedContact = [];
    // for (AtKey? new_key in new_trustedContactsKeys) {
    //   try {
    //     AtValue keyValue = await backendService.atClientInstance!
    //         .get(new_key!)
    //         .catchError((e) {
    //       print('error in get in getTrustedContact : $e ');
    //       return AtValue();
    //     });
    //     var jsonValue;
    //     if (keyValue != null && keyValue.value != null) {
    //       jsonValue = jsonDecode(keyValue.value);
    //       jsonValue[new_key].forEach((contact) {
    //         final c = AtContact.fromJson(contact);
    //         fetchedTrustedContact.add(c);
    //         trustedNames.add(c.atSign);
    //       });
    //     }

    //     trustedContacts = [];
    //     trustedContacts = fetchedTrustedContact;
    //     print("in getTrustedContacts trustedContacts: ${trustedContacts}");
    //     print(
    //         "in getTrustedContacts fetchedTrustedContact: ${fetchedTrustedContact}");
    //     setStatus(GetTrustedContacts, Status.Done);
    //   } catch (e) {
    //     print('ERROR=====>$e');
    //     setError(GetTrustedContacts, e.toString());
    //   }
    // }
    try {
      AtKey trustedContactsKey = AtKey()
        ..key = 'trustedContactsKey'
        ..metadata = Metadata();

      AtValue keyValue = await backendService.atClientInstance!
          .get(trustedContactsKey)
          .catchError((e) {
        print('error in get in getTrustedContact : $e ');
        return AtValue();
      });

      var jsonValue;
      if (keyValue != null && keyValue.value != null) {
        jsonValue = jsonDecode(keyValue.value);
        jsonValue['trustedContacts'].forEach((contact) {
          final c = AtContact.fromJson(contact);
          fetchedTrustedContact.add(c);
          trustedNames.add(c.atSign);
        });
      }

      trustedContacts = [];
      trustedContacts = fetchedTrustedContact;
      print("in getTrustedContacts trustedContacts: ${trustedContacts}");
      print(
          "in getTrustedContacts fetchedTrustedContact: ${fetchedTrustedContact}");
      setStatus(GetTrustedContacts, Status.Done);
    } catch (error) {
      print('ERROR=====>$error');
      setError(GetTrustedContacts, error.toString());
    }
  }
}
