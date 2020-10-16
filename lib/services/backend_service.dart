import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String _atsign;
  String _documentsPath;

  String get currentAtsign => _atsign;

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    _documentsPath = appDocumentDirectory.path;
    print("appDocumentDirectory => $appDocumentDirectory");
    String path = appDocumentDirectory.path;
    var atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..rootDomain = 'test.do-sf2.atsign.zone'
      ..hiveStoragePath = path;
    var result = await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference,
        atsign: atsign,
        namespace: 'mosphere');
    atClientInstance = atClientServiceInstance.atClient;
    return result;
  }

  // QR code scan
  authenticate(String qrCodeString, BuildContext context) async {
    if (qrCodeString.contains('@')) {
      try {
        List<String> params = qrCodeString.split(':');
        if (params?.length == 2) {
          _atsign = params[0];
          await authenticateWithCram(params[0], cramSecret: params[1]);
          await Navigator.pushNamed(context, Routes.WELCOME_SCREEN);
        }
      } catch (e) {
        print(e);
      }
    } else {
      // wrong bar code
      print("incorrect QR code");
    }
  }

  // first time setup with cram authentication
  Future<bool> authenticateWithCram(String atsign, {String cramSecret}) async {
    var result = await atClientServiceInstance.authenticate(atsign,
        cramSecret: cramSecret);
    atClientInstance = await atClientServiceInstance.atClient;
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

  // startMonitor needs to be called at the beginning of session
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    atClientInstance.startMonitor(privateKey, _documentsPath, acceptStream);
    print("Monitor started");
    return true;
  }

  // send a file
  Future<bool> sendFile(String filePath) async {
    print("Sending file => $filePath");
    var result = await atClientInstance.stream('@kevin🛠', filePath);
    print("sendfile result => $result");
    if (result.status.toString() == 'AtStreamStatus.COMPLETE') {
      return true;
    } else {
      return false;
    }
  }

  // acknowledge file transfer
  Future<bool> acceptStream(String atsign, String filename) async {
    print("from:$atsign file:$filename");
    await NotificationService().showNotification(atsign, filename);
    // popup for user which is awaited for one minute
    // and returns true or false
    return true;
  }
}
