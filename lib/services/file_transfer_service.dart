import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// import 'package:at_client/src/stream/file_transfer_object.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_object.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:at_client/src/service/notification_service.dart';
import 'package:at_client/src/service/encryption_service.dart';

class FileTransferService {
  FileTransferService._();
  static FileTransferService _instance = FileTransferService._();
  factory FileTransferService.getInstance() {
    return _instance;
  }

  Future<Map<String, FileTransferObject>> uploadFile(
      List<File> files, List<String> sharedWithAtSigns,
      {String? notes}) async {
    var _encryptionService =
        AtClientManager.getInstance().atClient.encryptionService;

    if (_encryptionService == null) {
      throw ('Encryption service is null');
    }

    var encryptionKey = _encryptionService.generateFileEncryptionKey();
    var key = MixedConstants.FILE_TRANSFER_KEY + Uuid().v4();
    var fileStatus = await _uploadFiles(key, files, encryptionKey);
    var fileUrl = MixedConstants.FILEBIN_URL + 'archive/' + key + '/zip';
    return shareFiles(
        sharedWithAtSigns, key, fileUrl, encryptionKey, fileStatus,
        notes: notes);
  }

  Future<List<FileStatus>> _uploadFiles(
      String transferId, List<File> files, String encryptionKey) async {
    var fileUploadProvider = Provider.of<FileProgressProvider>(
        NavService.navKey.currentContext!,
        listen: false);

    var _preference = BackendService.getInstance().atClientPreference;
    var fileStatuses = <FileStatus>[];

    for (var file in files) {
      var fileStatus = FileStatus(
        fileName: file.path.split(Platform.pathSeparator).last,
        isUploaded: false,
        size: await file.length(),
      );
      try {
        fileUploadProvider.updateSentFileTransferProgress =
            FileTransferProgress(FileState.encrypt, null, null);
        final encryptedFile = await encryptFile(
          file,
          encryptionKey,
          _preference.fileEncryptionChunkSize,
        );

        var response = await uploadToFileBinWithStreamedRequest(
          encryptedFile,
          transferId,
          fileStatus.fileName!,
        );

        encryptedFile.deleteSync();
        if (response != null && response.statusCode == 201) {
          final responseStr = await response.stream.bytesToString();
          var responseMap = jsonDecode(responseStr);
          fileStatus.fileName = responseMap['file']['filename'];
          fileStatus.isUploaded = true;
        }

        // storing sent files in a a directory.
        if (_preference.downloadPath != null) {
          var sentFilesDirectory = await Directory(_preference.downloadPath! +
                  Platform.pathSeparator +
                  'sent-files')
              .create();
          await File(file.path).copy(sentFilesDirectory.path +
              Platform.pathSeparator +
              (fileStatus.fileName ?? ''));
        }
      } on Exception catch (e) {
        fileStatus.error = e.toString();
      }
      fileStatuses.add(fileStatus);
    }
    return fileStatuses;
  }

  Future<List<FileStatus>> reuploadFiles(
      List<File> files, FileTransferObject fileTransferObject) async {
    var response = await _uploadFiles(fileTransferObject.transferId, files,
        fileTransferObject.fileEncryptionKey);
    return response;
  }

  Future<Map<String, FileTransferObject>> shareFiles(
    List<String> sharedWithAtSigns,
    String key,
    String fileUrl,
    String encryptionKey,
    List<FileStatus> fileStatus, {
    DateTime? date,
    String? notes,
  }) async {
    var result = <String, FileTransferObject>{};
    bool isAnyFileUploaded = false;
    for (var file in fileStatus) {
      if (file.isUploaded != null && file.isUploaded!) {
        isAnyFileUploaded = true;
        break;
      }
    }

    for (var sharedWithAtSign in sharedWithAtSigns) {
      var fileTransferObject = FileTransferObject(
          key, encryptionKey, fileUrl, sharedWithAtSign, fileStatus,
          date: date, notes: notes);

      // if no files are uploaded, no notification will be sent.
      if (!isAnyFileUploaded) {
        fileTransferObject.sharedStatus = false;
        result[sharedWithAtSign] = fileTransferObject;
        continue;
      }

      try {
        var atKey = AtKey()
          ..key = key
          ..sharedWith = sharedWithAtSign
          ..metadata = Metadata()
          ..metadata!.ttr = -1
          // file transfer key will be deleted after 15 days
          ..metadata!.ttl = 1296000000 // 1000 * 60 * 60 * 24 * 15
          ..sharedBy = BackendService.getInstance().currentAtSign;

        var notificationResult =
            await AtClientManager.getInstance().notificationService.notify(
                  NotificationParams.forUpdate(
                    atKey,
                    value: jsonEncode(fileTransferObject.toJson()),
                  ),
                );

        if (notificationResult.notificationStatusEnum ==
            NotificationStatusEnum.delivered) {
          fileTransferObject.sharedStatus = true;
        } else {
          fileTransferObject.sharedStatus = false;
        }
      } on Exception catch (e) {
        fileTransferObject.sharedStatus = false;
        fileTransferObject.error = e.toString();
      }
      result[sharedWithAtSign] = fileTransferObject;
    }
    return result;
  }

