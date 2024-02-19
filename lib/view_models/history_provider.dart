import 'dart:convert';
import 'dart:io';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_entity.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_object.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_recent.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/exception_service.dart';
import 'package:atsign_atmosphere_pro/services/file_transfer_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/local_notification_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_download_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart'
    as notificationService;
import 'trusted_sender_view_model.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  String PERIODIC_REFRESH = 'periodic_refresh';
  String RECENT_HISTORY = 'recent_history';
  String ADD_RECEIVED_FILE = 'add_received_file';
  String UPDATE_RECEIVED_RECORD = 'update_received_record';
  String SET_FILE_HISTORY = 'set_flie_history';
  String SET_RECEIVED_HISTORY = 'set_received_history';
  String GET_ALL_FILE_DATA = 'get_all_file_data';
  String GET_ALL_FILE_HISTORY = 'get_all_file_history';
  String GET_FILE_STATUS = 'get_file_status';
  String DOWNLOAD_FILE = 'download_file';
  String DOWNLOAD_ACK = 'download_ack';

  List<FileHistory> sentHistory = [],
      tempSentHistory = [],
      receivedFileHistory = [],
      allFilesHistory = [];

  List<FileType> listType = FileType.values.toList();

  List<FileTransfer> receivedHistoryLogs = [];

  Map<String?, Map<String, bool>> downloadedFileAcknowledgement = {};
  Map<String?, bool> individualSentFileId = {}, receivedItemsId = {};
  List<String> downloadingFilesList = [];
  String? state;
  String _historySearchText = '';
  bool isDesc = true;
  bool hadNewFile = false;
  bool isDownloadDone = false;

  List<FileEntity> allFiles = [];

  // on first transfer history fetch, we show loader in history screen.
  // on second attempt we keep the status as idle.
  bool isSyncedDataFetched = false;
  List<FilesDetail>? sentPhotos,
      sentVideos,
      sentAudio,
      sentApk,
      sentDocument = [];

  List<FilesDetail> recentFile = [];
  List<Widget> desktopTabs = [DesktopRecents()];
  Map sendFileHistory = {'history': []};
  String? app_lifecycle_state;
  HistoryType typeSelected = HistoryType.received;

  FileHistory? selectedFileHistory;

  resetData() {
    isSyncedDataFetched = false;
    sentHistory = [];
    receivedHistoryLogs = [];
    sendFileHistory = {'history': []};
    downloadedFileAcknowledgement = {};
    downloadingFilesList = [];
    recentFile = [];
    individualSentFileId = {};
    receivedItemsId = {};
    tempSentHistory = [];
    receivedFileHistory = [];
    allFilesHistory = [];
    listType = FileType.values.toList();
    notifyListeners();
  }

  String get getSearchText => _historySearchText;

  set setHistorySearchText(String txt) {
    _historySearchText = txt.trim().toLowerCase();
    notifyListeners();
  }

  void changeIsUpcomingEvent() {
    hadNewFile = !hadNewFile;
    notifyListeners();
  }

  void resetOptional() {
    listType = FileType.values.toList();
    notifyListeners();
  }

  void resetIsDownloadDone() {
    isDownloadDone = false;
    notifyListeners();
  }

  void setSelectedType(HistoryType type) {
    typeSelected = type;
    notifyListeners();
  }

  void updateListType(List<FileType> newList) {
    listType = newList;
    notifyListeners();
  }

  void setSelectedFileHistory(FileHistory? fileHistory) {
    selectedFileHistory = fileHistory;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  void addDownloadingState(String key) {
    if (!downloadingFilesList.contains(key)) {
      downloadingFilesList.add(key);
    }
    notifyListeners();
  }

  void removeDownloadingState(String key) {
    if (downloadingFilesList.contains(key)) {
      downloadingFilesList.remove(key);
    }
    notifyListeners();
  }

  updateFileHistoryDetail(FileHistory fileHistory) async {
    // checking whether sent file is stored in individual atKey or in sentHistory list.
    if (individualSentFileId[fileHistory.fileDetails!.key] != null) {
      await saveIndividualSentItemInAtkey(fileHistory, isEdit: true);
      return;
    }

    // if file is not saved individually, we will update file index in sent history list.
    int index = sentHistory.indexWhere((element) =>
        element.fileDetails!.key.contains(fileHistory.fileDetails!.key));

    var result = false;
    if (index > -1) {
      sentHistory[index] = fileHistory;
      updateSendFileHistoryArray(fileHistory);

      result = await updateSentHistory();
      notifyListeners();
    }
    return result;
  }

  saveNewSentFileItem(
      FileTransferObject fileTransferObject,
      List<String> sharedWithAtsigns,
      Map<String, FileTransferObject> fileShareResult,
      {bool isEdit = false,
      String? groupName}) async {
    FileHistory fileHistory = convertFileTransferObjectToFileHistory(
      fileTransferObject,
      sharedWithAtsigns,
      fileShareResult,
      groupName: groupName,
    );

    return await saveIndividualSentItemInAtkey(fileHistory);
  }

  /// if [fileHistory.fileDetails.key] is unique, a new AtKey will be created
  /// otherwise the same AtKey will be updated with the new [fileHistory] data.
  Future<bool> saveIndividualSentItemInAtkey(FileHistory fileHistory,
      {bool isEdit = false}) async {
    AtKey atKey = AtKey()
      ..key = fileHistory.fileDetails!.key
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..metadata!.ccd = true
      // key will be deleted after 15 days.
      ..metadata!.ttl = 1296000000; // 1000 * 60 * 60 * 24 * 15

    try {
      var res = await AtClientManager.getInstance().atClient.put(
          atKey,
          json.encode(
            fileHistory.toJson(),
          ));
      if (res) {
        individualSentFileId[fileHistory.fileDetails!.key] = true;
        if (isEdit) {
          updateFileEntryInSentHistory(fileHistory);
        } else {
          sentHistory.insert(0, fileHistory);

          //
          FileTransfer? fileTransfer = fileHistory.fileDetails;
          if ((fileTransfer?.files?.length ?? 0) > 0) {
            for (int j = 0; j < fileTransfer!.files!.length; j++) {
              for (int k = 0; k < fileHistory.sharedWith!.length; k++) {
                allFiles.insert(
                  0,
                  FileEntity(
                      file: fileTransfer.files![j],
                      date: fileTransfer.date != null
                          ? fileTransfer.date.toString()
                          : '',
                      atSign: fileHistory.sharedWith![k].atsign,
                      historyType: HistoryType.send,
                      note: fileTransfer.notes,
                      transferId: fileTransfer.key,
                      isUploaded: fileTransfer.files?[j].isUploaded ?? false,
                      fileTransferObject: fileHistory.fileTransferObject!),
                );
              }
            }
          }
          allFilesHistory.insert(0, fileHistory); // for desktop
        }
      }

      notifyListeners();
      return res;
    } catch (e) {
      ExceptionService.instance.showPutExceptionOverlay(e);
      print('exception in adding new sent history : $e');
      return false;
    }
  }

  // sent files are stored in two ways
  // old approach---------
  // 1 -- `sentHistory_v2` key stores list of all sent items.

  // with new approach we are saving data in individual keys
  // 2 -- every sent file data is stored individually in `file_transfer_[ID]` key.
  /// [getSentHistory] will get data from both keys and store them into [sentHistory] variable.
  getSentHistory({
    bool setLoading = true,
    List<FileType>? listFileTypeSelect,
  }) async {
    if (setLoading) {
      setStatus(SENT_HISTORY, Status.Loading);
    }

    // checking, if new keys are available to show in sent history
    AtClient atClient = AtClientManager.getInstance().atClient;
    List<AtKey> sentFileAtkeys = await atClient.getAtKeys(
      regex: MixedConstants.FILE_TRANSFER_KEY,
      sharedBy: atClient.getCurrentAtSign(),
    );

    sentFileAtkeys.retainWhere(
      (element) =>
          !element.key!
              .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT) &&
          compareAtSign(element.sharedBy!, atClient.getCurrentAtSign()!),
    );

    bool isNewKeyAvailable = false;

    sentFileAtkeys.forEach((AtKey atkey) {
      if (individualSentFileId[atkey.key] == null) {
        isNewKeyAvailable = true;
      }
      individualSentFileId[atkey.key] = true;
    });

    // if (!isNewKeyAvailable) {
    //   setStatus(SENT_HISTORY, Status.Done);
    //   return;
    // }

    tempSentHistory = [];

    try {
      AtKey key = AtKey()
        ..key = MixedConstants.SENT_FILE_HISTORY
        ..sharedBy = AtClientManager.getInstance().atClient.getCurrentAtSign()
        ..metadata = Metadata();

      var keyValue =
          await AtClientManager.getInstance().atClient.get(key).catchError((e) {
        print('error in getSentHistory : $e');
        return AtValue();
      });

      if (keyValue != null && keyValue.value != null) {
        try {
          Map historyFile = json.decode((keyValue.value) as String) as Map;
          sendFileHistory['history'] = historyFile['history'];

          historyFile['history'].forEach(
            (value) {
              FileHistory filesModel = FileHistory.fromJson(value);
              // checking for download acknowledged
              filesModel.sharedWith = checkIfileDownloaded(
                filesModel.sharedWith,
                filesModel.fileTransferObject!.transferId,
              );

              if ((listFileTypeSelect ?? []).isNotEmpty) {
                List<FileData> files = [];

                if ((filesModel.fileDetails?.files ?? []).isNotEmpty) {
                  Future.forEach(
                    filesModel.fileDetails!.files!,
                    (FileData file) async {
                      String? fileExtension = file.name?.split('.').last;
                      for (int i = 0; i < listFileTypeSelect!.length; i++) {
                        if (FileTypes.ALL_TYPES.contains(fileExtension)) {
                          if (listFileTypeSelect[i]
                              .suffixName
                              .contains(fileExtension)) {
                            files.add(file);
                            break;
                          } else {
                            break;
                          }
                        }
                        if (listFileTypeSelect[i] == FileType.other) {
                          files.add(file);
                          break;
                        }
                      }
                    },
                  );
                }

                if (files.isNotEmpty) {
                  filesModel.fileDetails?.files = files;
                  tempSentHistory.add(filesModel);
                }
              } else {
                tempSentHistory.add(filesModel);
              }
            },
          );
        } catch (e) {
          print('error in file model conversion in getSentHistory: $e');
        }
      }

      // fetching individually saved sent items.
      await getIndividuallySavedSentFileItems();
      sentHistory = tempSentHistory;
      // deleting sent items records, older than 15 days.
      await removePastSentFiles();
      sortSentItems();

      setStatus(SENT_HISTORY, Status.Done);
    } catch (error) {
      ExceptionService.instance.showPutExceptionOverlay(error);
      setError(SENT_HISTORY, error.toString());
    }
  }

  getIndividuallySavedSentFileItems() async {
    AtClient atClient = AtClientManager.getInstance().atClient;
    List<AtKey> sentFileAtkeys = await atClient.getAtKeys(
      regex: MixedConstants.FILE_TRANSFER_KEY,
      sharedBy: atClient.getCurrentAtSign(),
    );

    sentFileAtkeys.retainWhere(
      (element) =>
          !element.key!
              .contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT) &&
          compareAtSign(element.sharedBy!, atClient.getCurrentAtSign()!),
    );

    await Future.forEach(sentFileAtkeys, (AtKey atkey) async {
      AtValue atvalue =
          await AtClientManager.getInstance().atClient.get(atkey).catchError(
        (e) {
          print("Exception in getting atValue: $e");
          //// Removing exception as called in a loop
          // ExceptionService.instance.showGetExceptionOverlay(e);
          return AtValue();
        },
      );

      if (atvalue != null && atvalue.value != null) {
        try {
          FileHistory fileHistory = FileHistory.fromJson(
            jsonDecode(atvalue.value),
          );
          individualSentFileId[fileHistory.fileDetails!.key] = true;
          tempSentHistory.insert(0, fileHistory);
        } catch (e) {
          print('exeption in getSentFileItems : $e');
        }
      }
    });
  }

