import 'dart:convert';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/file_types.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  List<FilesModel> sentHistory = [];
  List<FilesDetail> sentPhotos = [];
  List<FilesDetail> sentVideos = [];
  List<FilesDetail> sentAudio = [];
  List<FilesDetail> sentApk = [];
  List<FilesDetail> sentDocument = [];
  List<FilesDetail> receivedPhotos = [];
  List<FilesDetail> receivedVideos = [];
  List<FilesDetail> receivedAudio = [];
  List<FilesDetail> receivedApk = [];
  List<FilesDetail> receivedDocument = [];
  List<FilesModel> receivedHistory = [];
  String SORT_FILES = 'sort_files';
  Map receivedFileHistory = {'history': []};
  Map sendFileHistory = {'history': []};
  BackendService backendService = BackendService.getInstance();

  setFilesHistory(
      {HistoryType historyType,
      String atSignName,
      List<FilesDetail> files}) async {
    try {
      DateTime now = DateTime.now();
      FilesModel filesModel = FilesModel(
          name: atSignName,
          historyType: historyType,
          date: now.toString(),
          files: files);
      filesModel.totalSize = 0.0;

      AtKey atKey = AtKey()..metadata = Metadata();
      var result;
      if (historyType == HistoryType.received) {
        // the file size come in bytes in reciever side
        filesModel.files.forEach((file) {
          file.size = file.size / 1024;
          filesModel.totalSize += file.size;
        });
        receivedFileHistory['history'].insert(0, (filesModel.toJson()));

        atKey.key = 'receivedFiles';

        result = await backendService.atClientInstance
            .put(atKey, json.encode(receivedFileHistory));
      } else {
        // the file is in kB in sender side
        filesModel.files.forEach((file) {
          filesModel.totalSize += file.size;
        });
        sendFileHistory['history'].insert(0, filesModel.toJson());
        atKey.key = 'sentFiles';
        result = await backendService.atClientInstance
            .put(atKey, json.encode(sendFileHistory));
      }
      print(result);
    } catch (e) {
      print("here error => $e");
    }
  }

  getSentHistory() async {
    setStatus(SENT_HISTORY, Status.Loading);
    try {
      sentHistory = [];
      AtKey key = AtKey()
        ..key = 'sentFiles'
        ..metadata = Metadata();
      var keyValue = await backendService.atClientInstance.get(key);
      if (keyValue != null && keyValue.value != null) {
        Map historyFile = json.decode((keyValue.value) as String) as Map;
        sendFileHistory['history'] = historyFile['history'];
        historyFile['history'].forEach((value) {
          FilesModel filesModel = FilesModel.fromJson((value));
          filesModel.historyType = HistoryType.send;
          sentHistory.add(filesModel);
        });
        print("sentFileHistory => $sentHistory");
      }
      // sortFiles();

      setStatus(SENT_HISTORY, Status.Done);
    } catch (error) {
      print('ERROR IN SENT HISTORU======>$error');
      setError(SENT_HISTORY, error.toString());
    }
  }

  getRecievedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    try {
      receivedHistory = [];
      AtKey key = AtKey()
        ..key = 'receivedFiles'
        ..metadata = Metadata();
      var keyValue = await backendService.atClientInstance.get(key);
      if (keyValue != null && keyValue.value != null) {
        Map historyFile = json.decode((keyValue.value) as String) as Map;
        // print('HISTORY FILE=====>$historyFile');
        receivedFileHistory['history'] = historyFile['history'];
        historyFile['history'].forEach((value) {
          FilesModel filesModel = FilesModel.fromJson((value));
          filesModel.historyType = HistoryType.send;
          // print('filesModel.name======>${filesModel.files[0].fileName}');
          // String fileExtension = filesModel.name.split('.').last;

          receivedHistory.add(filesModel);
        });
        receivedHistory.forEach((element) {
          element.files.forEach((element) {
            print(' element.name======>${element.fileName}');
          });
          // print(' element.files======>${element.files.}');
        });
        sortFiles(receivedHistory);
        // print("receivedHistory => $receivedHistory");
      }
      // await sortFiles();
      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      setError(RECEIVED_HISTORY, error.toString());
    }
  }

  sortFiles(List<FilesModel> filesList) async {
    try {
      print('IN SORT FILES');
      setStatus(SORT_FILES, Status.Loading);
      // print('IN SORT======>$')

      filesList.forEach((file) {
        String fileExtension = file.name.split('.').last;
        print('fileExtension=====>$fileExtension');
        // if (FileTypes.AUDIO_TYPES.contains(fileExtension)) {
        //   sentAudio.add(file.files);
        //   print(1);
        // } else if (FileTypes.VIDEO_TYPES.contains(fileExtension)) {
        //   sentVideos.add(file);
        //   print(2);
        // } else if (FileTypes.IMAGE_TYPES.contains(fileExtension)) {
        //   sentPhotos.add(file);
        //   print(3);
        // } else if (FileTypes.TEXT_TYPES.contains(fileExtension) ||
        //     FileTypes.PDF_TYPES.contains(fileExtension) ||
        //     FileTypes.WORD_TYPES.contains(fileExtension) ||
        //     FileTypes.EXEL_TYPES.contains(fileExtension)) {
        //   sentDocument.add(file);
        //   print(4);
        // } else if (FileTypes.APK_TYPES.contains(fileExtension)) {
        //   sentApk.add(file);
        //   print(5);
        // } else {
        //   print(6);
        // }
      });
      print(
          'sentAudio===>$sentAudio====>sentvideo====$sentVideos====>sentapk====>$sentApk======>sentdoc=====>$sentDocument======>sentphitos=====>$sentPhotos');
      print('sort files complete');
      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      setError(SORT_FILES, e.toString());
    }
  }
}
