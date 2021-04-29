import 'dart:convert';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/apk.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/cupertino.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  List<FileHistory> sentHistory = [], receivedHistoryNew = [];
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
      finalReceivedHistory = [];
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
      }
    } else {
      sendFileHistory['history'].insert(0, (fileHistory.toJson()));
    }
    print(
        'sendFileHistory after adding : ${sendFileHistory['history'].length}');
    var result = await backendService.atClientInstance
        .put(atKey, json.encode(sendFileHistory));
    print('file history saved: ${result}');
  }

  getSentHistory() async {
    setStatus(SENT_HISTORY, Status.Loading);
    // try {
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
        FileHistory filesModel = FileHistory.fromJson(jsonDecode(value));
        filesModel.type = HistoryType.send;
        sentHistory.add(filesModel);
      });
    }

    print('IN HISTORy---->${sentHistory}');
    setStatus(SENT_HISTORY, Status.Done);
    // } catch (error) {
    //   setError(SENT_HISTORY, error.toString());
    // }
  }

  getRecievedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    // try {
    // receivedHistory = [];
    // AtKey key = AtKey()
    //   ..key = 'receivedFiles'
    //   ..metadata = Metadata();
    // var keyValue = await backendService.atClientInstance.get(key);
    // if (keyValue != null && keyValue.value != null) {
    //   Map historyFile = json.decode((keyValue.value) as String) as Map;
    //   receivedFileHistory['history'] = historyFile['history'];
    //   historyFile['history'].forEach((value) {
    //     FilesModel filesModel = FilesModel.fromJson((value));
    //     filesModel.historyType = HistoryType.send;
    //     receivedHistory.add(filesModel);
    //   });

    //   finalReceivedHistory = [];
    //   receivedHistory.forEach((atSign) {
    //     atSign.files.forEach((file) {
    //       finalReceivedHistory.add(file);
    //     });
    //   });

    await getAllFileTransferData();
    sortFiles(receivedHistory);
    populateTabs();
    // }
    setStatus(RECEIVED_HISTORY, Status.Done);
    // } catch (error) {
    //   setError(RECEIVED_HISTORY, error.toString());
    // }
  }

  addToReceiveFileHistory(
    String sharedBy,
    String decodedMsg,
  ) async {
    // receivedFileHistory['history'].insert(0, (fileHistory.toJson()));

    FileHistory filesModel = FileHistory.fromJson((jsonDecode(decodedMsg)));
    filesModel.atsign = [
      sharedBy
    ]; // This originally contains list of atsigns the data was shared with
    // We change it to sharedBy
    filesModel.type = HistoryType.received;
    receivedHistoryNew.add(filesModel);
  }

  getAllFileTransferData() async {
    receivedHistoryNew = [];

    List<String> fileTransferResponse =
        await backendService.atClientInstance.getKeys(
      regex: MixedConstants.FILE_TRANSFER_KEY,
    );

    await Future.forEach(fileTransferResponse, (key) async {
      print('key $key');
      print('${key.split(':')[1]}');
      print('${backendService.atClientInstance.currentAtSign}');
      if ('@${key.split(':')[1]}'
          .contains(backendService.atClientInstance.currentAtSign)) {
        AtKey atKey = AtKey.fromString(key);
        AtValue atvalue = await backendService.atClientInstance
            .get(atKey)
            // ignore: return_of_invalid_type_from_catch_error
            .catchError((e) => print("error in get $e"));

        print('atvalue.value ${atvalue.value}');
        FileHistory filesModel =
            FileHistory.fromJson(jsonDecode(atvalue.value));
        filesModel.atsign = [
          atKey.sharedBy
        ]; // This originally contains list of atsigns the data was shared with
        // We change it to sharedBy
        filesModel.type = HistoryType.received;
        receivedHistoryNew.add(filesModel);
      }
    });

    print('sentHistory length ${receivedHistoryNew.length}');

    receivedHistoryNew.forEach((element) {
      element.fileDetails.files.forEach((element2) {
        print('file name : ${element2.name}');
      });
    });
  }

  sortFiles(List<FilesModel> filesList) async {
    // try {
    //   setStatus(SORT_FILES, Status.Loading);
    //   receivedAudio = [];
    //   receivedApk = [];
    //   receivedDocument = [];
    //   receivedPhotos = [];
    //   receivedVideos = [];
    //   filesList.forEach((atSign) {
    //     atSign.files.forEach((file) {
    //       String fileExtension = file.fileName.split('.').last;

    //       if (FileTypes.AUDIO_TYPES.contains(fileExtension)) {
    //         receivedAudio.add(file);
    //       }
    //       if (FileTypes.VIDEO_TYPES.contains(fileExtension)) {
    //         receivedVideos.add(file);
    //       }
    //       if (FileTypes.IMAGE_TYPES.contains(fileExtension)) {
    //         receivedPhotos.add(file);
    //       }
    //       if (FileTypes.TEXT_TYPES.contains(fileExtension) ||
    //           FileTypes.PDF_TYPES.contains(fileExtension) ||
    //           FileTypes.WORD_TYPES.contains(fileExtension) ||
    //           FileTypes.EXEL_TYPES.contains(fileExtension)) {
    //         receivedDocument.add(file);
    //       }
    //       if (FileTypes.APK_TYPES.contains(fileExtension)) {
    //         receivedApk.add(file);
    //       } else {}
    //     });
    //   });

    //   setStatus(SORT_FILES, Status.Done);
    // } catch (e) {
    //   setError(SORT_FILES, e.toString());
    // }
  }

  populateTabs() {
    // try {
    //   setStatus(POPULATE_TABS, Status.Loading);

    //   if (receivedApk.isNotEmpty) {
    //     if (!tabs.contains(APK) || !tabs.contains(APK())) {
    //       tabs.add(APK());
    //       tabNames.add('APK');
    //     }
    //   }
    //   if (receivedAudio.isNotEmpty) {
    //     if (!tabs.contains(Audios) || !tabs.contains(Audios())) {
    //       tabs.add(Audios());
    //       tabNames.add('Audios');
    //     }
    //   }
    //   if (receivedDocument.isNotEmpty) {
    //     if (!tabs.contains(Documents) || !tabs.contains(Documents())) {
    //       tabs.add(Documents());
    //       tabNames.add('Documents');
    //     }
    //   }
    //   if (receivedPhotos.isNotEmpty) {
    //     if (!tabs.contains(Photos) || !tabs.contains(Photos())) {
    //       tabs.add(Photos());
    //       tabNames.add('Photos');
    //     }
    //   }
    //   if (receivedVideos.isNotEmpty) {
    //     if (!tabs.contains(Videos) || !tabs.contains(Videos())) {
    //       tabs.add(Videos());
    //       tabNames.add('Videos');
    //     }
    //   }

    //   setStatus(POPULATE_TABS, Status.Done);
    // } catch (e) {
    //   setError(POPULATE_TABS, e.toString());
    // }
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
