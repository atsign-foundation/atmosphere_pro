import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class FileProgressProvider extends BaseModel {
  FileTransferProgress? _sentFileTransferProgress;
  final Map<String, FileTransferProgress> _receivedFileProgress = {};

  FileTransferProgress? get sentFileTransferProgress =>
      _sentFileTransferProgress;

  Map<String, FileTransferProgress> get receivedFileProgress =>
      _receivedFileProgress;

  set updateSentFileTransferProgress(
      FileTransferProgress fileTransferProgress) {
    _sentFileTransferProgress = fileTransferProgress;
    notifyListeners();
  }

  removeSentFileProgress() {
    _sentFileTransferProgress = null;
    notifyListeners();
  }

  updateReceivedFileProgress(
      String transferId, FileTransferProgress fileTransferProgress) {
    fileTransferProgress.percent =
        fileTransferProgress.percent?.roundToDouble();
    _receivedFileProgress[transferId] = fileTransferProgress;
    print(_receivedFileProgress[transferId]?.percent);
    notifyListeners();
  }

  removeReceiveProgressItem(String transferId) {
    _receivedFileProgress.remove(transferId);
  }
}
