import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class FileProgressProvider extends BaseModel {
  FileTransferProgress? _sentFileTransferProgress;
  Map<String, FileTransferProgress> _receivedFileProgress = {};

  FileTransferProgress? get sentFileTransferProgress =>
      _sentFileTransferProgress;

  Map<String, FileTransferProgress> get receivedFileProgress =>
      _receivedFileProgress;

  set updateSentFileTransferProgress(
      FileTransferProgress fileTransferProgress) {
    _sentFileTransferProgress = fileTransferProgress;
    notifyListeners();
  }

  updateReceivedFileProgress(
      String transferId, FileTransferProgress fileTransferProgress) {
    _receivedFileProgress[transferId] = fileTransferProgress;
    notifyListeners();
  }

  removeReceiveProgressItem(String transferId) {
    _receivedFileProgress.remove(transferId);
  }
}