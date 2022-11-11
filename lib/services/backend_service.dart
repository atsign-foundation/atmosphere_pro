import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_sync_ui_flutter/at_sync_ui.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/exception_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/services/version_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'navigation_service.dart';
import 'package:at_client/src/service/sync_service.dart';
import 'package:at_client/src/service/notification_service_impl.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:at_sync_ui_flutter/at_sync_ui_flutter.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();

  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }

  AtClientService? atClientServiceInstance;

  String? currentAtSign;
  String? app_lifecycle_state;
  late AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";
  Timer? periodicHistoryRefresh;
  String? get currentAtsign => currentAtSign;
  Directory? downloadDirectory;
  AnimationController? controller;

  final _isAuthuneticatingStreamController = StreamController<bool>.broadcast();

  Stream<bool> get isAuthuneticatingStream =>
      _isAuthuneticatingStreamController.stream;

  StreamSink<bool> get isAuthuneticatingSink =>
      _isAuthuneticatingStreamController.sink;

  setDownloadPath(
      {String? atsign,
      atClientPreference,
      required atClientServiceInstance}) async {
    if (Platform.isIOS || Platform.isWindows) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    downloadDirectory = Directory(MixedConstants.RECEIVED_FILE_DIRECTORY);
    if (atClientServiceMap[atsign!] == null) {
      final appSupportDirectory =
          await path_provider.getApplicationSupportDirectory();
      // final appSupportDirectory = Directory(MixedConstants.path);
      print("paths => $downloadDirectory $appSupportDirectory");
    }
    await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    // atClientInstance = atClientServiceInstance.atClient;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    // if (Platform.isIOS || Platform.isWindows) {
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
      ..downloadPath = downloadDirectory!.path
      ..namespace = MixedConstants.appNamespace
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..syncRegex = MixedConstants.regex
      ..outboundConnectionTimeout = MixedConstants.TIME_OUT
      ..monitorHeartbeatInterval = Duration(minutes: 1)
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    await getAtClientPreference().then((value) {
      return atClientPreference = value;
    });

    atClientServiceInstance = AtClientService();

    return await KeychainUtil.getAtSign();
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return await KeychainUtil.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String?> getPublicKey(String atsign) async {
    return await KeychainUtil.getPublicKey(atsign);
  }

  Future<String?> getAESKey(String atsign) async {
    return await KeychainUtil.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await KeychainUtil.getEncryptedKeys(atsign);
  }

  Map<String, AtClientService> atClientServiceMap = {};

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  startMonitor() async {
    await AtClientManager.getInstance()
        .notificationService
        .subscribe(regex: MixedConstants.appNamespace, shouldDecrypt: true)
        .listen((AtNotification notification) async {
      await _notificationCallBack(notification);
    });
  }

  setPeriodicFileHistoryRefresh() {
    periodicHistoryRefresh?.cancel();
    periodicHistoryRefresh = Timer.periodic(Duration(minutes: 1), (timer) {
      refreshHistoryScreen();
    });
  }

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
      var decryptedMessage = response.value!;

      if (decryptedMessage != null && decryptedMessage != '') {
        DownloadAcknowledgement downloadAcknowledgement =
            DownloadAcknowledgement.fromJson(jsonDecode(decryptedMessage));

        await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .updateDownloadAcknowledgement(downloadAcknowledgement, fromAtSign);
      }
      return;
    }

    if (notificationKey.contains(MixedConstants.FILE_TRANSFER_KEY) &&
        !notificationKey
            .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT)) {
      var atKey = notificationKey.split(':')[1];
      var decryptedMessage = response.value!;

      //TODO: only for testing
      // await sendNotificationAck(notificationKey, fromAtSign);

      if (decryptedMessage != null && decryptedMessage != '') {
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .checkForUpdatedOrNewNotification(fromAtSign, decryptedMessage);

        Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
                listen: false)
            .checkForUndownloadedFiles();

        BuildContext context = NavService.navKey.currentContext!;
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

  sendNotificationAck(String key, String fromAtsign) async {
    try {
      String transferId = key.split(':')[1];
      transferId = transferId.split('@')[0];
      transferId = transferId.replaceAll('.mospherepro', '');
      transferId = transferId.replaceAll('file_transfer_', '');
      AtKey atKey = AtKey()
        ..key = 'receive_ack_$transferId'
        ..sharedWith = fromAtsign
        ..metadata = Metadata()
        ..metadata!.ttr = -1
        ..metadata!.ttl = 518400000;

      var notificationResult =
          await AtClientManager.getInstance().notificationService.notify(
                NotificationParams.forUpdate(
                  atKey,
                  value: 'receive_ack_$key',
                ),
              );
    } catch (e) {
      print('error in ack: $e');
      ExceptionService.instance.showNotifyExceptionOverlay(e);
    }
  }

  downloadFiles(BuildContext context, String key, String fromAtSign) async {
    var historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    var result = await historyProvider.downloadFiles(
      key,
      fromAtSign,
      false,
    );
    if (result is bool && result) {
      var i = historyProvider.receivedHistoryLogs
          .indexWhere((element) => element.key == key);
      if (i != -1) {
        await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                listen: false)
            .saveNewDataInMyFiles(historyProvider.receivedHistoryLogs[i]);
      }
    } else if (result is bool && !result) {}
  }

  syncWithSecondary() async {
    AtSyncUIService().init(
      appNavigator: NavService.navKey,
      onSuccessCallback: _onSuccessCallback,
      onErrorCallback: _onSyncErrorCallback,
      onAtSignRemoved: CommonUtilityFunctions().onboardNextAtsign,
      primaryColor: ColorConstants.orangeColor,
    );

    AtSyncUIService().sync(
      atSyncUIOverlay: AtSyncUIOverlay.dialog,
      startTimer: true,
    );
  }

  _onSuccessCallback(SyncResult syncStatus) async {
    // removes failed snackbar message.
    ScaffoldMessenger.of(NavService.navKey.currentContext!)
        .hideCurrentSnackBar();

    var historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentState!.context,
        listen: false);

    var myFilesProvider = Provider.of<MyFilesProvider>(
        NavService.navKey.currentContext!,
        listen: false);

    print(
        'syncStatus type : $syncStatus, datachanged : ${syncStatus.dataChange}');
    if (!historyProvider.isSyncedDataFetched) {
      await Provider.of<TrustedContactProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .resetData();
      await Provider.of<TrustedContactProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .getTrustedContact();

      historyProvider.isSyncedDataFetched = true;
      await VersionService.getInstance().init();

      if (historyProvider.status[historyProvider.DOWNLOAD_ACK] !=
          Status.Loading) {
        await historyProvider.getFileDownloadedAcknowledgement();
      }

      if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
          Status.Loading) {
        await historyProvider.getReceivedHistory();
        await historyProvider.downloadAllTrustedSendersData();
      }

      if (historyProvider.status[historyProvider.SENT_HISTORY] !=
          Status.Loading) {
        await historyProvider.getSentHistory();
      }

      await myFilesProvider.init();

      Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
              listen: false)
          .checkForUndownloadedFiles();

      setPeriodicFileHistoryRefresh();
    }
  }

  _onSyncErrorCallback(SyncResult syncStatus) async {
    print('sync failed : ${syncStatus}');
    ScaffoldMessenger.of(NavService.navKey.currentContext!).showSnackBar(
      SnackBar(
        duration: Duration(days: 365),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TextStrings().syncFailed, style: CustomTextStyles.grey15),
              InkWell(
                onTap: () async {
                  ScaffoldMessenger.of(NavService.navKey.currentContext!)
                      .hideCurrentSnackBar();
                  AtSyncUIService().sync();
                },
                child: Text(TextStrings().retry,
                    style: CustomTextStyles.whiteBold16),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>?> getAtsignList() async {
    var atSignsList =
        await KeyChainManager.getInstance().getAtSignListFromKeychain();
    return atSignsList;
  }

  deleteAtSignFromKeyChain(String atsign) async {
    List<String>? atSignList = await getAtsignList();

    await KeychainUtil.deleteAtSignFromKeychain(atsign);

    if (atSignList != null) {
      atSignList.removeWhere((element) => element == atsign);
    }
    late var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);

    var tempAtsign;
    if (atSignList == null || atSignList.isEmpty) {
      tempAtsign = '';
    } else {
      tempAtsign = atSignList.first;
    }

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      /// in case of desktop, we close the dialog from here
      Navigator.of(NavService.navKey.currentContext!).pop();
    }

    if (tempAtsign == '') {
      if (Platform.isAndroid || Platform.isIOS) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext!,
            Routes.HOME,
            (Route<dynamic> route) => false);
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext!,
            DesktopRoutes.DESKTOP_HOME,
            (Route<dynamic> route) => false);
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      final result = await AtOnboarding.onboard(
        context: NavService.navKey.currentContext!,
        config: AtOnboardingConfig(
          atClientPreference: atClientPrefernce!,
          domain: MixedConstants.ROOT_DOMAIN,
          rootEnvironment: RootEnvironment.Production,
          appAPIKey: MixedConstants.ONBOARD_API_KEY,
        ),
      );
      switch (result.status) {
        case AtOnboardingResultStatus.success:
          final OnboardingService onboardingService =
              OnboardingService.getInstance();
          final value = onboardingService.atClientServiceMap;
          await onboardSuccessCallback(
              value, result.atsign!, atClientPrefernce);
          break;
        case AtOnboardingResultStatus.error:
          SnackbarService().showSnackbar(
            NavService.navKey.currentContext!,
            (result.message ?? '').isNotEmpty ? '' : 'Onboarding failed.',
            bgColor: ColorConstants.redAlert,
          );
          break;
        case AtOnboardingResultStatus.cancel:
          // TODO: Handle this case.
          break;
      }
    } else {
      CustomOnboarding.onboard(
          atSign: tempAtsign, atClientPrefernce: atClientPrefernce);
    }
  }

  bool authenticating = false;

  checkToOnboard({
    String? atSign,
    bool isSwitchAccount = false,
  }) async {
    try {
      final OnboardingService _onboardingService =
          OnboardingService.getInstance();
      late var atClientPrefernce;
      AtOnboardingResult result;

      if ((atSign ?? '').isNotEmpty) {
        _onboardingService.setAtsign = atSign;
      }

      //  await getAtClientPreference();
      await getAtClientPreference()
          .then((value) => atClientPrefernce = value)
          .catchError((e) => print(e));

      authenticating = false;
      isAuthuneticatingSink.add(authenticating);

      result = await AtOnboarding.onboard(
        context: NavService.navKey.currentContext!,
        config: AtOnboardingConfig(
          atClientPreference: atClientPrefernce!,
          domain: MixedConstants.ROOT_DOMAIN,
          rootEnvironment: RootEnvironment.Production,
          appAPIKey: MixedConstants.ONBOARD_API_KEY,
        ),
        isSwitchingAtsign: isSwitchAccount,
      );

      switch (result.status) {
        case AtOnboardingResultStatus.success:
          final value = _onboardingService.atClientServiceMap;
          authenticating = true;
          isAuthuneticatingSink.add(authenticating);
          await onboardSuccessCallback(
              value, result.atsign!, atClientPrefernce);
          authenticating = false;
          isAuthuneticatingSink.add(authenticating);
          break;
        case AtOnboardingResultStatus.error:
          var isConnected = Provider.of<InternetConnectivityChecker>(
                  NavService.navKey.currentContext!,
                  listen: false)
              .isInternetAvailable;

          SnackbarService().showSnackbar(NavService.navKey.currentContext!,
              !isConnected ? TextStrings.noInternetMsg : 'Onboarding failed.',
              bgColor: ColorConstants.redAlert);
          authenticating = false;
          isAuthuneticatingSink.add(authenticating);
          break;
        case AtOnboardingResultStatus.cancel:
          authenticating = false;
          isAuthuneticatingSink.add(authenticating);
          break;
      }

      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    } catch (e) {
      authenticating = false;
      isAuthuneticatingSink.add(authenticating);
    }
  }

  onboardSuccessCallback(Map<String?, AtClientService> atClientServiceMap,
      String onboardedAtsign, AtClientPreference atClientPreference) async {
    // setting client service and manager
    await AtClientManager.getInstance().setCurrentAtSign(
        onboardedAtsign, MixedConstants.appNamespace, atClientPreference);
    atClientServiceInstance = atClientServiceMap[onboardedAtsign];
    atClientServiceMap = atClientServiceMap;
    currentAtSign = onboardedAtsign;

    // clearing file and contact informations.
    Provider.of<WelcomeScreenProvider>(NavService.navKey.currentState!.context,
            listen: false)
        .selectedContacts = [];
    Provider.of<FileTransferProvider>(NavService.navKey.currentState!.context,
            listen: false)
        .selectedFiles = [];
    Provider.of<HistoryProvider>(NavService.navKey.currentState!.context,
            listen: false)
        .resetData();

    await KeychainUtil.makeAtSignPrimary(onboardedAtsign);
    startMonitor();
    syncWithSecondary();

    // start monitor and package initializations.
    initLocalNotification();
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);

    await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
        Routes.WELCOME_SCREEN, (Route<dynamic> route) => false);
  }

  String? state;
  late LocalNotificationService _notificationService;

  void initLocalNotification() async {
    _notificationService = LocalNotificationService();
    _notificationService.cancelNotifications();
    _notificationService.setOnNotificationClick(onNotificationClick);

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels> $msg');
      app_lifecycle_state = msg;

      return null;
    } as dynamic);
  }

  setDownloadDirectory() async {
    var _preference = await getAtClientPreference();
    MixedConstants.setNewApplicationDocumentsDirectory(
        AtClientManager.getInstance().atClient.getCurrentAtSign());
    _preference.downloadPath = MixedConstants.RECEIVED_FILE_DIRECTORY;
    AtClientManager.getInstance().atClient.setPreferences(_preference);
  }

  /// to create directory if does not exist
  doesDirectoryExist({String? path}) async {
    final dir =
        Directory(path ?? MixedConstants.ApplicationDocumentsDirectory!);
    if ((await dir.exists())) {
    } else {
      await dir.create();
    }
  }

  onNotificationClick(String payload) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Navigator.push(
        NavService.navKey.currentContext!,
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

  showToast(String msg, {bool isError = false, bool isSuccess = true}) {
    ErrorDialog().show(msg, context: NavService.navKey.currentContext);
  }

  refreshHistoryScreen() async {
    var historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    historyProvider.setStatus(historyProvider.PERIODIC_REFRESH, Status.Loading);

    if (historyProvider.status[historyProvider.RECEIVED_HISTORY] !=
        Status.Loading) {
      await historyProvider.refreshReceivedFile(setLoading: false);
    }
    historyProvider.setStatus(historyProvider.PERIODIC_REFRESH, Status.Done);
  }
}
