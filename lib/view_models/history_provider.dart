import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
      print("comming till here");
      DateTime now = DateTime.now();
      FilesModel filesModel = FilesModel(
          name: atSignName,
          historyType: historyType,
          date: now.toString(),
          files: files);
      filesModel.totalSize = 0.0;
      filesModel.files.forEach((file) {
        filesModel.totalSize += file.size;
      });
      AtKey atKey = AtKey()..metadata = Metadata();
      var result;
      if (historyType == HistoryType.received) {
        receivedFileHistory['history'].add((filesModel.toJson()));

        atKey.key = 'receive';

        result = await backendService.atClientInstance
            .put(atKey, json.encode(receivedFileHistory));
      } else {
        sendFileHistory['history'].add(filesModel.toJson());
        atKey.key = 'send';
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
      print("comming till here");
      AtKey key = AtKey()
        ..key = 'send'
        ..metadata = Metadata();
      var keyValue = await backendService.atClientInstance.get(key);
      print("value => ${keyValue.value} => ${keyValue.value.runtimeType}");
      if (keyValue != null && keyValue.value != null) {
        Map historyFile = json.decode((keyValue.value) as String) as Map;
        sendFileHistory['history'] = historyFile['history'];
        print("hrww => ${historyFile['history']}");
        historyFile['history'].forEach((value) {
          print("value122 => ${value.runtimeType}");
          FilesModel filesModel = FilesModel.fromJson((value));
          print("dewdwed => $filesModel");
          filesModel.historyType = HistoryType.send;
          sentHistory.add(filesModel);
        });
        print("sendFileHistory => $sentHistory");
      }

      setStatus(SENT_HISTORY, Status.Done);
    } catch (e) {
      setStatus(SENT_HISTORY, Status.Error);
    }
  }

  getRecievedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    try {
      print("inside receive");
      receivedHistory = [];
      AtKey key = AtKey()
        ..key = 'receive'
        ..metadata = Metadata();
      var keyValue = await backendService.atClientInstance.get(key);
      print("keyValue1 => $keyValue");
      if (keyValue != null && keyValue.value != null) {
        Map historyFile = json.decode((keyValue.value) as String) as Map;
        receivedFileHistory['history'] = historyFile['history'];
        print("hrww1 => ${historyFile['history']}");
        historyFile['history'].forEach((value) {
          print("value12211 => ${value.runtimeType}");
          FilesModel filesModel = FilesModel.fromJson((value));
          print("dewdwed11 => $filesModel");
          filesModel.historyType = HistoryType.send;
          receivedHistory.add(filesModel);
        });
        print("receivedHistory => $receivedHistory");
      }

      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (e) {
      setStatus(RECEIVED_HISTORY, Status.Error);
    }
  }
}
