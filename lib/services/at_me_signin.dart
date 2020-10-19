import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_utils/at_logger.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

class AtMeService {
  static final AtMeService _singleton = AtMeService._internal();

  AtMeService._internal();
  final AtSignLogger _logger = AtSignLogger('AtMeService');

  factory AtMeService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;

  // StateContainerState _container;
  // User _user;
  String _atsign;
  List<String> scanKeys = [];

  Map<dynamic, dynamic> tempObject = {};

  ///Returns `true` if authentication is successful for the existing atsign in device.
  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
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
        namespace: 'me');
    atClientInstance = atClientServiceInstance.atClient;
    // var keys = await atClientInstance.getKeys(sharedBy: '@kevin🛠');
    // print("keys => $keys");
    return result;
  }

  ///Returns `false` if fails in authenticating [atsign] with [cramSecret]/[privateKey].
  Future<bool> authenticate(String atsign, {String cramSecret}) async {
    var result = await atClientServiceInstance.authenticate(atsign,
        cramSecret: cramSecret);
    atClientInstance = await atClientServiceInstance.atClient;
    return result;
  }

  checkLogin(BuildContext context) async {
    try {
      await onboard();
      Navigator.pushNamed(context, Routes.WELCOME_SCREEN);
    } catch (e) {
      print("error here => $e");
      Navigator.pushNamed(context, Routes.SCAN_QR_SCREEN);
    }
  }

  performAuthentication(String qrCodeString, BuildContext context) async {
    if (qrCodeString.contains('@')) {
      try {
        List<String> params = qrCodeString.split(':');

        await onboard(atsign: params[0]).catchError((e) {
          print("error => $e");
        });
        await authenticate(params[0], cramSecret: params[1]);
        Navigator.pushNamed(context, Routes.WELCOME_SCREEN);
      } catch (e) {
        print(e);
      }
    } else {
      // wrong bar code
    }
  }
}
