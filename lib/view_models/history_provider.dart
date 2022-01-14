import 'dart:convert';
import 'dart:io';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_apk.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_audios.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_documents.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_photos.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_recent.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_unknowns.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/apk.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/unknowns.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:at_client/src/stream/file_transfer_object.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:provider/provider.dart';

import 'file_download_checker.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  String ADD_RECEIVED_FILE = 'add_received_file';
  String UPDATE_RECEIVED_RECORD = 'update_received_record';
  String SET_FILE_HISTORY = 'set_flie_history';
  String SET_RECEIVED_HISTORY = 'set_received_history';
  String GET_ALL_FILE_DATA = 'get_all_file_data';
  String DOWNLOAD_FILE = 'download_file';
  String RECENT_HISTORY = 'recent_history';
  String fileSearchText = '';
  List<FileHistory> sentHistory = [];
  List<FileTransfer> receivedHistoryLogs = [];
  List<FileTransfer> receivedHistoryNew = [];
  bool isSyncedDataFetched = false;
  Map<String, Map<String, bool>> downloadedFileAcknowledgement = {};
  List<FilesDetail> sentPhotos,
      sentVideos,
      sentAudio,
      sentApk,
      sentDocument = [];

  List<FilesDetail> receivedPhotos,
      receivedVideos,
      receivedAudio,
      receivedApk,
      receivedDocument,
      finalReceivedHistory = [],
      receivedUnknown = [],
      recentFile = [];
  List<String> tabNames = ['Recents'];

  List<FilesModel> receivedHistory, receivedAudioModel = [];
  List<Widget> tabs = [DesktopRecents()];
  String SORT_FILES = 'sort_files';
  String POPULATE_TABS = 'populate_tabs';
  Map receivedFileHistory = {'history': []};
  Map sendFileHistory = {'history': []};
  String SORT_LIST = 'sort_list';
  BackendService backendService = BackendService.getInstance();

  setFilesHistory(
      {HistoryType historyType,
      List<String> atSignName,
      List<FilesDetail> files,
      @required int id}) async {
    try {
      DateTime now = DateTime.now();
      FilesModel filesModel = FilesModel(
          name: atSignName,
          id: id,
          historyType: historyType,
          date: now.toString(),
          files: files);
      filesModel.totalSize = 0.0;

      AtKey atKey = AtKey()..metadata = Metadata();

      if (historyType == HistoryType.received) {
        /// the file size come in bytes in receiver side
        // filesModel.files.forEach((file) {
        //   file.size = file.size;
        //   filesModel.totalSize += file.size;
        // });
        // receivedFileHistory['history'].insert(0, (filesModel.toJson()));

        // atKey.key = 'receivedFiles';

        // await backendService.atClientManager.atClient
        //     .put(atKey, json.encode(receivedFileHistory));
      } else {
        // the file is in kB in sender side
        filesModel.files.forEach((file) {
          filesModel.totalSize += file.size;
        });
        sendFileHistory['history'].insert(0, filesModel.toJson());
        atKey.key = MixedConstants.SENT_FILE_HISTORY;
        await backendService.atClientManager.atClient
            .put(atKey, json.encode(sendFileHistory));
      }
    } catch (e) {
      print("here error => $e");
    }
  }

  resetData() {
    receivedHistory = [];
    receivedAudioModel = [];
    sendFileHistory = {'history': []};
    downloadedFileAcknowledgement = {};
  }

  setFileTransferHistory(
    FileTransferObject fileTransferObject,
    List<String> sharedWithAtsigns,
    Map<String, FileTransferObject> fileShareResult, {
    bool isEdit = false,
  }) async {
    FileHistory fileHistory = convertFileTransferObjectToFileHistory(
      fileTransferObject,
      sharedWithAtsigns,
      fileShareResult,
    );

    setStatus(SET_FILE_HISTORY, Status.Loading);
    await getSentHistory();
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..key = MixedConstants.SENT_FILE_HISTORY;

    if (isEdit) {
      int index = sentHistory.indexWhere((element) =>
          element?.fileDetails?.key?.contains(fileHistory.fileDetails.key));

      if (index > -1) {
        sendFileHistory['history'][index] = fileHistory.toJson();
        sentHistory[index] = fileHistory;
      }
    } else {
      sendFileHistory['history'].insert(0, (fileHistory.toJson()));
      sentHistory.insert(0, fileHistory);
    }

    var result = await backendService.atClientManager.atClient
        .put(atKey, json.encode(sendFileHistory));
    print('file history saved: ${result}');
    setStatus(SET_FILE_HISTORY, Status.Done);
  }

  updateFileHistoryDetail(FileHistory fileHistory) async {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..key = MixedConstants.SENT_FILE_HISTORY;

    int index = sentHistory.indexWhere((element) =>
        element?.fileDetails?.key?.contains(fileHistory.fileDetails.key));

    if (index > -1) {
      sendFileHistory['history'][index] = fileHistory.toJson();
      sentHistory[index] = fileHistory;
    }
    var result = await backendService.atClientManager.atClient
        .put(atKey, json.encode(sendFileHistory));

    return result;
  }

  getSentHistory() async {
    setStatus(SENT_HISTORY, Status.Loading);
    try {
      sentHistory = [];
      AtKey key = AtKey()
        ..key = MixedConstants.SENT_FILE_HISTORY
        ..sharedBy = backendService.currentAtsign
        ..metadata = Metadata();
      var keyValue = await backendService.atClientManager.atClient
          .get(key)
          .catchError((e) {
        print('error in decrypting value : $e');
      });
      if (keyValue != null && keyValue.value != null) {
        try {
          Map historyFile = json.decode((keyValue.value) as String) as Map;

          sendFileHistory['history'] = historyFile['history'];
          historyFile['history'].forEach((value) {
            FileHistory filesModel = FileHistory.fromJson((value));
            filesModel.sharedWith = checkIfileDownloaded(
              filesModel.sharedWith,
              filesModel.fileTransferObject.transferId,
            );
            sentHistory.add(filesModel);
          });
        } catch (e) {
          print('error in file model conversion in getSentHistory: $e');
        }
      }

      setStatus(SENT_HISTORY, Status.Done);
    } catch (error) {
      setError(SENT_HISTORY, error.toString());
    }
  }

  List<ShareStatus> checkIfileDownloaded(
      List<ShareStatus> shareStatus, String transferId) {
    if (downloadedFileAcknowledgement[transferId] != null) {
      for (int i = 0; i < shareStatus.length; i++) {
        if (downloadedFileAcknowledgement[transferId][shareStatus[i].atsign] !=
            null) {
          shareStatus[i].isFileDownloaded = true;
        }
      }
    }
    return shareStatus;
  }

  getFileDownloadedAcknowledgement() async {
    var atKeys = await AtClientManager.getInstance()
        .atClient
        .getAtKeys(regex: MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT);
    atKeys.retainWhere((element) => !compareAtSign(element.sharedBy,
        AtClientManager.getInstance().atClient.getCurrentAtSign()));

    await Future.forEach(atKeys, (AtKey atKey) async {
      try {
        AtValue atValue = await AtClientManager.getInstance()
            .atClient
            .get(atKey)
            .catchError((e) {
          print('error in get in getFileDownloadedAcknowledgement : $e');
        });
        if (atValue != null && atValue.value != null) {
          var downloadAcknowledgement =
              DownloadAcknowledgement.fromJson(jsonDecode(atValue.value));

          if (downloadedFileAcknowledgement[
                  downloadAcknowledgement.transferId] !=
              null) {
            downloadedFileAcknowledgement[downloadAcknowledgement.transferId]
                [formatAtsign(atKey.sharedBy)] = true;
          } else {
            downloadedFileAcknowledgement[downloadAcknowledgement.transferId] =
                {formatAtsign(atKey.sharedBy): true};
          }
        }
      } catch (e) {
        print('error in getFileDownloadedAcknowledgement : $e');
      }
    });
  }

  getReceivedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    receivedHistoryLogs = [];
    try {
      await getAllFileTransferData();
      sortReceivedNotifications();
      await sortFiles(receivedHistoryLogs);
      populateTabs();
      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      setStatus(RECEIVED_HISTORY, Status.Error);
      setError(RECEIVED_HISTORY, error.toString());
    }
  }

  checkForUpdatedOrNewNotification(String sharedBy, String decodedMsg) async {
    setStatus(UPDATE_RECEIVED_RECORD, Status.Loading);
    FileTransferObject fileTransferObject =
        FileTransferObject.fromJson((jsonDecode(decodedMsg)));
    FileTransfer filesModel =
        convertFiletransferObjectToFileTransfer(fileTransferObject);
    filesModel.sender = sharedBy;

    //check id data with same key already present
    var index = receivedHistoryLogs
        .indexWhere((element) => element.key == fileTransferObject.transferId);

    if (index > -1) {
      receivedHistoryLogs[index] = filesModel;
    } else {
      await addToReceiveFileHistory(sharedBy, filesModel);
    }
    setStatus(UPDATE_RECEIVED_RECORD, Status.Done);
  }

  addToReceiveFileHistory(String sharedBy, FileTransfer filesModel,
      {bool isUpdate = false}) async {
    setStatus(ADD_RECEIVED_FILE, Status.Loading);
    filesModel.sender = sharedBy;

    if (filesModel.isUpdate) {
      int index = receivedHistoryLogs
          .indexWhere((element) => element?.key?.contains(filesModel.key));
      if (index > -1) {
        receivedHistoryLogs[index] = filesModel;
      }
    } else {
      receivedHistoryNew.insert(0, filesModel);
      receivedHistoryLogs.insert(0, filesModel);
    }

    await sortFiles(receivedHistoryLogs);
    await populateTabs();
    setStatus(ADD_RECEIVED_FILE, Status.Done);
  }

  updateDownloadAcknowledgement(
      DownloadAcknowledgement downloadAcknowledgement, String sharedBy) async {
    var index = sentHistory.indexWhere((element) =>
        element.fileDetails.key == downloadAcknowledgement.transferId);
    if (index > -1) {
      var i = sentHistory[index]
          .sharedWith
          .indexWhere((element) => element.atsign == sharedBy);
      sentHistory[index].sharedWith[i].isFileDownloaded = true;
      await updateFileHistoryDetail(sentHistory[index]);
    }
  }

  getAllFileTransferData() async {
    setStatus(GET_ALL_FILE_DATA, Status.Loading);
    receivedHistoryLogs = [];

    List<String> fileTransferResponse =
        await backendService.atClientManager.atClient.getKeys(
      regex: MixedConstants.FILE_TRANSFER_KEY,
    );

    await Future.forEach(fileTransferResponse, (key) async {
      if (key.contains('cached') && !checkRegexFromBlockedAtsign(key)) {
        AtKey atKey = AtKey.fromString(key);
        AtValue atvalue = await backendService.atClientManager.atClient
            .get(atKey)
            // ignore: return_of_invalid_type_from_catch_error
            .catchError((e) => print("error in get $e"));

        if (atvalue != null && atvalue.value != null) {
          try {
            FileTransferObject fileTransferObject =
                FileTransferObject.fromJson(jsonDecode(atvalue.value));
            FileTransfer filesModel =
                convertFiletransferObjectToFileTransfer(fileTransferObject);
            filesModel.sender = '@' + key.split('@').last;

            if (filesModel.key != null) {
              receivedHistoryLogs.insert(0, filesModel);
            }
          } catch (e) {
            print('error in getAllFileTransferData file model conversion: $e');
          }
        }
      }
    });

    print('sentHistory length ${receivedHistoryNew.length}');
    print('receivedHistoryLogs length: ${receivedHistoryLogs.length}');
    setStatus(GET_ALL_FILE_DATA, Status.Done);
  }

  sortFiles(List<FileTransfer> filesList) async {
    try {
      setStatus(SORT_FILES, Status.Loading);
      receivedAudio = [];
      receivedApk = [];
      receivedDocument = [];
      receivedPhotos = [];
      receivedVideos = [];
      receivedUnknown = [];
      await Future.forEach(filesList, (fileData) async {
        await Future.forEach(fileData.files, (file) async {
          String fileExtension = file.name.split('.').last;
          FilesDetail fileDetail = FilesDetail(
            fileName: file.name,
            filePath: BackendService.getInstance().downloadDirectory.path +
                '/${file.name}',
            size: double.parse(file.size.toString()),
            date: fileData.date.toLocal().toString(),
            type: file.name.split('.').last,
            contactName: fileData.sender,
          );

          // check if file exists
          File tempFile = File(fileDetail.filePath);
          bool isFileDownloaded = await tempFile.exists();

          if (isFileDownloaded) {
            if (FileTypes.AUDIO_TYPES.contains(fileExtension)) {
              int index = receivedAudio.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedAudio.add(fileDetail);
              }
            } else if (FileTypes.VIDEO_TYPES.contains(fileExtension)) {
              int index = receivedVideos.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedVideos.add(fileDetail);
              }
            } else if (FileTypes.IMAGE_TYPES.contains(fileExtension)) {
              int index = receivedPhotos.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                // checking is photo is downloaded or not
                //if photo is downloaded then only it's shown in my files screen
                File file = File(fileDetail.filePath);
                bool isFileDownloaded = await file.exists();

                if (isFileDownloaded) {
                  receivedPhotos.add(fileDetail);
                }
              }
            } else if (FileTypes.TEXT_TYPES.contains(fileExtension) ||
                FileTypes.PDF_TYPES.contains(fileExtension) ||
                FileTypes.WORD_TYPES.contains(fileExtension) ||
                FileTypes.EXEL_TYPES.contains(fileExtension)) {
              int index = receivedDocument.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedDocument.add(fileDetail);
              }
            } else if (FileTypes.APK_TYPES.contains(fileExtension)) {
              int index = receivedApk.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedApk.add(fileDetail);
              }
            } else {
              int index = receivedUnknown.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedUnknown.add(fileDetail);
              }
            }
          }
        });
      });
      getrecentHistoryFiles();
      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      setError(SORT_FILES, e.toString());
    }
  }

  getrecentHistoryFiles() async {
    // finding last 15 received files data for recent tab
    setStatus(RECENT_HISTORY, Status.Loading);
    try {
      var lastTenFilesData = receivedHistoryLogs.sublist(
          0, receivedHistoryLogs.length > 15 ? 15 : receivedHistoryLogs.length);

      await Future.forEach(lastTenFilesData, (fileData) async {
        await Future.forEach(fileData.files, (FileData file) async {
          FilesDetail fileDetail = FilesDetail(
            fileName: file.name,
            filePath: BackendService.getInstance().downloadDirectory.path +
                '/${file.name}',
            size: double.parse(file.size.toString()),
            date: fileData.date.toLocal().toString(),
            type: file.name.split('.').last,
            contactName: fileData.sender,
          );

          File tempFile = File(fileDetail.filePath);
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

  populateTabs() {
    bool isDesktop = false;
    tabNames = ['Recents'];
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      isDesktop = true;
    }
    tabs = [isDesktop ? DesktopRecents() : Recents()];

    try {
      setStatus(POPULATE_TABS, Status.Loading);

      if (receivedApk.isNotEmpty) {
        if (!tabs.contains(APK) || !tabs.contains(APK())) {
          tabs.add(isDesktop ? DesktopAPK() : APK());
          tabNames.add('APK');
        }
      }
      if (receivedAudio.isNotEmpty) {
        if (!tabs.contains(Audios) || !tabs.contains(Audios())) {
          tabs.add(isDesktop ? DesktopAudios() : Audios());
          tabNames.add('Audios');
        }
      }
      if (receivedDocument.isNotEmpty) {
        if (!tabs.contains(Documents) || !tabs.contains(Documents())) {
          tabs.add(isDesktop ? DesktopDocuments() : Documents());
          tabNames.add('Documents');
        }
      }
      if (receivedPhotos.isNotEmpty) {
        if (!tabs.contains(Photos) || !tabs.contains(Photos())) {
          tabs.add(isDesktop ? DesktopPhotos() : Photos());
          tabNames.add('Photos');
        }
      }
      if (receivedVideos.isNotEmpty) {
        if (!tabs.contains(Videos) || !tabs.contains(Videos())) {
          tabs.add(isDesktop ? DesktopVideos() : Videos());
          tabNames.add('Videos');
        }
      }
      if (receivedUnknown.isNotEmpty) {
        if (!tabs.contains(Unknowns()) || !tabs.contains(Unknowns())) {
          tabs.add(isDesktop ? DesktopUnknowns() : Unknowns());
          tabNames.add('Unknowns');
        }
      }

      print('tabs populated: ${tabs}');

      setStatus(POPULATE_TABS, Status.Done);
    } catch (e) {
      setError(POPULATE_TABS, e.toString());
    }
  }

  sortReceivedNotifications() {
    receivedHistoryLogs.sort((a, b) => b.date.compareTo(a.date));
  }

  sortByName(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) => a.fileName.compareTo(b.fileName));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortBySize(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) => a.size.compareTo(b.size));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortByType(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) =>
          a.fileName.split('.').last.compareTo(b.fileName.split('.').last));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortByDate(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);

      list.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  bool checkRegexFromBlockedAtsign(String regex) {
    bool isBlocked = false;
    String atsign = regex.split('@')[regex.split('@').length - 1];

    ContactService().blockContactList.forEach((element) {
      if (element.atSign == '@${atsign}') {
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
    );
  }

  updateFileSendingStatus(
      {bool isUploading, bool isUploaded, String id, String filename}) {
    var index =
        sentHistory.indexWhere((element) => element.fileDetails.key == id);
    if (index > -1) {
      var fileIndex = sentHistory[index]
          .fileDetails
          .files
          .indexWhere((element) => element.name == filename);

      if (fileIndex > -1) {
        sentHistory[index].fileDetails.files[fileIndex].isUploading =
            isUploading;
        sentHistory[index].fileDetails.files[fileIndex].isUploaded = isUploaded;
      }
    }
    notifyListeners();
  }

  FileHistory convertFileTransferObjectToFileHistory(
      FileTransferObject fileTransferObject,
      List<String> sharedWithAtsigns,
      Map<String, FileTransferObject> fileShareResult) {
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
    );

    sharedWithAtsigns.forEach((atsign) {
      sthareStatus
          .add(ShareStatus(atsign, fileShareResult[atsign].sharedStatus));
    });

    return FileHistory(
        fileTransfer, sthareStatus, HistoryType.send, fileTransferObject);
  }

  downloadFiles(String transferId, String sharedBy, bool isWidgetOpen) async {
    try {
      var index = receivedHistoryLogs
          .indexWhere((element) => element.key == transferId);
      if (index > -1) {
        receivedHistoryLogs[index].isDownloading = true;
        receivedHistoryLogs[index].isWidgetOpen = isWidgetOpen;
      }
      notifyListeners();

      var files = await backendService.atClientManager.atClient
          .downloadFile(transferId, sharedBy);

      await sortFiles(receivedHistoryLogs);
      populateTabs();
      print('audios: ${receivedAudio.length}');
      receivedHistoryLogs[index].isDownloading = false;
      setStatus(DOWNLOAD_FILE, Status.Done);

      if (files is List<File>) {
        Provider.of<FileDownloadChecker>(NavService.navKey.currentContext,
                listen: false)
            .checkForUndownloadedFiles();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('error in downloading file: $e');
      return false;
    }
  }

  Future<bool> sendFileDownloadAcknowledgement(
      FileTransfer fileTransfer) async {
    var downloadAcknowledgement =
        DownloadAcknowledgement(true, fileTransfer.key);

    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..metadata.ccd = true
      ..key = MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT + fileTransfer.key
      ..metadata.ttl = 518400000
      ..sharedWith = fileTransfer.sender;
    try {
      var notificationResult =
          await AtClientManager.getInstance().notificationService.notify(
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
      return false;
    }
  }

  updateSendingNotificationStatus(
      String transferId, String atsign, bool isSending) {
    var index = sentHistory.indexWhere(
        (element) => element.fileTransferObject.transferId == transferId);
    if (index != -1) {
      var atsignIndex = sentHistory[index]
          .sharedWith
          .indexWhere((element) => element.atsign == atsign);
      if (atsignIndex != -1) {
        sentHistory[index].sharedWith[atsignIndex].isSendingNotification =
            isSending;
      }
    }
    notifyListeners();
  }

  setFileSearchText(String str) {
    fileSearchText = str;
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
}
