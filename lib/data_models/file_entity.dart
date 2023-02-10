import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_object.dart';

class FileEntity {
  final FileData? file;
  final String? date;
  final HistoryType? historyType;
  final String? atSign;
  final String? note;
  final String transferId;
  final FileTransferObject fileTransferObject;

  // to manage file upload
  bool isUploading;
  bool isUploaded;

  FileEntity({
    this.file,
    this.date,
    this.historyType,
    this.atSign,
    this.note,
    required this.transferId,
    required this.fileTransferObject,
    this.isUploading = false,
    this.isUploaded = false,
  });
}
