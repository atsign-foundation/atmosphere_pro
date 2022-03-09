import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

/// Dump all the .keys file from which the notifications has to be sent into a directory
/// and provide the path to the directoryPath variable.
/// Provide the receiving atSign in sharedWithAtSign variable.
/// Defaulted to work for the production atSign. To enable for other environments
/// set root domain in getPreference method.
Future<void> main() async {
  var directoryPath = '/Users/gayathridevisrinivasan/Documents/at_key';
  var sharedWithAtSign = '@batblack77naval';
  var keysList = Directory(directoryPath).listSync();
  for (var keys in keysList) {
    var keysMap = await dumpKeys(keys.path);
    var atSign = keys.path
        .substring(keys.path.lastIndexOf('@'))
        .replaceAll('_key.atKeys', '');
    var preferences =
        getPreference(keysMap["pkamPrivateKey"].toString(), directoryPath);
    await setKeys(atSign, preferences, keysMap);
    var atClientManager = await AtClientManager.getInstance()
        .setCurrentAtSign(atSign, 'wavi', preferences);
    final atClient = atClientManager.atClient;
    var notificationId =
        await atClient.notifyChange(NotificationParams.forUpdate(AtKey()
          ..key = 'phone'
          ..sharedWith = sharedWithAtSign
          ..sharedBy = atSign));
    print('$atSign : $notificationId');
  }
}

/// Get Decrypted keys from .keys file.
Future<Map> dumpKeys(filePath) async {
  var keyMap = {};
  try {
    var fileContents = File(filePath).readAsStringSync();
    var keysJSON = json.decode(fileContents);
    var aesEncryptionKey = keysJSON['selfEncryptionKey'];
    keyMap['pkamPublicKey'] = RSAPublicKey.fromString(
        decryptValue(keysJSON['aesPkamPublicKey'], aesEncryptionKey));
    keyMap['pkamPrivateKey'] = RSAPrivateKey.fromString(
        decryptValue(keysJSON['aesPkamPrivateKey'], aesEncryptionKey));
    keyMap['encryptionPublicKey'] = RSAPublicKey.fromString(
        decryptValue(keysJSON['aesEncryptPublicKey'], aesEncryptionKey));
    keyMap['encryptionPrivateKey'] = RSAPrivateKey.fromString(
        decryptValue(keysJSON['aesEncryptPrivateKey'], aesEncryptionKey));
    keyMap['selfEncryptionKey'] = aesEncryptionKey;
  } on ArgParserException catch (e) {
    print('$e');
  } on Exception catch (e) {
    print('Exception : $e');
  }
  return keyMap;
}

/// Decrypt the encrypted keys
String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

/// Set keys in the local hive store.
Future<void> setKeys(
    String atSign, AtClientPreference atClientPreference, Map keyMap) async {
  try {
    final atClientManager = await AtClientManager.getInstance()
        .setCurrentAtSign(atSign, 'me', atClientPreference);
    var atClient = atClientManager.atClient;
    var metadata = Metadata();
    metadata.namespaceAware = false;
    // Set encryption private key
    await atClient.getLocalSecondary().putValue(
        AT_ENCRYPTION_PRIVATE_KEY, keyMap["encryptionPrivateKey"].toString());
    // Set encryption public key. should be synced
    metadata.isPublic = true;
    var atKey = AtKey()
      ..key = 'publickey'
      ..metadata = metadata;
    await atClient.put(atKey, keyMap["encryptionPublicKey"].toString());
    // Set self encryption keys.
    await atClient.getLocalSecondary().putValue(
        AT_ENCRYPTION_SELF_KEY, keyMap["selfEncryptionKey"].toString());
  } on Exception catch (e, trace) {
    print(e.toString());
    print(trace);
  }
}

/// Returns the preferences
AtClientPreference getPreference(String privateKey, String directoryPath) {
  var preference = AtClientPreference();
  //Storage path of hive
  // Replace with local hive path
  preference.hiveStoragePath = '$directoryPath/hive';
  // Replace with commit log hive path
  preference.commitLogPath = '$directoryPath/hive/commit';
  preference.isLocalStoreRequired = true;
  preference.privateKey = privateKey;
  preference.rootDomain = 'root.atsign.org';
  return preference;
}