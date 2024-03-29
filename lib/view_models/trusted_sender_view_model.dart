import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/exception_service.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';

class TrustedContactProvider extends BaseModel {
  TrustedContactProvider._();
  static TrustedContactProvider _instance = TrustedContactProvider._();
  factory TrustedContactProvider() => _instance;
  String AddTrustedContacts = 'add_trusted_contacts';
  List<AtContact> _trustedContacts = [];
  List<AtContact> get trustedContacts => _trustedContacts;

  var jsonValue;
  List<AtKey> new_trustedContactsKeys = [];
  bool trustedContactOperation = false;
  List<String?> trustedNames = [];
  String GetTrustedContacts = 'get_trusted_contacts';
  String MigrateTrustedContacts = 'migrate_trusted_contacts';

  BackendService backendService = BackendService.getInstance();

  resetData() {
    _trustedContacts = [];
    new_trustedContactsKeys = [];
    trustedContactOperation = false;
    trustedNames = [];
  }

  addTrustedContacts(AtContact trustedContact) async {
    if (trustedContact.tags != null && trustedContact.tags!['image'] != null) {
      trustedContact.tags!['image'] = null;
    }
    trustedContactOperation = true;
    setStatus(AddTrustedContacts, Status.Loading);
    String at_sign_name = trustedContact.atSign!.replaceAll("@", "");

    try {
      bool isAlreadyPresent = false;
      for (AtContact? contact in _trustedContacts) {
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
        _trustedContacts.add(trustedContact);
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
    var res;
    try {
      for (AtContact? contact in _trustedContacts) {
        if (contact!.atSign == trustedContact!.atSign) {
          int index = _trustedContacts.indexOf(contact);
          AtKey key = AtKey()
            ..key =
                'trusted_contact_${trustedContact.atSign!.replaceAll("@", "")}'
            ..metadata = Metadata();
          res = await AtClientManager.getInstance().atClient.delete(key);
          if (res) {
            _trustedContacts.removeAt(index);
          } else {
            print("error in deleting atKey from server");
          }
          break;
        }
      }
      trustedContactOperation = false;
      setStatus(AddTrustedContacts, Status.Done);
      return res;
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
          await AtClientManager.getInstance().atClient.get(trustedContactsKey);
      jsonValue = jsonDecode(old_trustedContactsKeys.value);
      for (var i = 0; i < jsonValue['trustedContacts'].length; i++) {
        var j = _trustedContacts.indexWhere((element) =>
            element.atSign == jsonValue['trustedContacts'][i]['atSign']);
        if (j == -1) {
          AtKey new_trustedContactsKey = AtKey()
            ..key =
                'trusted_contact_${jsonValue['trustedContacts'][i]['atSign'].replaceAll("@", "")}'
            ..metadata = Metadata();
          await AtClientManager.getInstance().atClient.put(
                new_trustedContactsKey,
                jsonValue['trustedContacts'][i]['atSign'],
              );

          _trustedContacts.add(
              AtContact(atSign: jsonValue['trustedContacts'][i]['atSign']));
          jsonValue['trustedContacts'].removeAt(i);

          await AtClientManager.getInstance().atClient.put(
                trustedContactsKey,
                json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
              );
        } else {
          jsonValue['trustedContacts'].removeAt(i);
          await AtClientManager.getInstance().atClient.put(
                trustedContactsKey,
                json.encode({"trustedContacts": jsonValue["trustedContacts"]}),
              );
        }
      }

      setStatus(MigrateTrustedContacts, Status.Done);
    } catch (e) {
      print('ERROR=====>$e');
      setError(MigrateTrustedContacts, e.toString());
    }
  }

  getTrustedContact() async {
    List<AtContact> fetchedTrustedContact = [];
    setStatus(GetTrustedContacts, Status.Loading);

    new_trustedContactsKeys = await AtClientManager.getInstance()
        .atClient
        .getAtKeys(regex: 'trusted_contact_');

    try {
      for (var new_key in new_trustedContactsKeys) {
        AtValue keyValue = await AtClientManager.getInstance()
            .atClient
            .get(new_key)
            .catchError((e) {
          return AtValue();
        });
        fetchedTrustedContact.add(AtContact(atSign: keyValue.value));
      }

      fetchedTrustedContact.forEach((element) {
        _trustedContacts.add(element);
      });
      setStatus(GetTrustedContacts, Status.Done);
    } catch (e) {
      print('ERROR=====>$e');
      setError(GetTrustedContacts, e.toString());
    }
  }
}
