import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:provider/provider.dart';

import 'base_model.dart';
import 'history_provider.dart';

class FileDownloadChecker extends BaseModel {
  FileDownloadChecker();
  bool undownloadedFilesExist = false;
  HistoryProvider historyProvider;
  FileTransfer receivedHistory;

  void checkForUndownloadedFiles() async {
    if (historyProvider == null) {
      historyProvider = Provider.of<HistoryProvider>(
          NavService.navKey.currentContext,
          listen: false);
    }

    for (var value in historyProvider.receivedHistoryLogs) {
      receivedHistory = value;
      var _isDownloadAvailable = _checkForDownloadAvailability();

      if (_isDownloadAvailable) {
        var _isFilesAvailableOffline =
            await _isFilesAlreadyDownloaded(value.sender);
        if (!_isFilesAvailableOffline) {
          undownloadedFilesExist = true;
          notifyListeners();
          return;
        }
      }
    }

    undownloadedFilesExist = false;
    notifyListeners();
  }

  bool _checkForDownloadAvailability() {
    bool _isDownloadAvailable = false;
    var expiryDate = receivedHistory.date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      _isDownloadAvailable = true;
    }

    var isFileUploaded = false;
    receivedHistory.files.forEach((FileData fileData) {
      if (fileData.isUploaded) {
        isFileUploaded = true;
      }
    });

    if (!isFileUploaded) {
      _isDownloadAvailable = false;
    }

    return _isDownloadAvailable;
  }

  Future<bool> _isFilesAlreadyDownloaded(String sender) async {
    for (var element in receivedHistory.files) {
      String path;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        path = MixedConstants.RECEIVED_FILE_DIRECTORY +
            Platform.pathSeparator +
            sender +
            Platform.pathSeparator +
            element.name;
      } else {
        path = BackendService.getInstance().downloadDirectory.path +
            Platform.pathSeparator +
            element.name;
      }
      File test = File(path);
      bool fileExists = await test.exists();
      if (fileExists == false) {
        return false;
      }
    }

    return true;
  }
}