// deletes sent items which are older that 15 days
  removePastSentFiles() async {
    List<String> idsToDelete = [];
    for (int i = 0; i < sentHistory.length; i++) {
      FileHistory fileHistory = sentHistory[i];
      var sentFileDeletionDate =
          fileHistory.fileDetails!.date!.add(Duration(days: 15));
      if (sentFileDeletionDate.difference(DateTime.now()) <
          Duration(seconds: 0)) {
        idsToDelete.add(sentHistory[i].fileDetails!.key);
      }
    }

    idsToDelete.forEach((String id) {
      var index =
          sentHistory.indexWhere((element) => element.fileDetails!.key == id);
      if (index > -1) {
        updateSendFileHistoryArray(sentHistory[index], isDelete: true);
        sentHistory.removeAt(index);
      }
    });

    await updateSentHistory();
  }

  sortSentItems() {
    sentHistory
        .sort((a, b) => b.fileDetails!.date!.compareTo(a.fileDetails!.date!));
  }

  List<ShareStatus>? checkIfileDownloaded(
      List<ShareStatus>? shareStatus, String transferId) {
    if (downloadedFileAcknowledgement[transferId] != null) {
      for (int i = 0; i < shareStatus!.length; i++) {
        if (downloadedFileAcknowledgement[transferId]![
                shareStatus[i].atsign!] !=
            null) {
          shareStatus[i].isFileDownloaded = true;
        }
      }
    }
    return shareStatus;
  }

  deleteSentItem(String? transferId) async {
    int index = sentHistory.indexWhere((element) {
      return element.fileDetails?.key == transferId;
    });
    FileHistory? fileHistory;
    if (index != -1) {
      fileHistory = sentHistory[index];
    }

    if (fileHistory != null &&
        individualSentFileId[fileHistory.fileDetails!.key] != null) {
      await deleteIndividualSentItem(fileHistory);
      return;
    }

    if (index != -1) {
      sentHistory.removeWhere((element) {
        return element.fileDetails?.key == transferId;
      });
      notifyListeners();
      updateSendFileHistoryArray(fileHistory, isDelete: true);

      var res = await updateSentHistory();
      if (res) {
        notifyListeners();
        return res;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteReceivedItem(FileTransfer fileTransfer) async {
    var atKey = AtKey()
      ..key = fileTransfer.key
      ..sharedBy = fileTransfer.sender
      ..sharedWith = AtClientManager.getInstance().atClient.getCurrentAtSign()
      ..metadata = (Metadata()..isCached = true);

    var res = await AtClientManager.getInstance().atClient.delete(atKey);
    if (res) {
      var i = receivedHistoryLogs.indexWhere(
        (element) => element.key == fileTransfer.key,
      );

      if (i != -1) {
        receivedHistoryLogs.removeAt(i);
        notifyListeners();
      }
      return res;
    } else {
      return res;
    }
  }

  getFileDownloadedAcknowledgement() async {
    setStatus(DOWNLOAD_ACK, Status.Loading);
    var atKeys = await AtClientManager.getInstance()
        .atClient
        .getAtKeys(regex: MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT);
    atKeys.retainWhere((element) => !compareAtSign(element.sharedBy!,
        AtClientManager.getInstance().atClient.getCurrentAtSign()!));

    await Future.forEach(atKeys, (AtKey atKey) async {
      try {
        AtValue atValue = await AtClientManager.getInstance()
            .atClient
            .get(atKey)
            .catchError((e) {
          print('error in get in getFileDownloadedAcknowledgement : $e');
          //// Removing exception as called in a loop
          // ExceptionService.instance.showGetExceptionOverlay(e);
          return AtValue();
        });
        if (atValue.value != null) {
          var downloadAcknowledgement =
              DownloadAcknowledgement.fromJson(jsonDecode(atValue.value));

          if (downloadedFileAcknowledgement[
                  downloadAcknowledgement.transferId] !=
              null) {
            downloadedFileAcknowledgement[downloadAcknowledgement.transferId]![
                formatAtsign(atKey.sharedBy!)] = true;
          } else {
            downloadedFileAcknowledgement[downloadAcknowledgement.transferId] =
                {formatAtsign(atKey.sharedBy!): true};
          }
        }
      } catch (e) {
        print('error in getFileDownloadedAcknowledgement : $e');
        setStatus(DOWNLOAD_ACK, Status.Error);
      }
    });
    setStatus(DOWNLOAD_ACK, Status.Done);
  }

  getReceivedHistory({bool setLoading = true}) async {
    if (setLoading) {
      setStatus(RECEIVED_HISTORY, Status.Loading);
    }

    try {
      await getAllFileTransferData();
      sortReceivedNotifications();
      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      ExceptionService.instance.showPutExceptionOverlay(error);
      setStatus(RECEIVED_HISTORY, Status.Error);
      setError(RECEIVED_HISTORY, error.toString());
    }
  }

  Future<void> downloadAllTrustedSendersData() async {
    var isTrustedSender = false;

    for (var value in receivedHistoryLogs) {
      isTrustedSender = false;

      for (var _contact in Provider.of<TrustedContactProvider>(
              NavService.navKey.currentContext!,
              listen: false)
          .trustedContacts) {
        if (_contact.atSign == value.sender) {
          isTrustedSender = true;
          break;
        }
      }

      if (isTrustedSender && (value.files ?? []).isNotEmpty) {
        var _isFileDownloaded =
            await isFileDownloaded(value.sender, value.files![0]);

        /// only check for one file and download entire zip if one is not present
        if (!_isFileDownloaded) {
          await downloadFiles(
            value.key,
            value.sender!,
            false,
          ).then((value) {
            if (value) {
              isDownloadDone = true;
              notifyListeners();
            }
          });
        }
      }
    }
  }

  Future<bool> isFileDownloaded(String? sender, FileData _fileData) async {
    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      path = MixedConstants.RECEIVED_FILE_DIRECTORY +
          Platform.pathSeparator +
          (sender ?? '') +
          Platform.pathSeparator +
          (_fileData.name ?? '');
    } else {
      path = BackendService.getInstance().downloadDirectory!.path +
          Platform.pathSeparator +
          (_fileData.name ?? '');
    }
    File test = File(path);
    bool fileExists = await test.exists();

    return fileExists;
  }

  checkForUpdatedOrNewNotification(String sharedBy, String decodedMsg) async {
    setStatus(UPDATE_RECEIVED_RECORD, Status.Loading);
    FileTransferObject fileTransferObject =
        FileTransferObject.fromJson((jsonDecode(decodedMsg)))!;
    FileTransfer filesModel =
        convertFiletransferObjectToFileTransfer(fileTransferObject);
    filesModel.sender = sharedBy;

    //check id data with same key already present
    var index = receivedHistoryLogs
        .indexWhere((element) => element.key == fileTransferObject.transferId);
    _initBackendService();
    if (index > -1) {
      receivedHistoryLogs[index] = filesModel;

      // converting received files into single entries before displaying in transfer history
      if ((filesModel.files?.length ?? 0) > 0) {
        for (int j = 0; j < filesModel.files!.length; j++) {
          allFiles.insert(
            0,
            FileEntity(
              file: filesModel.files![j],
              date: filesModel.date != null ? filesModel.date.toString() : '',
              atSign: filesModel.sender,
              historyType: HistoryType.received,
              note: filesModel.notes,
              transferId: filesModel.key,
              isUploaded: filesModel.files?[j].isUploaded ?? false,
              fileTransferObject: fileTransferObject,
            ),
          );
        }
      }
    } else {
      String nickName = '';
      var displayDetails = await getAtSignDetails(sharedBy);
      if (displayDetails.tags != null) {
        nickName = displayDetails.tags!['nickname'] ??
            displayDetails.tags!['name'] ??
            sharedBy;
      }
      // showing notification for new recieved file
      switch (app_lifecycle_state) {
        case 'AppLifecycleState.resumed':
        case 'AppLifecycleState.inactive':
        case 'AppLifecycleState.detached':
          await LocalNotificationService()
              .showNotification(nickName, 'Download and view the file(s).');
          break;
        case 'AppLifecycleState.paused':
          await LocalNotificationService().showNotification(
              nickName, 'Open the app to download and view the file(s).');
          break;
        default:
          await LocalNotificationService()
              .showNotification(nickName, 'Download and view the file(s).');
      }

      var fileHistory = FileHistory(
        filesModel,
        [],
        HistoryType.received,
        fileTransferObject,
      );

      Provider.of<notificationService.NotificationService>(
              NavService.navKey.currentContext!,
              listen: false)
          .addRecentNotifications(fileHistory);

      await addToReceiveFileHistory(
        sharedBy,
        filesModel,
        fileTransferObject: fileTransferObject,
      );
      receivedFileHistory.insert(0, fileHistory);
      allFilesHistory.insert(0, fileHistory);
    }
    setStatus(UPDATE_RECEIVED_RECORD, Status.Done);
  }

  void _initBackendService() async {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels=> $msg');
      app_lifecycle_state = msg;

      return msg;
    });
  }

  addToReceiveFileHistory(
    String sharedBy,
    FileTransfer filesModel, {
    bool isUpdate = false,
    required FileTransferObject fileTransferObject,
  }) async {
    setStatus(ADD_RECEIVED_FILE, Status.Loading);
    filesModel.sender = sharedBy;

    if (filesModel.isUpdate!) {
      int index = receivedHistoryLogs.indexWhere(
          (FileTransfer element) => element.key.contains(filesModel.key));
      if (index > -1) {
        receivedHistoryLogs[index] = filesModel;
      }
    } else {
      receivedHistoryLogs.insert(0, filesModel);
      receivedItemsId[filesModel.key] = true;

      if ((filesModel.files?.length ?? 0) > 0) {
        for (int j = 0; j < filesModel.files!.length; j++) {
          allFiles.insert(
            0,
            FileEntity(
              file: filesModel.files![j],
              date: filesModel.date != null ? filesModel.date.toString() : '',
              atSign: filesModel.sender,
              historyType: HistoryType.received,
              note: filesModel.notes,
              transferId: filesModel.key,
              isUploaded: filesModel.files?[j].isUploaded ?? false,
              fileTransferObject: fileTransferObject,
            ),
          );
        }
      }
    }

    setStatus(ADD_RECEIVED_FILE, Status.Done);
  }

  updateDownloadAcknowledgement(
      DownloadAcknowledgement downloadAcknowledgement, String sharedBy) async {
    var index = sentHistory.indexWhere((element) =>
        element.fileDetails!.key == downloadAcknowledgement.transferId);
    if (index > -1) {
      var i = sentHistory[index]
          .sharedWith!
          .indexWhere((element) => element.atsign == sharedBy);
      sentHistory[index].sharedWith![i].isFileDownloaded = true;
      await updateFileHistoryDetail(sentHistory[index]);
    }
  }

  Future<void> getAllFileTransferData({
    List<FileType>? listFileTypeSelect,
  }) async {
    setStatus(GET_ALL_FILE_DATA, Status.Loading);
    List<FileTransfer> tempReceivedHistoryLogs = [];
    List<FileHistory> tempReceivedFiles = [];

    List<AtKey> fileTransferAtkeys =
        await AtClientManager.getInstance().atClient.getAtKeys(
              regex: MixedConstants.FILE_TRANSFER_KEY,
            );

    fileTransferAtkeys.retainWhere((element) =>
        !element.key!.contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT));

    bool isNewKeyAvailable = false;
    fileTransferAtkeys.forEach((AtKey atkey) {
      if (receivedItemsId[atkey.key] == null) {
        isNewKeyAvailable = true;
      }
      receivedItemsId[atkey.key] = true;
    });

    if (!isNewKeyAvailable) {
      return;
    }

    for (var atKey in fileTransferAtkeys) {
      var isCurrentAtsign = compareAtSign(
          atKey.sharedBy!, BackendService.getInstance().currentAtSign!);

      if (!isCurrentAtsign && !checkRegexFromBlockedAtsign(atKey.sharedBy!)) {
        receivedItemsId[atKey.key] = true;

        AtValue atvalue =
            await AtClientManager.getInstance().atClient.get(atKey).catchError(
          (e) {
            print("error in getting atValue in getAllFileTransferData : $e");
            return AtValue();
          },
        );

        if (atvalue.value != null) {
          try {
            FileTransferObject fileTransferObject =
                FileTransferObject.fromJson(jsonDecode(atvalue.value))!;
            FileTransfer filesModel =
                convertFiletransferObjectToFileTransfer(fileTransferObject);
            filesModel.sender = atKey.sharedBy!;

            if ((listFileTypeSelect ?? []).isNotEmpty) {
              List<FileData> files = [];

              if ((filesModel.files ?? []).isNotEmpty) {
                await Future.forEach(
                  filesModel.files!,
                  (FileData file) async {
                    String? fileExtension = file.name?.split('.').last;
                    for (int i = 0; i < listFileTypeSelect!.length; i++) {
                      if (FileTypes.ALL_TYPES.contains(fileExtension)) {
                        if (listFileTypeSelect[i]
                            .suffixName
                            .contains(fileExtension)) {
                          files.add(file);
                          break;
                        } else {
                          break;
                        }
                      }
                      if (listFileTypeSelect[i] == FileType.other) {
                        files.add(file);
                        break;
                      }
                      print(file);
                    }
                  },
                );
              }

              if (files.isNotEmpty) {
                filesModel.files = files;
                tempReceivedHistoryLogs.insert(0, filesModel);
                final file = FileHistory(
                  filesModel,
                  [],
                  HistoryType.received,
                  fileTransferObject,
                );
                tempReceivedFiles.insert(0, file);
              }
            } else {
              if (filesModel.key != null) {
                tempReceivedHistoryLogs.insert(0, filesModel);
              }

              final file = FileHistory(
                filesModel,
                [],
                HistoryType.received,
                fileTransferObject,
              );

              if (filesModel.key != null) {
                tempReceivedFiles.insert(0, file);
              }
            }
          } catch (e) {
            print('error in getAllFileTransferData file model conversion: $e');
          }
        }
      }
    }

    receivedHistoryLogs = tempReceivedHistoryLogs;
    receivedFileHistory = tempReceivedFiles;
    setStatus(GET_ALL_FILE_DATA, Status.Done);
  }

  Future<void> getAllFileTransferHistory() async {
    setStatus(GET_ALL_FILE_HISTORY, Status.Loading);
    List<FileHistory> tempFileHistoryLogs = [];
    try {
      await getSentHistory();
      await getAllFileTransferData();

      tempFileHistoryLogs.addAll(receivedFileHistory);
      tempFileHistoryLogs.addAll(sentHistory);

      tempFileHistoryLogs
          .sort((a, b) => b.fileDetails!.date!.compareTo(a.fileDetails!.date!));

      allFilesHistory = tempFileHistoryLogs;
      changeFilterType(typeSelected);

      setStatus(GET_ALL_FILE_HISTORY, Status.Done);
    } catch (e) {
      setStatus(GET_ALL_FILE_HISTORY, Status.Error);
    }
  }

  void changeFilterType(HistoryType type) {
    if (typeSelected != type) {
      listType = FileType.values.toList();
    }
    typeSelected = type;
    notifyListeners();
  }

  updateFileType(List<FileType> fileType) {
    listType = fileType;
    notifyListeners();
  }

  Future<void> filterByFileType(List<FileType> fileType) async {
    setStatus(GET_ALL_FILE_HISTORY, Status.Loading);
    listType = fileType;
    List<FileHistory> tempFileHistoryLogs = [];
    try {
      await getAllFileTransferData(listFileTypeSelect: listType);
      await getSentHistory(listFileTypeSelect: listType);

      tempFileHistoryLogs.addAll(receivedFileHistory);
      tempFileHistoryLogs.addAll(sentHistory);

      tempFileHistoryLogs
          .sort((a, b) => b.fileDetails!.date!.compareTo(a.fileDetails!.date!));

      setStatus(GET_ALL_FILE_HISTORY, Status.Done);
    } catch (e) {
      setStatus(GET_ALL_FILE_HISTORY, Status.Error);
    }
  }

  getrecentHistoryFiles() async {
    // finding last 15 received files data for recent tab
    setStatus(RECENT_HISTORY, Status.Loading);
    try {
      var lastTenFilesData = receivedHistoryLogs.sublist(
          0, receivedHistoryLogs.length > 15 ? 15 : receivedHistoryLogs.length);

      await Future.forEach(lastTenFilesData, (dynamic fileData) async {
        await Future.forEach(fileData.files, (FileData file) async {
          String filePath;

          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
            filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
                Platform.pathSeparator +
                fileData.sender +
                Platform.pathSeparator +
                (file.name ?? '');
          } else {
            filePath = BackendService.getInstance().downloadDirectory!.path +
                Platform.pathSeparator +
                (file.name ?? '');
          }

          FilesDetail fileDetail = FilesDetail(
            fileName: file.name,
            filePath: filePath,
            size: double.parse(file.size.toString()),
            date: fileData.date.toLocal().toString(),
            type: file.name!.split('.').last,
            contactName: fileData.sender,
          );

          File tempFile = File(fileDetail.filePath!);
          bool isFileDownloaded = await tempFile.exists();
          int index = recentFile
              .indexWhere((element) => element.fileName == fileDetail.fileName);

          if (isFileDownloaded && index == -1) {
            recentFile.add(fileDetail);
          }
        });
      });
      setStatus(RECENT_HISTORY, Status.Done);
    } catch (e) {
      setStatus(RECENT_HISTORY, Status.Error);
    }
  }

  sortReceivedNotifications() {
    receivedHistoryLogs.sort((a, b) => b.date!.compareTo(a.date!));
  }

  bool checkRegexFromBlockedAtsign(String atsign) {
    bool isBlocked = false;

    ContactService().blockContactList.forEach((element) {
      if (compareAtSign(element.atSign!, atsign)) {
        isBlocked = true;
      }
    });
    return isBlocked;
  }

  FileTransfer convertFiletransferObjectToFileTransfer(
      FileTransferObject fileTransferObject) {
    List<FileData> files = [];
    fileTransferObject.fileStatus.forEach((fileDetail) {
      files.add(FileData(
          name: fileDetail.fileName,
          size: fileDetail.size,
          isUploaded: fileDetail.isUploaded));
    });

    return FileTransfer(
        url: fileTransferObject.fileUrl,
        files: files,
        date: fileTransferObject.date,
        key: fileTransferObject.transferId,
        notes: fileTransferObject.notes,
        fileEncryptionKey: fileTransferObject.fileEncryptionKey);
  }

  updateFileSendingStatus(
      {bool? isUploading, bool? isUploaded, String? id, String? filename}) {
    var index =
        sentHistory.indexWhere((element) => element.fileDetails!.key == id);
    if (index > -1) {
      var fileIndex = sentHistory[index]
          .fileDetails!
          .files!
          .indexWhere((element) => element.name == filename);

      // as of now operating is only used to determine whether file is being uploaded or not
      // As per requirement it can be used to determine whether notification is being sent or not.
      sentHistory[index].isOperating = isUploading;

      if (fileIndex > -1) {
        sentHistory[index].fileDetails!.files![fileIndex].isUploading =
            isUploading;
        sentHistory[index].fileDetails!.files![fileIndex].isUploaded =
            isUploaded;
      }
    }

    /// updating file entity list, allFiles
    index = allFiles.indexWhere((el) => el.transferId == id);
    if (index != -1) {
      allFiles[index].isUploading = isUploading ?? false;
      allFiles[index].isUploaded = isUploaded ?? false;
    }

    notifyListeners();
  }

  FileHistory convertFileTransferObjectToFileHistory(
    FileTransferObject fileTransferObject,
    List<String> sharedWithAtsigns,
    Map<String, FileTransferObject> fileShareResult, {
    String? groupName,
  }) {
    List<FileData> files = [];
    var sthareStatus = <ShareStatus>[];

    fileTransferObject.fileStatus.forEach((fileDetail) {
      files.add(FileData(
          name: fileDetail.fileName,
          size: fileDetail.size,
          isUploaded: fileDetail.isUploaded));
    });

    FileTransfer fileTransfer = FileTransfer(
      key: fileTransferObject.transferId,
      date: fileTransferObject.date,
      files: files,
      url: fileTransferObject.fileUrl,
      fileEncryptionKey: fileTransferObject.fileEncryptionKey,
    );

    sharedWithAtsigns.forEach((atsign) {
      sthareStatus
          .add(ShareStatus(atsign, fileShareResult[atsign]!.sharedStatus));
    });

    return FileHistory(
      fileTransfer,
      sthareStatus,
      HistoryType.send,
      fileTransferObject,
      groupName: groupName,
      notes: fileTransferObject.notes,
    );
  }

  downloadFiles(String transferId, String sharedBy, bool isWidgetOpen,
      {String? downloadPath}) async {
    try {
      FileTransferService.getInstance()
          .updateFileTransferState('', transferId, null, FileState.processing);

      var _downloadPath;

      _downloadPath =
          await MixedConstants.getFileDownloadLocation(sharedBy: sharedBy);

      var files;
      try {
        files = await FileTransferService.getInstance().downloadFile(
          transferId,
          sharedBy,
          downloadPath: downloadPath ?? _downloadPath,
        );
      } catch (e) {
        Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
                listen: false)
            .removeReceiveProgressItem(transferId);
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          e.toString(),
          bgColor: ColorConstants.redAlert,
        );
        return false;
      }

      Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
              listen: false)
          .checkForUndownloadedFiles();

      Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
              listen: false)
          .removeReceiveProgressItem(
              transferId); //setting filetransfer progress as null
      if (files is List<File>) {
        setStatus(DOWNLOAD_FILE, Status.Done);
        return true;
      } else {
        setStatus(DOWNLOAD_FILE, Status.Done);
        return false;
      }
    } catch (e) {
      print('error in downloading file: $e');
      Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
              listen: false)
          .removeReceiveProgressItem(transferId);
      setStatus(DOWNLOAD_FILE, Status.Error);
      return false;
    }
  }

  downloadSingleFile(
    String transferId,
    String? sharedBy,
    bool? isWidgetOpen,
    String fileName,
  ) async {
    var index = allFilesHistory
        .indexWhere((element) => element.fileDetails?.key == transferId);
    var _fileIndex = allFilesHistory[index]
        .fileDetails
        ?.files!
        .indexWhere((_file) => _file.name == fileName);
    try {
      if ((index > -1) && (_fileIndex! > -1)) {
        allFilesHistory[index].fileDetails?.files![_fileIndex].isDownloading =
            true;
        allFilesHistory[index].fileDetails?.isWidgetOpen = isWidgetOpen;
      }
      notifyListeners();

      var files =
          await _downloadSingleFileFromWeb(transferId, sharedBy, fileName);
      allFilesHistory[index].fileDetails?.files![_fileIndex!].isDownloading =
          false;

      Provider.of<FileDownloadChecker>(NavService.navKey.currentContext!,
              listen: false)
          .checkForUndownloadedFiles();

      if (files is List<File>) {
        await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                listen: false)
            .saveNewDataInMyFiles(allFilesHistory[index].fileDetails!);
        setStatus(DOWNLOAD_FILE, Status.Done);
        return true;
      } else {
        setStatus(DOWNLOAD_FILE, Status.Done);
        return false;
      }
    } catch (e) {
      print('error in downloading file: $e');
      Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
              listen: false)
          .removeReceiveProgressItem(transferId);
      allFilesHistory[index].fileDetails?.files![_fileIndex!].isDownloading =
          false;
      setStatus(DOWNLOAD_FILE, Status.Error);
      return false;
    }
  }

  Future<List<File>> _downloadSingleFileFromWeb(
      String? transferId, String? sharedByAtSign, String fileName,
      {String? downloadPath}) async {
    downloadPath ??= await MixedConstants.getFileDownloadLocation(
      sharedBy: sharedByAtSign,
    );
    if (downloadPath == null) {
      throw Exception('downloadPath not found');
    }

    FileTransferObject? fileTransferObject;

    var fileEntityIndex = allFilesHistory.indexWhere(
        (element) => element.fileTransferObject?.transferId == transferId);
    if (fileEntityIndex == -1) {
      throw Exception('file object not found.');
    }

    fileTransferObject = allFilesHistory[fileEntityIndex].fileTransferObject;
    String formattedFileUrl = fileTransferObject!.fileUrl;

    try {
      formattedFileUrl = formattedFileUrl.replaceFirst('/archive', '');
      formattedFileUrl = formattedFileUrl.replaceFirst('/zip', '');
      formattedFileUrl = formattedFileUrl + '/$fileName';

      print('fileTransferObject.fileUrl ${fileTransferObject.fileUrl}');
    } on Exception catch (e) {
      throw Exception('json decode exception in download file ${e.toString()}');
    }
    updateFileTransferState(
        transferId!, FileTransferProgress(FileState.download, 0, fileName, 0));

    var downloadedFiles = <File>[];

    var tempDirectory =
        await Directory(downloadPath).createTemp('encrypted-files');
    var fileDownloadReponse =
        await FileTransferService.getInstance().downloadIndividualFile(
      formattedFileUrl,
      tempDirectory.path,
      fileName,
      transferId,
    );

    if (fileDownloadReponse.isError) {
      throw Exception('download fail');
    }
    var encryptedFileList = tempDirectory.listSync();
    try {
      for (var encryptedFile in encryptedFileList) {
        FileTransferService.getInstance().updateFileTransferState(
          fileName,
          fileTransferObject.transferId,
          null,
          FileState.decrypt,
        );

        var decryptedFile = await FileTransferService.getInstance().decryptFile(
          File(encryptedFile.path),
          fileTransferObject.fileEncryptionKey,
          BackendService.getInstance()
              .atClientPreference
              .fileEncryptionChunkSize,
        );

        decryptedFile.copySync(downloadPath +
            Platform.pathSeparator +
            encryptedFile.path.split(Platform.pathSeparator).last);
        downloadedFiles.add(File(downloadPath +
            Platform.pathSeparator +
            encryptedFile.path.split(Platform.pathSeparator).last));
        decryptedFile.deleteSync();
      }

      Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
              listen: false)
          .removeReceiveProgressItem(transferId);
      // deleting temp directory
      Directory(fileDownloadReponse.filePath!).deleteSync(recursive: true);
      tempDirectory.deleteSync(recursive: true);
      return downloadedFiles;
    } catch (e) {
      print('error in downloadFile: $e');
      return [];
    }
  }

  Future<bool> sendFileDownloadAcknowledgement(
      FileTransfer fileTransfer) async {
    var downloadAcknowledgement =
        DownloadAcknowledgement(true, fileTransfer.key);

    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..metadata!.ccd = true
      ..key = MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT + fileTransfer.key
      ..metadata!.ttl = 518400000
      ..sharedWith = fileTransfer.sender;
    try {
      var notificationResult = await AtClientManager.getInstance()
          .atClient
          .notificationService
          .notify(
            NotificationParams.forUpdate(
              atKey,
              value: jsonEncode(downloadAcknowledgement.toJson()),
            ),
          );

      if (notificationResult.notificationStatusEnum ==
          NotificationStatusEnum.delivered) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      ExceptionService.instance.showNotifyExceptionOverlay(e);
      return false;
    }
  }

  updateSendingNotificationStatus(
      String transferId, String atsign, bool isSending) {
    var index = sentHistory.indexWhere(
        (element) => element.fileTransferObject!.transferId == transferId);
    if (index != -1) {
      var atsignIndex = sentHistory[index]
          .sharedWith!
          .indexWhere((element) => element.atsign == atsign);
      if (atsignIndex != -1) {
        sentHistory[index].sharedWith![atsignIndex].isSendingNotification =
            isSending;
      }
    }
    notifyListeners();
  }

  bool compareAtSign(String atsign1, String atsign2) {
    if (atsign1[0] != '@') {
      atsign1 = '@' + atsign1;
    }
    if (atsign2[0] != '@') {
      atsign2 = '@' + atsign2;
    }

    return atsign1.toLowerCase() == atsign2.toLowerCase() ? true : false;
  }

  String formatAtsign(String atsign) {
    if (atsign[0] != '@') {
      atsign = '@' + atsign;
    }
    return atsign;
  }

  Future<bool> updateSentHistory() async {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..key = MixedConstants.SENT_FILE_HISTORY;
    AtClient atClient = AtClientManager.getInstance().atClient;
    try {
      return await atClient.put(atKey, json.encode(sendFileHistory));
    } catch (e) {
      ExceptionService.instance.showPutExceptionOverlay(e);
      print('error in update sent hisory  : $e');
      return false;
    }
  }

  updateFileEntryInSentHistory(FileHistory fileHistory,
      {bool isDelete = false}) {
    int index = sentHistory.indexWhere(
      (element) =>
          element.fileDetails!.key.contains(fileHistory.fileDetails!.key),
    );
    if (index != -1) {
      if (isDelete) {
        sentHistory.removeAt(index);
      } else {
        sentHistory[index] = fileHistory;

        FileTransfer? fileTransfer = fileHistory.fileDetails;
        if ((fileTransfer?.files?.length ?? 0) > 0) {
          for (int j = 0; j < fileTransfer!.files!.length; j++) {
            var fileEntity = FileEntity(
              file: fileTransfer.files![j],
              date:
                  fileTransfer.date != null ? fileTransfer.date.toString() : '',
              atSign: fileHistory.fileTransferObject?.sharedWith,
              historyType: HistoryType.send,
              note: fileTransfer.notes,
              transferId: fileTransfer.key,
              isUploaded: fileTransfer.files?[j].isUploaded ?? false,
              fileTransferObject: fileHistory.fileTransferObject!,
            );

            var index = allFiles.indexWhere((element) =>
                element.transferId ==
                fileHistory.fileTransferObject?.transferId);
            if (index != -1) {
              allFiles[index] = fileEntity;
            }
          }
        }
      }
    }
  }

  updateSendFileHistoryArray(FileHistory? fileHistory,
      {bool isDelete = false}) {
    for (int i = 0; i < sendFileHistory['history'].length; i++) {
      FileHistory tempFileHistory = FileHistory.fromJson(
        sendFileHistory['history'][i],
      );
      if (tempFileHistory.fileDetails!.key == fileHistory!.fileDetails!.key) {
        if (isDelete) {
          sendFileHistory['history'].removeAt(i);
        } else {
          sendFileHistory['history'][i] = fileHistory.toJson();
        }
        break;
      }
    }
  }

  deleteIndividualSentItem(FileHistory fileHistory) async {
    AtKey atKey = AtKey()
      ..key = fileHistory.fileDetails!.key
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..metadata!.ccd = true
      ..metadata!.ttl = 1296000000;

    var res = await AtClientManager.getInstance().atClient.delete(atKey);
    if (res) {
      updateFileEntryInSentHistory(fileHistory, isDelete: true);
      notifyListeners();
    }
    return res;
  }

  updateFileTransferState(
      String transferId, FileTransferProgress fileTransferProgress) {
    Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateReceivedFileProgress(
      transferId,
      fileTransferProgress,
    );

    notifyListeners();
  }

  refreshReceivedFile({bool setLoading = true}) async {
    if (setLoading) {
      setStatus(RECEIVED_HISTORY, Status.Loading);
    }

    List<AtKey> fileTransferAtkeys =
        await AtClientManager.getInstance().atClient.getAtKeys(
              regex: MixedConstants.FILE_TRANSFER_KEY,
            );

    fileTransferAtkeys.retainWhere((element) =>
        !element.key!.contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT) &&
        receivedItemsId[element.key] != true);

    for (var atKey in fileTransferAtkeys) {
      var isCurrentAtsign = compareAtSign(
          atKey.sharedBy!, BackendService.getInstance().currentAtSign!);
      if (!isCurrentAtsign && !checkRegexFromBlockedAtsign(atKey.sharedBy!)) {
        receivedItemsId[atKey.key] = true;

        AtValue atvalue = await AtClientManager.getInstance()
            .atClient
            .get(atKey)
            // ignore: return_of_invalid_type_from_catch_error
            .catchError((e) {
          print("error in getting atValue in getAllFileTransferData : $e");
          //// Removing exception as called in a loop
          // ExceptionService.instance.showGetExceptionOverlay(e);
          return AtValue();
        });

        if (atvalue.value != null) {
          try {
            FileTransferObject fileTransferObject =
                FileTransferObject.fromJson(jsonDecode(atvalue.value))!;
            FileTransfer filesModel =
                convertFiletransferObjectToFileTransfer(fileTransferObject);
            filesModel.sender = atKey.sharedBy!;

            receivedHistoryLogs.insert(0, filesModel);
          } catch (e) {
            print('error in getAllFileTransferData file model conversion: $e');
          }
        }
      }
    }

    try {} catch (e) {
      print('error in refreshReceivedFile : $e');
    }

    setStatus(RECEIVED_HISTORY, Status.Done);
  }

// save file in gallery function is not in use as of now.
// saveFilesInGallery(List<File> files) async {
//   for (var file in files) {
//     if (FileTypes.IMAGE_TYPES.contains(file.path.split('.').last) ||
//         FileTypes.VIDEO_TYPES.contains(file.path.split('.').last)) {
//       // saving image,video in gallery.
//       await ImageGallerySaver.saveFile(file.path);
//     }
//   }
// }
}
