import 'dart:convert';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/apk.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/unknowns.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/cupertino.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  String ADD_RECEIVED_FILE = 'add_recieved_file';
  String SET_FILE_HISTORY = 'set_flie_history';
  List<FileHistory> sentHistory = [];
  List<FileTransfer> recievedHistoryLogs = [];
  List<FileTransfer> receivedHistoryNew = [];
  // List<List<FilesDetail>> tempList = [];
  // Map<int, Map<String, Set<FilesDetail>>> testSentHistory = {};
  // static Map<int, Map<String, Set<FilesDetail>>> test = {};
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
      receivedUnknown = [];
  List<String> tabNames = ['Recents'];

  List<FilesModel> receivedHistory, receivedAudioModel = [];
  List<Widget> tabs = [Recents()];
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
        /// the file size come in bytes in reciever side
        // filesModel.files.forEach((file) {
        //   file.size = file.size;
        //   filesModel.totalSize += file.size;
        // });
        // receivedFileHistory['history'].insert(0, (filesModel.toJson()));

        // atKey.key = 'receivedFiles';

        // await backendService.atClientInstance
        //     .put(atKey, json.encode(receivedFileHistory));
      } else {
        // the file is in kB in sender side
        filesModel.files.forEach((file) {
          filesModel.totalSize += file.size;
        });
        sendFileHistory['history'].insert(0, filesModel.toJson());
        atKey.key = 'sentFiles';
        await backendService.atClientInstance
            .put(atKey, json.encode(sendFileHistory));
      }
    } catch (e) {
      print("here error => $e");
    }
  }

  setFileTransferHistory(FileHistory fileHistory, {bool isEdit = false}) async {
    setStatus(SET_FILE_HISTORY, Status.Loading);
    await getSentHistory();
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..key = 'sentFiles';
    print('atkey : ${atKey} ');
    print('sendFileHistory : ${sendFileHistory['history'].length}');
    if (isEdit) {
      int index = sentHistory.indexWhere((element) =>
          element?.fileDetails?.key?.contains(fileHistory.fileDetails.key));
      print('index: $index');
      if (index > -1) {
        sendFileHistory['history'][index] = fileHistory.toJson();
        sentHistory[index] = fileHistory;
      }
    } else {
      sendFileHistory['history'].insert(0, (fileHistory.toJson()));
      sentHistory.insert(0, fileHistory);
    }
    print(
        'sendFileHistory after adding : ${sendFileHistory['history'].length}');
    var result = await backendService.atClientInstance
        .put(atKey, json.encode(sendFileHistory));
    print('file history saved: ${result}');
    setStatus(SET_FILE_HISTORY, Status.Done);
  }

  getSentHistory() async {
    setStatus(SENT_HISTORY, Status.Loading);
    try {
      sentHistory = [];
      AtKey key = AtKey()
        ..key = 'sentFiles'
        ..metadata = Metadata();
      var keyValue = await backendService.atClientInstance.get(key);
      print('stored file values:${keyValue}');
      if (keyValue != null && keyValue.value != null) {
        Map historyFile = json.decode((keyValue.value) as String) as Map;
        print('stored file values decoded:${historyFile}');
        sendFileHistory['history'] = historyFile['history'];
        historyFile['history'].forEach((value) {
          FileHistory filesModel = FileHistory.fromJson((value));
          filesModel.type = HistoryType.send;
          sentHistory.add(filesModel);
        });
      }

      print('IN HISTORy---->${sentHistory}');
      setStatus(SENT_HISTORY, Status.Done);
    } catch (error) {
      setError(SENT_HISTORY, error.toString());
    }
  }

  getRecievedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    try {
      await getAllFileTransferData();
      sortFiles(recievedHistoryLogs);
      populateTabs();
      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      setError(RECEIVED_HISTORY, error.toString());
    }
  }

  addToReceiveFileHistory(
    String sharedBy,
    String decodedMsg,
  ) async {
    setStatus(ADD_RECEIVED_FILE, Status.Loading);
    FileTransfer filesModel = FileTransfer.fromJson((jsonDecode(decodedMsg)));
    print('addToReceiveFileHistory: ${filesModel.sender}');
    receivedHistoryNew.insert(0, filesModel);
    recievedHistoryLogs.insert(0, filesModel);
    await getReceivedHistoryLog();
    await getAllFileTransferData();
    await sortFiles(recievedHistoryLogs);
    await populateTabs();
    setStatus(ADD_RECEIVED_FILE, Status.Done);
  }

  getAllFileTransferData() async {
    await getReceivedHistoryLog();
    receivedHistoryNew = [];

    List<String> fileTransferResponse =
        await backendService.atClientInstance.getKeys(
      regex: MixedConstants.FILE_TRANSFER_KEY,
    );

    await Future.forEach(fileTransferResponse, (key) async {
      print('key $key');
      print('${key.split(':')[1]}');
      print('${backendService.atClientInstance.currentAtSign}');
      if (key.contains('cached')) {
        AtKey atKey = AtKey.fromString(key);
        AtValue atvalue = await backendService.atClientInstance
            .get(atKey)
            // ignore: return_of_invalid_type_from_catch_error
            .catchError((e) => print("error in get $e"));

        if (atvalue != null &&
            atvalue.value != null &&
            atvalue.value[0] != 'h') {
          print('atvalue.value ${atvalue.value}');
          FileTransfer filesModel =
              FileTransfer.fromJson(jsonDecode(atvalue.value));

          print('test detail:${filesModel.key}');

          // filesModel.sharedWith = [ShareStatus(atKey.sharedBy, true)];

          // This originally contains list of atsigns the data was shared with
          // We change it to sharedBy
          // filesModel.type = HistoryType.received;
          if (filesModel.key != null) {
            receivedHistoryNew.insert(0, filesModel);

            // checking if this data is already present in history logs or not
            int index = recievedHistoryLogs
                .indexWhere((element) => element.key == filesModel.key);
            if (index == -1) {
              print('new log found');
              recievedHistoryLogs.insert(0, filesModel);
            }
          }
        }
      }
    });

    print('sentHistory length ${receivedHistoryNew.length}');
    print('recievedHistoryLogs length: ${recievedHistoryLogs.length}');
    updateReceivedHistoryLogs();
  }

  getReceivedHistoryLog() async {
    recievedHistoryLogs = [];
    AtKey key = AtKey()
      ..metadata = Metadata()
      ..key = 'receivedFiles';
    var keyValue = await backendService.atClientInstance.get(key);
    print('received file history:${keyValue}');
    if (keyValue != null && keyValue.value != null) {
      Map historyFile = json.decode((keyValue.value) as String) as Map;
      receivedFileHistory['history'] = historyFile['history'];
      historyFile['history'].forEach((value) {
        FileTransfer filesModel = FileTransfer.fromJson((value));
        recievedHistoryLogs.add(filesModel);
      });
    }

    print('recievedHistoryLogs : ${recievedHistoryLogs}');
  }

  updateReceivedHistoryLogs() async {
    AtKey key = AtKey()
      ..metadata = Metadata()
      ..key = 'receivedFiles';

    receivedFileHistory['history'] = recievedHistoryLogs;
    var result = await backendService.atClientInstance
        .put(key, json.encode(receivedFileHistory));
    print('received history logs updated: ${result}');
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
      filesList.forEach((fileData) {
        fileData.files.forEach((file) {
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
              receivedPhotos.add(fileDetail);
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
        });
      });

      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      setError(SORT_FILES, e.toString());
    }
  }

  populateTabs() {
    tabs = [Recents()];
    tabNames = ['Recents'];
    try {
      setStatus(POPULATE_TABS, Status.Loading);

      if (receivedApk.isNotEmpty) {
        if (!tabs.contains(APK) || !tabs.contains(APK())) {
          tabs.add(APK());
          tabNames.add('APK');
        }
      }
      if (receivedAudio.isNotEmpty) {
        if (!tabs.contains(Audios) || !tabs.contains(Audios())) {
          tabs.add(Audios());
          tabNames.add('Audios');
        }
      }
      if (receivedDocument.isNotEmpty) {
        if (!tabs.contains(Documents) || !tabs.contains(Documents())) {
          tabs.add(Documents());
          tabNames.add('Documents');
        }
      }
      if (receivedPhotos.isNotEmpty) {
        if (!tabs.contains(Photos) || !tabs.contains(Photos())) {
          tabs.add(Photos());
          tabNames.add('Photos');
        }
      }
      if (receivedVideos.isNotEmpty) {
        if (!tabs.contains(Videos) || !tabs.contains(Videos())) {
          tabs.add(Videos());
          tabNames.add('Videos');
        }
      }
      if (receivedUnknown.isNotEmpty) {
        if (!tabs.contains(Unknowns()) || !tabs.contains(Unknowns())) {
          tabs.add(Unknowns());
          tabNames.add('Unknowns');
        }
      }

      print('tabs populated: ${tabs}');

      setStatus(POPULATE_TABS, Status.Done);
    } catch (e) {
      setError(POPULATE_TABS, e.toString());
    }
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
}
