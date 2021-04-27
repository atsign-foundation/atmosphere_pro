import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:at_commons/at_builders.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_flushbar.dart';
import 'package:atsign_atmosphere_pro/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:at_commons/at_commons.dart';
import 'navigation_service.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String currentAtSign;
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";
  String get currentAtsign => currentAtSign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;
  double bytesReceived = 0.0;
  AnimationController controller;
  Flushbar receivingFlushbar;
  String onBoardError;

  setDownloadPath(
      {String atsign, atClientPreference, atClientServiceInstance}) async {
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    if (atClientServiceMap[atsign] == null) {
      final appSupportDirectory =
          await path_provider.getApplicationSupportDirectory();
      print("paths => $downloadDirectory $appSupportDirectory");
    }
    await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    atClientInstance = atClientServiceInstance.atClient;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..downloadPath = downloadDirectory.path
      ..namespace = MixedConstants.appNamespace
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  // QR code scan
  Future authenticate(String qrCodeString, BuildContext context) async {
    Completer c = Completer();
    if (qrCodeString.contains('@')) {
      try {
        List<String> params = qrCodeString.split(':');
        if (params?.length == 2) {
          await authenticateWithCram(params[0], cramSecret: params[1]);
          currentAtSign = params[0];
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
    currentAtSign = atsign;
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    // return await atClientServiceInstance.getAtSign();
    await getAtClientPreference().then((value) {
      return atClientPreference = value;
    });

    atClientServiceInstance = AtClientService();

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

  Map<String, AtClientService> atClientServiceMap = {};
  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor({value, atsign}) async {
    if (value.containsKey(atsign)) {
      currentAtSign = atsign;
      atClientServiceMap = value;
      atClientInstance = value[atsign].atClient;
      atClientServiceInstance = value[atsign];
    }

    await atClientServiceMap[atsign].makeAtSignPrimary(atsign);
    await initializeContactsService(atClientInstance, currentAtSign);
    Provider.of<FileTransferProvider>(NavService.navKey.currentContext,
            listen: false)
        .selectedFiles = [];
    await setDownloadPath(
        atsign: atsign,
        atClientPreference: atClientPreference,
        atClientServiceInstance: atClientServiceInstance);
    String privateKey = await getPrivateKey(atsign);
    await initializeContactsService(atClientInstance, currentAtSign);

    await atClientInstance.startMonitor(privateKey, _notificationCallBack);
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
    var toAtSing = responseJson['to'];
    // var id = responseJson['id'];
    var atKey = notificationKey.split(':')[1];
    atKey = atKey.replaceFirst(fromAtSign, '');
    atKey = atKey.trim();

    if (atKey == 'stream_id') {
      var valueObject = responseJson['value'];
      var streamId = valueObject.split(':')[0];
      var fileName = valueObject.split(':')[1];
      fileLength = valueObject.split(':')[2];
      fileName = utf8.decode(base64.decode(fileName));
      userResponse =
          await acceptStream(fromAtSign, fileName, fileLength, toAtSing
              // id:id
              );

      if (userResponse == true) {
        await atClientInstance.sendStreamAck(
            streamId,
            fileName,
            int.parse(fileLength),
            fromAtSign,
            _streamCompletionCallBack,
            _streamReceiveCallBack);
      }

      return;
    }

    if (atKey.contains(MixedConstants.FILE_TRANSFER_KEY)) {
      var value = responseJson['value'];

      var decryptedMessage = await atClientInstance.encryptionService
          .decrypt(value, fromAtSign)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print("error in decrypting: $e"));

      print('decryptedMessage $decryptedMessage');

      downloadFileFromBin(fromAtSign, decryptedMessage);
    }
  }

  void download(
    String sharedByAtSign,
    // String encryptedFilePath,
    Uint8List encryptedFileInBytes,
    String fileName,
  ) async {
    // var atKey = AtKey()
    //   ..key = fileKey
    //   ..sharedBy = sharedByAtSign;
    // var result = await atClientInstance.get(atKey);
    // print('encryptedFilePath: ${result.value}');
    // var encryptedFilePath = result.value;

    // var encryptedFile = File('/Users/apple/Downloads/__houseofwaxrural6.png');
    // var encryptedFileInBytes = encryptedFile.readAsBytesSync();
    //
    // var encryptedFileInBytes = await downloadFileFromBin(encryptedFilePath);
    // var fileName =
    //     encryptedFilePath.substring(encryptedFilePath.lastIndexOf('/') + 1);
    print('decrypting file: $fileName');
    var fileDecryptionKeyLookUpBuilder = LookupVerbBuilder()
      ..atKey = AT_FILE_ENCRYPTION_SHARED_KEY
      ..sharedBy = sharedByAtSign
      ..auth = true;
    var encryptedFileSharedKey = await atClientInstance
        .getRemoteSecondary()
        .executeAndParse(fileDecryptionKeyLookUpBuilder);
    var currentAtSignPrivateKey =
        await atClientInstance.getLocalSecondary().getEncryptionPrivateKey();
    var fileDecryptionKey = atClientInstance.decryptKey(
        encryptedFileSharedKey, currentAtSignPrivateKey);
    //  EncryptionUtil.decryptKey(
    //     encryptedFileSharedKey, currentAtSignPrivateKey);
    print(fileDecryptionKey);
    print(encryptedFileInBytes);

    var decryptedFile = await atClientInstance.encryptionService
        .decryptFile(encryptedFileInBytes, fileDecryptionKey);
    var downloadedFile = File('/Users/apple/Downloads/$fileName');
    downloadedFile.writeAsBytesSync(decryptedFile);
  }

  Future<Uint8List> downloadFileFromBin(
    String sharedByAtSign,
    String filebinPath,
    // String encryptedFilePath,
  ) async {
    http.Response response;
    try {
      response = await http.get(filebinPath);
      var archive = ZipDecoder().decodeBytes(response.bodyBytes);
      // return archive[0].content as Uint8List;
      for (var file in archive) {
        var unzipped = file.content as List<int>;
        download(
          sharedByAtSign,
          // filebinPath,
          unzipped,
          file.name,
        );
      }
      // return unzipped.;
    } catch (e) {
      print('Error in download $e');
      return null;
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

  void _streamReceiveCallBack(var bytesReceived) async {
    receivingFlushbar =
        CustomFlushBar().getFlushbar(TextStrings().fileSent, null);

    await receivingFlushbar.show(NavService.navKey.currentContext);
  }

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
  acceptStream(String atsign, String filename, String filesize, String receiver,
      {String id}) async {
    print("from:$atsign file:$filename size:$receiver");
    if (receiver == currentAtSign && atsign != currentAtSign) {
      BuildContext context = NavService.navKey.currentContext;

      if (!autoAcceptFiles &&
          app_lifecycle_state != null &&
          app_lifecycle_state != AppLifecycleState.resumed.toString()) {
        print("app not active $app_lifecycle_state");
        await NotificationService()
            .showNotification(atsign, filename, filesize);
      }
      NotificationPayload payload = NotificationPayload(
          file: filename, name: atsign, size: double.parse(filesize));

      bool userAcceptance;

      bool trustedSender = false;
      TrustedContactProvider trustedContactProvider =
          Provider.of<TrustedContactProvider>(context, listen: false);

      trustedContactProvider.trustedContacts.forEach((element) {
        if (element.atSign == atsign) {
          trustedSender = true;
        }
      });

      if (autoAcceptFiles && trustedSender) {
        DateTime date = DateTime.now();
        Provider.of<HistoryProvider>(context, listen: false).setFilesHistory(
            atSignName: payload.name.toString(),
            historyType: HistoryType.received,
            files: [
              FilesDetail(
                  filePath:
                      atClientPreference.downloadPath + '/' + payload.file,
                  size: payload.size,
                  date: date.toString(),
                  fileName: payload.file,
                  type:
                      payload.file.substring(payload.file.lastIndexOf('.') + 1))
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
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  Future<List<String>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  deleteAtSignFromKeyChain(String atsign) async {
    List<String> atSignList = await getAtsignList();

    await atClientServiceMap[atsign].deleteAtSignFromKeychain(atsign);

    if (atSignList != null) {
      atSignList.removeWhere((element) => element == currentAtSign);
    }

    var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);
    var tempAtsign;
    if (atSignList == null || atSignList.isEmpty) {
      tempAtsign = '';
    } else {
      tempAtsign = atSignList.first;
    }

    if (tempAtsign == '') {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext,
          Routes.HOME, (Route<dynamic> route) => false);
    } else {
      await Onboarding(
        atsign: tempAtsign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          atClientServiceMap = value;

          String atSign =
              await atClientServiceMap[atsign].atClient.currentAtSign;

          await atClientServiceMap[atSign].makeAtSignPrimary(atSign);
          await initializeContactsService(atClientInstance, currentAtSign);
          // await onboard(atsign: atsign, atClientPreference: atClientPreference, atClientServiceInstance: );
          await Navigator.pushNamedAndRemoveUntil(
              NavService.navKey.currentContext,
              Routes.HOME,
              (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
        // nextScreen: WelcomeScreen(),
      );
    }
    // if (atClientInstance != null) {
    //   await startMonitor();
    // }
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
      if (name.fileLength == 0) {
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

  bool authenticating = false;

  checkToOnboard({String atSign}) async {
    try {
      authenticating = true;
      var atClientPrefernce;
      //  await getAtClientPreference();
      await getAtClientPreference()
          .then((value) => atClientPrefernce = value)
          .catchError((e) => print(e));
      currentAtSign = atSign;
      await Onboarding(
        atsign: atSign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          atClientServiceMap = value;

          String atSign =
              await atClientServiceMap[atsign].atClient.currentAtSign;

          await atClientServiceMap[atSign].makeAtSignPrimary(atSign);
          await startMonitor(atsign: atsign, value: value);
          _initBackendService();
          await initializeContactsService(atClientInstance, currentAtSign);
          authenticating = false;
          // await onboard(atsign: atsign, atClientPreference: atClientPreference, atClientServiceInstance: );
          await Navigator.pushNamedAndRemoveUntil(
              NavService.navKey.currentContext,
              Routes.WELCOME_SCREEN,
              (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
          authenticating = false;
        },
        // nextScreen: WelcomeScreen(),
      );
    } catch (e) {
      authenticating = false;
    }
  }

  String state;
  NotificationService _notificationService;
  void _initBackendService() async {
    _notificationService = NotificationService();
    _notificationService.cancelNotifications();
    _notificationService.setOnNotificationClick(onNotificationClick);

    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels> $msg');
      app_lifecycle_state = msg;

      return null;
    });
  }

  onNotificationClick(String payload) async {}
}
