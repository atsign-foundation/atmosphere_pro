import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:at_client/src/stream/file_transfer_object.dart';

class DemoData {
  List<FileHistory> getFileHistoryData() {
    List<FileHistory> fileHistorys = <FileHistory>[];
    for (int i = 0; i < 11; i++) {
      FileTransfer fileTransfer = FileTransfer(
        url: 'url',
        files: [FileData(name: 'name', size: 10, url: 'url', path: 'path')],
        expiry: DateTime.now(),
        platformFiles: [
          PlatformFile(
            name: 'name',
            size: 1000,
            path: 'path',
          )
        ],
        date: DateTime.now(),
      );
      FileHistory fileHistory = FileHistory(
          fileTransfer,
          [
            ShareStatus('@kevin', true),
            ShareStatus('@colin', true),
            ShareStatus('@k', true)
          ],
          HistoryType.send,
          FileTransferObject(
            'transferId',
            'fileEncryptionKey',
            'fileUrl',
            'sharedWith',
            [],
          ));
      fileHistorys.add(fileHistory);
    }

    return fileHistorys;
  }
}
