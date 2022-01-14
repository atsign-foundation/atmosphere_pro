import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_flushbar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
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
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:at_client/src/service/sync_service.dart';
import 'package:at_client/src/service/sync_service_impl.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  AtClientManager atClientManager = AtClientManager.getInstance();
  SyncService syncService;
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

  final _isAuthuneticatingStreamController = StreamController<bool>.broadcast();
  Stream<bool> get isAuthuneticatingStream =>
      _isAuthuneticatingStreamController.stream;
  StreamSink<bool> get isAuthuneticatingSink =>
      _isAuthuneticatingStreamController.sink;

  setDownloadPath(
      {String atsign, atClientPreference, atClientServiceInstance}) async {
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    downloadDirectory = Directory(MixedConstants.RECEIVED_FILE_DIRECTORY);
    if (atClientServiceMap[atsign] == null) {
      final appSupportDirectory =
          await path_provider.getApplicationSupportDirectory();
      // final appSupportDirectory = Directory(MixedConstants.path);
      print("paths => $downloadDirectory $appSupportDirectory");
    }
    await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    atClientInstance = atClientServiceInstance.atClient;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    // if (Platform.isIOS) {
    //   downloadDirectory =
    //       await path_provider.getApplicationDocumentsDirectory();
    // } else {
    //   downloadDirectory = await path_provider.getExternalStorageDirectory();
    // }
    downloadDirectory = Directory(MixedConstants.RECEIVED_FILE_DIRECTORY);
    // final appDocumentDirectory = Directory(MixedConstants.path);
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..downloadPath = downloadDirectory.path
      ..namespace = MixedConstants.appNamespace
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..syncRegex = MixedConstants.regex
      ..outboundConnectionTimeout = MixedConstants.TIME_OUT
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
    // atClientInstance = await atClientServiceInstance.atClient;
    return result;
  }

  Future<bool> authenticateWithAESKey(String atsign,
      {String cramSecret, String jsonData, String decryptKey}) async {
    atClientPreference.cramSecret = cramSecret;
    var result = await atClientServiceInstance.authenticate(
        atsign, atClientPreference,
        jsonData: jsonData, decryptKey: decryptKey);
    // atClientInstance = atClientServiceInstance.atClient;
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

    currentAtSign = await KeychainUtil.getAtSign();
    return currentAtSign;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await KeychainUtil.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await KeychainUtil.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await KeychainUtil.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await KeychainUtil.getEncryptedKeys(atsign);
  }

  Map<String, AtClientService> atClientServiceMap = {};
  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor({value, atsign}) async {
    await AtClientManager.getInstance()
        .notificationService
        .subscribe()
        .listen((AtNotification notification) {
      _notificationCallBack(notification);
    });
    print('monitor started');
    return true;
  }

  var fileLength;
  var userResponse = false;
  Future<void> _notificationCallBack(var response) async {
    // check for stats notification with id -1
    if (response.id == '-1') {
      return;
    }
    var notificationKey = response.key;
    var fromAtSign = response.from;
    var atKey = notificationKey.split(':')[1];
    atKey = atKey.replaceFirst(fromAtSign, '');
    atKey = atKey.trim();
    print('fromAtSign : $fromAtSign');

    // check for notification from blocked atsign
    if (ContactService()
            .blockContactList
            .indexWhere((element) => element.atSign == fromAtSign) >
        -1) {
      return;
    }
    if (notificationKey
        .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT)) {
      var value = response.value;

      var decryptedMessage = await AtClientManager.getInstance()
          .atClient
          .encryptionService
          .decrypt(value, fromAtSign)
          .catchError((e) {
        print("error in decrypting: $e");
      });
      DownloadAcknowledgement downloadAcknowledgement =
          DownloadAcknowledgement.fromJson(jsonDecode(decryptedMessage));

      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .updateDownloadAcknowledgement(downloadAcknowledgement, fromAtSign);
      return;
    }

    print(' FILE_TRANSFER_KEY : ${atKey}');
    if (notificationKey.contains(MixedConstants.FILE_TRANSFER_KEY) &&
        !notificationKey
            .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT)) {
      var value = response.value;

      var decryptedMessage = await atClientManager.atClient.encryptionService
          .decrypt(value, fromAtSign)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print("error in decrypting: $e"));

      if (decryptedMessage != null) {
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                listen: false)
            .checkForUpdatedOrNewNotification(fromAtSign, decryptedMessage);
        await NotificationService().showNotification(fromAtSign);
      }
    }
  }

  syncWithSecondary() async {
    syncService = AtClientManager.getInstance().syncService;
    syncService.sync(onDone: _onSuccessCallback);
    syncService.setOnDone(_onSuccessCallback);
  }

  _onSuccessCallback(SyncResult syncStatus) async {
    var historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentState.context,
        listen: false);

    print(
        'syncStatus type : $syncStatus, datachanged : ${syncStatus.dataChange}');
    if (syncStatus.syncStatus == SyncStatus.success &&
        syncStatus.dataChange &&
        !historyProvider.isSyncedDataFetched) {
      if (historyProvider.status[historyProvider.SENT_HISTORY] !=
          Status.Loading) {
        await historyProvider.getSentHistory();
      }

      if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
          Status.Loading) {
        await historyProvider.getReceivedHistory();
      }

      historyProvider.isSyncedDataFetched = true;
      print(
          'historyProvider.isSyncedDataFetched : ${historyProvider.isSyncedDataFetched}');
    }
  }

  Future proceedToFileDownload(String fileName) async {
    String path = downloadDirectory.path + '/$fileName';
    File file = File(path);
    bool isPresent, proceedToDownload = false;
    isPresent = await file.exists();
    if (isPresent) {
      await showDialog(
          context: NavService.navKey.currentContext,
          builder: (context) {
            return AlertDialog(
              content: Container(
                height: 150.toHeight,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A file named, "$fileName" already exists. ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Do you want to replace it ?'),
                      SizedBox(
                        height: 20.toHeight,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                proceedToDownload = true;
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes')),
                          TextButton(onPressed: null, child: Text('')),
                          TextButton(
                              onPressed: () {
                                proceedToDownload = false;
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      // when file with same name is not present , we can proceed to download
      print('file not present');
      return true;
    }
    print('proceedToDownload : ${proceedToDownload}');
    return proceedToDownload;
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
        await NotificationService().showNotification(atsign);
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
            atSignName: [payload.name.toString()],
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
    await KeychainUtil.deleteAtSignFromKeychain(atsign);
    if (atSignList != null) {
      atSignList.removeWhere((element) => element == atsign);
    }
    var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);

    var tempAtsign;
    if (atSignList == null || atSignList.isEmpty) {
      tempAtsign = '';
    } else {
      tempAtsign = atSignList.first;
    }

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      /// in case of desktop, we close the dialog from here
      Navigator.of(NavService.navKey.currentContext).pop();
    }

    if (tempAtsign == '') {
      if (Platform.isAndroid || Platform.isIOS) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext,
            Routes.HOME,
            (Route<dynamic> route) => false);
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext,
            DesktopRoutes.DESKTOP_HOME,
            (Route<dynamic> route) => false);
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      await Onboarding(
        atsign: tempAtsign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        appAPIKey: MixedConstants.ONBOARD_API_KEY,
        rootEnvironment: RootEnvironment.Production,
        onboard: (value, atsign) async {
          atClientServiceMap = value;

          String atSign = await atClientManager.atClient.getCurrentAtSign();
          currentAtSign = atSign;
          await startMonitor(atsign: atsign, value: value);
          await initializeContactsService();
          // await onboard(atsign: atsign, atClientPreference: atClientPreference, atClientServiceInstance: );
          await Navigator.pushNamedAndRemoveUntil(
              NavService.navKey.currentContext,
              Routes.HOME,
              (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
      );
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      CustomOnboarding.onboard(
          atSign: tempAtsign, atClientPrefernce: atClientPrefernce);
    }
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
      var result = await atClientManager.atClient
          .get(key)
          .catchError((e) => print("error in get ${e.toString()}"));
      var firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientManager.atClient.get(key);
      var lastname = result.value;

      var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.fileLength == 0) {
        name = atSign.substring(1);
      }

      // image
      key.metadata.isBinary = true;
      key.key = contactFields[2];
      result = await atClientManager.atClient.get(key);
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
      isAuthuneticatingSink.add(authenticating);
      var atClientPrefernce;
      //  await getAtClientPreference();
      await getAtClientPreference()
          .then((value) => atClientPrefernce = value)
          .catchError((e) => print(e));
      await Onboarding(
        atsign: atSign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        appAPIKey: MixedConstants.ONBOARD_API_KEY,
        rootEnvironment: RootEnvironment.Production,
        onboard: (value, atsign) async {
          authenticating = true;
          isAuthuneticatingSink.add(authenticating);
          atClientServiceMap = value;

          String atSign = await atClientManager.atClient.getCurrentAtSign();
          currentAtSign = atSign;

          await startMonitor(atsign: atsign, value: value);
          initBackendService();
          await initializeContactsService();
          authenticating = false;
          isAuthuneticatingSink.add(authenticating);
          // await onboard(atsign: atsign, atClientPreference: atClientPreference, atClientServiceInstance: );
          await Navigator.pushNamedAndRemoveUntil(
              NavService.navKey.currentContext,
              Routes.WELCOME_SCREEN,
              (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
          authenticating = false;
          isAuthuneticatingSink.add(authenticating);
        },
        // nextScreen: WelcomeScreen(),
      );
      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    } catch (e) {
      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    }
  }

  String state;
  NotificationService _notificationService;
  void initBackendService() async {
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

  onNotificationClick(String payload) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Navigator.push(
        NavService.navKey.currentContext,
        MaterialPageRoute(builder: (context) => HistoryScreen(tabIndex: 1)),
      );
    } else if (Platform.isMacOS) {
      DesktopSetupRoutes.nested_push(DesktopRoutes.DESKTOP_HISTORY);
    }
  }

  ///Resets [atsigns] list from device storage.
  Future<void> resetAtsigns(List atsigns) async {
    for (String atsign in atsigns) {
      await KeychainUtil.resetAtSignFromKeychain(atsign);
      atClientServiceMap.remove(atsign);
    }
  }
}
