import 'dart:convert';
import 'dart:io';
import 'package:at_client/src/stream/file_transfer_object.dart';
import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

/// Dump all the .keys file from which the notifications has to be sent into a directory
/// and provide the path to the directoryPath variable.
/// Provide the receiving atSign in sharedWithAtSign variable.
/// Defaulted to work for the production atSign. To enable for other environments
/// set root domain in getPreference method.
Future<void> main() async {
  var directoryPath = '';
  var sharedWithAtSign = '@atsign';
  var keysList = Directory(directoryPath).listSync();
  keysList.removeWhere((element) =>
      element.path.contains('.DS') || element.path.contains('hive'));
  for (var keys in keysList) {
    var keysMap = await dumpKeys(keys.path);
    var atSign = keys.path
        .substring(keys.path.lastIndexOf('@'))
        .replaceAll('_key.atKeys', '');
    var preferences =
        getPreference(keysMap["pkamPrivateKey"].toString(), directoryPath);
    await setKeys(atSign, preferences, keysMap);
    var atClientManager = await AtClientManager.getInstance()
        .setCurrentAtSign(atSign, MixedConstants.appNamespace, preferences);
    final atClient = atClientManager.atClient;

    var fileTransferObject = getFileTransferObject(atSign);

    var atKey = AtKey()
      ..key = fileTransferObject.transferId
      ..sharedWith = sharedWithAtSign
      ..metadata = Metadata()
      ..metadata.ttr = -1
      // file transfer key will be deleted after 30 minutes
      ..metadata.ttl = 900000
      ..sharedBy = atSign;

    var notificationStatus = await atClientManager.notificationService.notify(
      NotificationParams.forUpdate(
        atKey,
        value: jsonEncode(fileTransferObject.toJson()),
      ),
    );
    print(
        'sent notification to: $sharedWithAtSign , from" $atSign,  ID: ${notificationStatus.notificationID}, status: ${notificationStatus.notificationStatusEnum}, exception: ${notificationStatus.atClientException}');
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
        .setCurrentAtSign(
            atSign, MixedConstants.appNamespace, atClientPreference);
    var atClient = atClientManager.atClient;
    var metadata = Metadata();
    metadata.namespaceAware = false;
    // Set encryption private key
    await atClient.getLocalSecondary()?.putValue(
        AT_ENCRYPTION_PRIVATE_KEY, keyMap["encryptionPrivateKey"].toString());
    // Set encryption public key. should be synced
    metadata.isPublic = true;
    var atKey = AtKey()
      ..key = 'publickey'
      ..metadata = metadata;
    await atClient.put(atKey, keyMap["encryptionPublicKey"].toString());
    // Set self encryption keys.
    await atClient.getLocalSecondary()?.putValue(
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

FileTransferObject getFileTransferObject(String sharedWith) {
  return FileTransferObject(
    MixedConstants.FILE_TRANSFER_KEY +
        '${DateTime.now().microsecondsSinceEpoch}',
    'dem_encryption_key',
    'demo_fileUrl',
    sharedWith,
    [FileStatus(fileName: 'file_name', size: 11)],
    date: DateTime.now(),
  );
}
