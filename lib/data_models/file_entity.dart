import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';

class FileEntity {
  final FileData? file;
  final String? date;
  final HistoryType? historyType;
  final String? atSign;
  final String? note;

  FileEntity({
    this.file,
    this.date,
    this.historyType,
    this.atSign,
    this.note,
  });
}
