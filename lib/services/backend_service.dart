import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_flushbar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_pro/services/hive_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:another_flushbar/flushbar.dart';
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
  AtClientManager atClientManager;
  AtClient atClientInstance;
  String currentAtSign;
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  SyncService syncService;
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
    if (atClientServiceMap[atsign] == null) {
      final appSupportDirectory =
          await path_provider.getApplicationSupportDirectory();
      print("paths => $downloadDirectory $appSupportDirectory");
    }
    await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    // atClientInstance = atClientServiceInstance.atClient;
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
      ..syncRegex = MixedConstants.regex
      ..outboundConnectionTimeout = MixedConstants.TIME_OUT
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    // return await atClientServiceInstance.getAtSign();
    await getAtClientPreference().then((value) {
      return atClientPreference = value;
    });

    atClientServiceInstance = AtClientService();

    return await KeychainUtil.getAtSign();
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

  ///Resets [atsigns] list from device storage.
  Future<void> resetAtsigns(List atsigns) async {
    for (String atsign in atsigns) {
      await KeychainUtil.resetAtSignFromKeychain(atsign);
      atClientServiceMap.remove(atsign);
    }
  }

  Map<String, AtClientService> atClientServiceMap = {};

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  startMonitor() async {
    await AtClientManager.getInstance()
        .notificationService
        .subscribe(regex: MixedConstants.appNamespace)
        .listen((AtNotification notification) {
      _notificationCallBack(notification);
    });
  }

  var fileLength;
  var userResponse = false;

  Future<void> _notificationCallBack(AtNotification response) async {
    print('response => $response');
    var notificationKey = response.key;
    var fromAtSign = response.from;

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

      var decryptedMessage = await atClientInstance.encryptionService
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

    if (notificationKey.contains(MixedConstants.FILE_TRANSFER_KEY) &&
        !notificationKey
            .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT)) {
      var atKey = notificationKey.split(':')[1];
      var value = response.value;

      var decryptedMessage =
          await atClientInstance.encryptionService.decrypt(value, fromAtSign)
              // ignore: return_of_invalid_type_from_catch_error
              .catchError((e) {
        print("error in decrypting: $e");
        //TODO: only for closed testing purpose , we are showing error dialog
        // should be removed before general release.
        ErrorDialog()
            .show(e.toString(), context: NavService.navKey.currentContext);
      });

      if (decryptedMessage != null) {
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                listen: false)
            .checkForUpdatedOrNewNotification(fromAtSign, decryptedMessage);

        BuildContext context = NavService.navKey.currentContext;
        bool trustedSender = false;
        TrustedContactProvider trustedContactProvider =
            Provider.of<TrustedContactProvider>(context, listen: false);

        trustedContactProvider.trustedContacts.forEach((element) {
          if (element.atSign == fromAtSign) {
            trustedSender = true;
          }
        });

        if (trustedSender) {
          await downloadFiles(context, atKey.split('.').first, fromAtSign);
        }
      }
    }
  }

  downloadFiles(BuildContext context, String key, String fromAtSign) async {
    var result = await Provider.of<HistoryProvider>(context, listen: false)
        .downloadFiles(
      key,
      fromAtSign,
      false,
    );
    if (result is bool && result) {
    } else if (result is bool && !result) {}
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
    if (syncStatus.dataChange && !historyProvider.isSyncedDataFetched) {
      if (historyProvider.status[historyProvider.SENT_HISTORY] !=
          Status.Loading) {
        await historyProvider.getSentHistory();
      }

      if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
          Status.Loading) {
        await historyProvider.getReceivedHistory();
      }

      historyProvider.isSyncedDataFetched = true;
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
        await LocalNotificationService()
            .showNotification(atsign, 'Download and view the file(s).');
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
            await onboardSuccessCallback(value, atsign, atClientPrefernce);
          },
          onError: (error) {
            print('Onboarding throws $error error');
          },
          appAPIKey: MixedConstants.ONBOARD_API_KEY);
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
          onboard: (value, onboardedAtsign) async {
            authenticating = true;
            isAuthuneticatingSink.add(authenticating);
            await onboardSuccessCallback(
                value, onboardedAtsign, atClientPrefernce);
            authenticating = false;
            isAuthuneticatingSink.add(authenticating);
          },
          onError: (error) {
            print('Onboarding throws $error error');
            authenticating = false;
            isAuthuneticatingSink.add(authenticating);
          },
          appAPIKey: MixedConstants.ONBOARD_API_KEY
          // nextScreen: WelcomeScreen(),
          );
      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    } catch (e) {
      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    }
  }

  onboardSuccessCallback(Map<String, AtClientService> atClientServiceMap,
      String onboardedAtsign, AtClientPreference atClientPreference) async {
    // setting client service and manager
    await AtClientManager.getInstance().setCurrentAtSign(
        onboardedAtsign, MixedConstants.appNamespace, atClientPreference);
    atClientServiceInstance = atClientServiceMap[onboardedAtsign];
    atClientManager = atClientServiceMap[onboardedAtsign].atClientManager;
    atClientInstance = atClientManager.atClient;
    atClientServiceMap = atClientServiceMap;
    currentAtSign = onboardedAtsign;
    syncService = atClientManager.syncService;
    await KeychainUtil.makeAtSignPrimary(onboardedAtsign);

    syncWithSecondary();

    // start monitor and package initializations.
    await startMonitor();
    _initBackendService();
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);

    // clearing file and contact informations.
    Provider.of<WelcomeScreenProvider>(NavService.navKey.currentState.context,
            listen: false)
        .selectedContacts = [];
    Provider.of<FileTransferProvider>(NavService.navKey.currentState.context,
            listen: false)
        .selectedFiles = [];
    Provider.of<HistoryProvider>(NavService.navKey.currentState.context,
            listen: false)
        .resetData();

    await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext,
        Routes.WELCOME_SCREEN, (Route<dynamic> route) => false);
  }

  String state;
  LocalNotificationService _notificationService;

  void _initBackendService() async {
    _notificationService = LocalNotificationService();
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
    await Navigator.push(
      NavService.navKey.currentContext,
      MaterialPageRoute(builder: (context) => HistoryScreen(tabIndex: 1)),
    );
  }
}
