import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

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

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    var appDocumentDirectory;
    if (Platform.isIOS) {
      appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      appDocumentDirectory = await path_provider.getExternalStorageDirectory();
    }
    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    print("paths => $appDocumentDirectory $appSupportDirectory");
    String path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.IMMEDIATE;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = appDocumentDirectory.path;
    atClientPreference.outboundConnectionTimeout = MixedConstants.TIME_OUT;
    var result = await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference,
        atsign: atsign,
        namespace: 'mosphere');
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
    var result = await atClientServiceInstance.authenticate(atsign,
        cramSecret: cramSecret);
    atClientInstance = await atClientServiceInstance.atClient;
    return result;
  }

  Future<bool> authenticateWithAESKey(String atsign,
      {String cramSecret, String jsonData, String decryptKey}) async {
    var result = await atClientServiceInstance.authenticate(atsign,
        cramSecret: cramSecret, jsonData: jsonData, decryptKey: decryptKey);
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
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    atClientInstance.startMonitor(privateKey, acceptStream);
    print("Monitor started");
    return true;
  }

  // send a file
  Future<bool> sendFile(String atSign, String filePath) async {
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
    ContactProvider contactProvider =
        Provider.of<ContactProvider>(context, listen: false);

    for (AtContact blockeduser in contactProvider.blockContactList) {
      if (atsign == blockeduser.atSign) {
        return false;
      }
    }

    if (!autoAcceptFiles &&
        app_lifecycle_state != null &&
        app_lifecycle_state != AppLifecycleState.resumed.toString()) {
      print("app not active $app_lifecycle_state");
      await NotificationService().showNotification(atsign, filename, filesize);
      // sleep(const Duration(seconds: 2));
    }
    NotificationPayload payload = NotificationPayload(
        file: filename, name: atsign, size: double.parse(filesize));

    bool userAcceptance;
    if (autoAcceptFiles) {
      Provider.of<HistoryProvider>(context, listen: false).setFilesHistory(
          atSignName: payload.name.toString(),
          historyType: HistoryType.received,
          files: [
            FilesDetail(
                filePath: atClientPreference.downloadPath + '/' + payload.file,
                size: payload.size,
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
}
