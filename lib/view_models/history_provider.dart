import 'dart:convert';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class HistoryProvider extends BaseModel {
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  List<FilesModel> sentHistory = [];
  List<FilesModel> receivedHistory = [];
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
        receivedFileHistory['history'] = historyFile['history'];
        historyFile['history'].forEach((value) {
          FilesModel filesModel = FilesModel.fromJson((value));
          filesModel.historyType = HistoryType.send;
          receivedHistory.add(filesModel);
        });
        print("receivedHistory => $receivedHistory");
      }

      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      setError(RECEIVED_HISTORY, error.toString());
    }
  }
}