  Future<File> encryptFile(
      File file, String encryptionKey, int fileEncryptionChunkSize) {
    var _preference = BackendService.getInstance().atClientPreference;
    final Completer<File> completer = Completer<File>();
    var receiverPort = ReceivePort();

    Isolate.spawn(encryptFileInIsolate, {
      'sendPort': receiverPort.sendPort,
      'file': file,
      'encryptionKey': encryptionKey,
      'fileEncryptionChunkSize': _preference.fileEncryptionChunkSize,
      'path': MixedConstants.RECEIVED_FILE_DIRECTORY
    });

    receiverPort.listen((encryptedFile) {
      completer.complete(encryptedFile);
    });

    return completer.future;
  }

  Future<dynamic> uploadToFileBinWithStreamedRequest(
      File file, String container, String fileName) async {
    try {
      var fileUploadProvider = Provider.of<FileProgressProvider>(
          NavService.navKey.currentContext!,
          listen: false);
      var postUri =
          Uri.parse(MixedConstants.FILEBIN_URL + '$container/' + fileName);
      final streamedRequest = http.StreamedRequest('POST', postUri);

      var uploadedBytes = 0;
      var fileLength = await file.length();

      streamedRequest.contentLength = fileLength;
      file.openRead().listen((chunk) {
        streamedRequest.sink.add(chunk);

        uploadedBytes += chunk.length;
        var percent = (uploadedBytes / fileLength) * 100;
        fileUploadProvider.updateSentFileTransferProgress =
            FileTransferProgress(FileState.upload, percent, fileName);
      }, onDone: () {
        streamedRequest.sink.close();
      });

      http.StreamedResponse response = await streamedRequest.send();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<File>> downloadFile(String transferId, String sharedByAtSign,
      {String? downloadPath}) async {
    var _preference = BackendService.getInstance().atClientPreference;
    downloadPath ??=
        BackendService.getInstance().atClientPreference.downloadPath;
    if (downloadPath == null) {
      throw Exception('downloadPath not found');
    }

    var atKey = AtKey()
      ..key = transferId
      ..sharedBy = sharedByAtSign;
    var result = await AtClientManager.getInstance().atClient.get(atKey);
    FileTransferObject fileTransferObject;
    try {
      if (FileTransferObject.fromJson(jsonDecode(result.value)) == null) {
        throw AtClientException("AT0014", "FileTransferObject is null");
      }
      fileTransferObject =
          FileTransferObject.fromJson(jsonDecode(result.value))!;
    } on Exception catch (e) {
      throw Exception('json decode exception in download file ${e.toString()}');
    }

    var downloadedFiles = <File>[];
    var fileDownloadReponse = await downloadAllFiles(
      fileTransferObject,
      downloadPath,
    );

    if (fileDownloadReponse.isError) {
      throw Exception('download fail');
    }
    var encryptedFileList = Directory(fileDownloadReponse.filePath!).listSync();
    try {
      for (var encryptedFile in encryptedFileList) {
        updateFileTransferState(
            encryptedFile.path.split(Platform.pathSeparator).last,
            transferId,
            null,
            FileState.decrypt);
        var decryptedFile = await decryptFile(
            File(encryptedFile.path),
            fileTransferObject.fileEncryptionKey,
            _preference.fileEncryptionChunkSize);
        decryptedFile.copySync(downloadPath +
            Platform.pathSeparator +
            encryptedFile.path.split(Platform.pathSeparator).last);
        downloadedFiles.add(File(downloadPath +
            Platform.pathSeparator +
            encryptedFile.path.split(Platform.pathSeparator).last));
        decryptedFile.deleteSync();
      }
      // deleting temp directory
      Directory(fileDownloadReponse.filePath!).deleteSync(recursive: true);
      return downloadedFiles;
    } catch (e) {
      throw Exception('Error in saving file');
    }
  }

  Future<File> decryptFile(
      File file, String encryptionKey, int fileEncryptionChunkSize) async {
    final Completer<File> completer = Completer<File>();
    var receiverPort = ReceivePort();
    var _preference = BackendService.getInstance().atClientPreference;

    Isolate.spawn(decryptFileInIsolate, {
      'sendPort': receiverPort.sendPort,
      'file': file,
      'encryptionKey': encryptionKey,
      'fileEncryptionChunkSize': _preference.fileEncryptionChunkSize,
    });

    receiverPort.listen((encryptedFile) {
      completer.complete(encryptedFile);
    });
    return completer.future;
  }

  Future downloadAllFiles(
      FileTransferObject fileTransferObject, String downloadPath) async {
    final Completer<FileDownloadResponse> completer =
        Completer<FileDownloadResponse>();
    var tempDirectory =
        await Directory(downloadPath).createTemp('encrypted-files');
    var fileDownloadResponse =
        FileDownloadResponse(isError: false, filePath: tempDirectory.path);

    try {
      String filebinContainer = fileTransferObject.fileUrl;
      filebinContainer = filebinContainer.replaceFirst('/archive', '');
      filebinContainer = filebinContainer.replaceFirst('/zip', '');

      for (int i = 0; i < fileTransferObject.fileStatus.length; i++) {
        String fileName = fileTransferObject.fileStatus[i].fileName!;
        String fileUrl = filebinContainer + '/' + fileName;
        updateFileTransferState(
          fileName,
          fileTransferObject.transferId,
          null,
          FileState.download,
        );

        var downloadResponse = await downloadIndividualFile(fileUrl,
            tempDirectory.path, fileName, fileTransferObject.transferId);
        if (downloadResponse.isError) {
          fileDownloadResponse = FileDownloadResponse(
              isError: true,
              filePath: tempDirectory.path,
              errorMsg: 'Failed to download file.');
        }
      }

      completer.complete(fileDownloadResponse);
      return completer.future;
    } catch (e) {
      completer.complete(
        FileDownloadResponse(
            isError: true, errorMsg: 'Failed to download file.'),
      );
    }
    return completer.future;
  }

  Future downloadIndividualFile(String fileUrl, String tempPath,
      String fileName, String transferId) async {
    final Completer<FileDownloadResponse> completer =
        Completer<FileDownloadResponse>();
    var httpClient = http.Client();
    http.Request request;
    late Future<http.StreamedResponse> response;

    try {
      request = http.Request('GET', Uri.parse(fileUrl));
      response = httpClient.send(request);
    } catch (e) {
      throw ('Failed to fetch file details.');
    }

    late StreamSubscription downloadSubscription;
    File file = File(tempPath + Platform.pathSeparator + fileName);
    double downloaded = 0;

    try {
      downloadSubscription =
          response.asStream().listen((http.StreamedResponse r) {
        r.stream.listen(
          (List<int> chunk) {
            file.writeAsBytesSync(chunk, mode: FileMode.append);
            downloaded += chunk.length;
            if (r.contentLength != null) {
              var percent = (downloaded / r.contentLength!) * 100;

              updateFileTransferState(
                fileName,
                transferId,
                percent.roundToDouble(),
                FileState.download,
              );
            }
          },
          onDone: () async {
            await downloadSubscription.cancel();
            completer.complete(
              FileDownloadResponse(filePath: file.path),
            );
          },
        );
      });

      return completer.future;
    } catch (e) {
      await downloadSubscription.cancel();
      completer.complete(
        FileDownloadResponse(
            isError: true, errorMsg: 'Failed to download file.'),
      );
    }

    return completer.future;
  }

  /// [updateFileTransferState] sets download/decrypt file state in history screen.
  updateFileTransferState(String fileName, String transferId, double? percent,
      FileState fileState) {
    var fileTransferProgress = FileTransferProgress(
      fileState,
      percent, // currently not showing download/decrypt %
      fileName,
    );

    Provider.of<FileProgressProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateReceivedFileProgress(
      transferId,
      fileTransferProgress,
    );
  }
}

void encryptFileInIsolate(Map params) async {
  final encryptedFile = await EncryptionService().encryptFileInChunks(
    params['file'],
    params['encryptionKey'],
    params['fileEncryptionChunkSize'],
    path: params['path'],
  );
  params['sendPort'].send(encryptedFile);
}

void decryptFileInIsolate(Map params) async {
  final decryptedFile = await EncryptionService().decryptFileInChunks(
    params['file'],
    params['encryptionKey'],
    params['fileEncryptionChunkSize'],
  );

  params['sendPort'].send(decryptedFile);
}
