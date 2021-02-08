import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_lookup/at_lookup.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_flushbar.dart';
import 'package:atsign_atmosphere_pro/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:at_commons/at_commons.dart';
import 'navigation_service.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String _atsign;
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";
  String get currentAtsign => _atsign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;
  double bytesReceived = 0.0;
  AnimationController controller;
  Flushbar receivingFlushbar;
  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    print("paths => $downloadDirectory $appSupportDirectory");
    String path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.IMMEDIATE;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = downloadDirectory.path;
    atClientPreference.outboundConnectionTimeout = MixedConstants.TIME_OUT;
    var result = await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    atClientInstance = atClientServiceInstance.atClient;
    return result;
  }

  // QR code scan
  Future authenticate(String qrCodeString, BuildContext context) async {
    Completer c = Completer();
    if (qrCodeString.contains('@')) {
      try {
        List<String> params = qrCodeString.split(':');
        if (params?.length == 2) {
          await authenticateWithCram(params[0], cramSecret: params[1]);
          _atsign = params[0];
          await startMonitor();
          c.complete(AUTH_SUCCESS);
          await Navigator.pushNamed(context, Routes.PRIVATE_KEY_GEN_SCREEN);
        }
      } catch (e) {
        print("error here =>  ${e.toString()}");
        c.complete('Fail to Authenticate');
        print(e);
      }
    } else {
      // wrong bar code
      c.complete("incorrect QR code");
      print("incorrect QR code");
    }
    return c.future;
  }

  // first time setup with cram authentication
  Future<bool> authenticateWithCram(String atsign, {String cramSecret}) async {
    atClientPreference.cramSecret = cramSecret;
    var result =
        await atClientServiceInstance.authenticate(atsign, atClientPreference);
    atClientInstance = await atClientServiceInstance.atClient;
    return result;
  }

  Future<bool> authenticateWithAESKey(String atsign,
      {String cramSecret, String jsonData, String decryptKey}) async {
    atClientPreference.cramSecret = cramSecret;
    var result = await atClientServiceInstance.authenticate(
        atsign, atClientPreference,
        jsonData: jsonData, decryptKey: decryptKey);
    atClientInstance = atClientServiceInstance.atClient;
    _atsign = atsign;
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceInstance.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await atClientServiceInstance.getEncryptedKeys(atsign);
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    // monitorConnection =
    await atClientInstance.startMonitor(privateKey, _notificationCallBack);
    print("Monitor started");
    return true;
  }

  var fileLength;
  var userResponse = false;
  Future<void> _notificationCallBack(var response) async {
    print('response => $response');
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var notificationKey = responseJson['key'];
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    atKey = atKey.replaceFirst(fromAtSign, '');
    atKey = atKey.trim();
    if (atKey == 'stream_id') {
      var valueObject = responseJson['value'];
      var streamId = valueObject.split(':')[0];
      var fileName = valueObject.split(':')[1];
      fileLength = valueObject.split(':')[2];
      fileName = utf8.decode(base64.decode(fileName));
      userResponse = await acceptStream(fromAtSign, fileName, fileLength);
      if (userResponse == true) {
        await atClientInstance.sendStreamAck(
            streamId,
            fileName,
            int.parse(fileLength),
            fromAtSign,
            _streamCompletionCallBack,
            _streamReceiveCallBack);
      }
    }
  }

  void _streamCompletionCallBack(var streamId) async {
    DateTime now = DateTime.now();
    int historyFileCount = 0;
    Provider.of<HistoryProvider>(NavService.navKey.currentContext,
            listen: false)
        .receivedFileHistory
        .forEach((key, value) {
      value.forEach((e) => historyFileCount++);
    });

    var value = {'timeStamp': now, 'length': historyFileCount};
    HiveService().writeData(
        MixedConstants.HISTORY_BOX, MixedConstants.HISTORY_KEY, value);
    receivingFlushbar =
        CustomFlushBar().getFlushbar(TextStrings().fileReceived, null);

    await receivingFlushbar.show(NavService.navKey.currentContext);
  }

  void _streamReceiveCallBack(var bytesReceived) {}

  // send a file
  Future<bool> sendFile(String atSign, String filePath) async {
    if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    print("Sending file => $atSign $filePath");
    var result = await atClientInstance.stream(atSign, filePath);
    print("sendfile result => $result");
    if (result.status.toString() == 'AtStreamStatus.COMPLETE') {
      return true;
    } else {
      return false;
    }
  }

  void downloadCompletionCallback({bool downloadCompleted, filePath}) {}

  // acknowledge file transfer
  Future<bool> acceptStream(
      String atsign, String filename, String filesize) async {
    print("from:$atsign file:$filename size:$filesize");
    BuildContext context = NavService.navKey.currentContext;
    // ContactProvider contactProvider =
    //     Provider.of<ContactProvider>(context, listen: false);

    // for (AtContact blockeduser in contactProvider.blockedContactList) {
    //   if (atsign == blockeduser.atSign) {
    //     return false;
    //   }
    // }

    if (!autoAcceptFiles &&
        app_lifecycle_state != null &&
        app_lifecycle_state != AppLifecycleState.resumed.toString()) {
      print("app not active $app_lifecycle_state");
      await NotificationService().showNotification(atsign, filename, filesize);
    }
    NotificationPayload payload = NotificationPayload(
        file: filename, name: atsign, size: double.parse(filesize));

    bool userAcceptance;
    if (autoAcceptFiles) {
      DateTime date = DateTime.now();
      Provider.of<HistoryProvider>(context, listen: false).setFilesHistory(
          atSignName: payload.name.toString(),
          historyType: HistoryType.received,
          files: [
            FilesDetail(
                filePath: atClientPreference.downloadPath + '/' + payload.file,
                size: payload.size,
                date: date.toString(),
                fileName: payload.file,
                type: payload.file.substring(payload.file.lastIndexOf('.') + 1))
          ]);
      userAcceptance = true;
    } else {
      await showDialog(
        context: context,
        builder: (context) => ReceiveFilesAlert(
          payload: jsonEncode(payload),
          sharingStatus: (s) {
            userAcceptance = s;
            print('STATUS====>$s');
          },
        ),
      );
    }

    return userAcceptance;
  }

  deleteAtSignFromKeyChain(String atsign) async {
    await FlutterKeychain.remove(key: '@atsign');
  }

  Future<bool> checkAtsign(String atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        atSign, MixedConstants.ROOT_DOMAIN, AtClientPreference().rootPort);
    return checkPresence != null;
  }

  Future<Map<String, dynamic>> getContactDetails(String atSign) async {
    Map<String, dynamic> contactDetails = {};
    if (atSign == null) {
      return contactDetails;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var metadata = Metadata();
    metadata.isPublic = true;
    metadata.namespaceAware = false;
    AtKey key = AtKey();
    key.sharedBy = atSign;
    key.metadata = metadata;
    List contactFields = TextStrings().contactFields;

    try {
      // firstname
      key.key = contactFields[0];
      var result = await atClientInstance
          .get(key)
          .catchError((e) => print("error in get ${e.toString()}"));
      var firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientInstance.get(key);
      var lastname = result.value;

      var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.length == 0) {
        name = atSign.substring(1);
      }

      // image
      key.metadata.isBinary = true;
      key.key = contactFields[2];
      result = await atClientInstance.get(key);
      var image = result.value;
      contactDetails['name'] = name;
      contactDetails['image'] = image;
    } catch (e) {
      contactDetails['name'] = null;
      contactDetails['image'] = null;
    }
    return contactDetails;
  }
}
