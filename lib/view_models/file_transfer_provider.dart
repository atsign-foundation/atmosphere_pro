import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;
import 'package:http/http.dart' as http;

class FileTransferProvider extends BaseModel {
  FileTransferProvider._();
  static FileTransferProvider _instance = FileTransferProvider._();
  factory FileTransferProvider() => _instance;
  final String MEDIA = 'MEDIA';
  final String FILES = 'FILES';
  static List<PlatformFile> appClosedSharedFiles = [];
  String PICK_FILES = 'pick_files';
  String VIDEO_THUMBNAIL = 'video_thumbnail';
  String ACCEPT_FILES = 'accept_files';
  String SEND_FILES = 'send_files';
  List<SharedMediaFile> _sharedFiles;
  FilePickerResult result;
  PlatformFile file;
  FLUSHBAR_STATUS flushbarStatus;
  List<PlatformFile> selectedFiles = [];
  List<FileTransferStatus> transferStatus = [];
  Map<String, List<Map<String, bool>>> transferStatusMap = {};
  bool sentStatus = false;
  Uint8List videoThumbnail;
  double totalSize = 0;
  bool clearList = false;
  BackendService _backendService = BackendService.getInstance();
  List<AtContact> temporaryContactList = [];

  final _flushBarStream = StreamController<FLUSHBAR_STATUS>.broadcast();
  Stream<FLUSHBAR_STATUS> get flushBarStatusStream => _flushBarStream.stream;
  StreamSink<FLUSHBAR_STATUS> get flushBarStatusSink => _flushBarStream.sink;

  setFiles() async {
    setStatus(PICK_FILES, Status.Loading);
    try {
      selectedFiles = [];
      totalSize = 0;
      if (appClosedSharedFiles.isNotEmpty) {
        appClosedSharedFiles.forEach((element) {
          selectedFiles.add(element);
        });
        calculateSize();
      }
      appClosedSharedFiles = [];
      setStatus(PICK_FILES, Status.Done);
    } catch (error) {
      setError(PICK_FILES, error.toString());
    }
  }

  pickFiles(String choice) async {
    setStatus(PICK_FILES, Status.Loading);
    try {
      List<PlatformFile> tempList = [];
      if (selectedFiles.isNotEmpty) {
        tempList = selectedFiles;
      }
      selectedFiles = [];

      totalSize = 0;

      result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: choice == MEDIA ? FileType.media : FileType.any,
          allowCompression: true,
          withData: true);

      if (result?.files != null) {
        selectedFiles = tempList;
        tempList = [];

        result.files.forEach((element) {
          selectedFiles.add(element);
        });
        if (appClosedSharedFiles.isNotEmpty) {
          appClosedSharedFiles.forEach((element) {
            selectedFiles.add(element);
          });
        }
      }

      calculateSize();

      setStatus(PICK_FILES, Status.Done);
    } catch (error) {
      setError(PICK_FILES, error.toString());
    }
  }

  calculateSize() async {
    totalSize = 0;
    selectedFiles?.forEach((element) {
      totalSize += element.size;
    });
  }

  void acceptFiles() async {
    setStatus(ACCEPT_FILES, Status.Loading);
    try {
      await ReceiveSharingIntent.getMediaStream().listen(
          (List<SharedMediaFile> value) {
        _sharedFiles = value;

        if (value.isNotEmpty) {
          value.forEach((element) async {
            File file = File(element.path);
            double length = double.parse(await file.length().toString());

            selectedFiles.add(PlatformFile(
                name: basename(file.path),
                path: file.path,
                size: length.round(),
                bytes: await file.readAsBytes()));
            await calculateSize();
          });

          print(
              "Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        }
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

      // For sharing images coming from outside the app while the app is closed
      await ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> value) {
        _sharedFiles = value;
        if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
          _sharedFiles.forEach((element) async {
            var test = File(element.path);
            var length = await test.length();

            selectedFiles.add(PlatformFile(
                name: basename(test.path),
                path: test.path,
                size: length.round(),
                bytes: await test.readAsBytes()));
            await calculateSize();
          });
          print(
              "Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
          BuildContext c = NavService.navKey.currentContext;
          Navigator.pushReplacementNamed(c, Routes.WELCOME_SCREEN);
        }
      });
      setStatus(ACCEPT_FILES, Status.Done);
    } catch (error) {
      setError(ACCEPT_FILES, error.toString());
    }
  }

  bool isSending = false;
  sendFiles(List<PlatformFile> selectedFiles,
      List<GroupContactsModel> contactList) async {
    isSending = true;

    setStatus(SEND_FILES, Status.Loading);
    try {
      temporaryContactList = [];
      contactList.forEach((element) {
        if (element.contactType == ContactsType.CONTACT) {
          bool flag = false;
          for (AtContact atContact in temporaryContactList) {
            if (atContact.toString() == element.contact.toString()) {
              flag = true;
            }
          }
          if (!flag) {
            temporaryContactList.add(element.contact);
          }
        } else if (element.contactType == ContactsType.GROUP) {
          element.group.members.forEach((contact) {
            bool flag = false;
            for (AtContact atContact in temporaryContactList) {
              if (atContact.toString() == contact.toString()) {
                flag = true;
              }
            }
            if (!flag) {
              temporaryContactList.add(contact);
            }
          });
        }
      });

      int id = DateTime.now().millisecondsSinceEpoch;
      // showFlushbar = null;
      flushbarStatus = FLUSHBAR_STATUS.IDLE;
      await Future.forEach(temporaryContactList, (contact) async {
        await updateStatus(contact, id);
      });
      // temporaryContactList.forEach((contact) {
      //   updateStatus(contact, id);
      // });
      isSending = false;
      setStatus(SEND_FILES, Status.Done);
    } catch (error) {
      isSending = false;
      setError(SEND_FILES, error.toString());
    }
  }

  bool checkAtContactList(AtContact element) {
    return false;
  }

  static send(String contact, List selectedFiles, _backendService) async {
    selectedFiles.forEach((file) async {
      await _backendService.sendFile(contact, file.path);
    });
  }

  // bool showFlushbar;
  updateStatus(AtContact contact, int id) async {
    try {
      // setStatus(SEND_FILES, Status.Loading);
      selectedFiles.forEach((element) {
        transferStatus.add(FileTransferStatus(
            contactName: contact.atSign,
            fileName: element.name,
            status: TransferStatus.PENDING,
            id: id));
        Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                listen: false)
            .setFilesHistory(
                id: id,
                atSignName: [contact.atSign],
                historyType: HistoryType.send,
                files: [
                  FilesDetail(
                    filePath: element.path,
                    id: id,
                    contactName: contact.atSign,
                    size: double.parse(element.size.toString()),
                    fileName: element.name.toString(),
                    type: element.name.split('.').last,
                  ),
                ]);
      });

      if (contact == temporaryContactList.first) {
        sentStatus = true;
      }
      await Future.forEach(selectedFiles, (PlatformFile queuedFile) async {
        bool tempStatus =
            await _backendService.sendFile(contact.atSign, queuedFile.path);
        if (queuedFile.name == selectedFiles.first.name &&
            contact.atSign == temporaryContactList.first.atSign) {
          if (tempStatus) {
            flushbarStatus = FLUSHBAR_STATUS.SENDING;
          } else {
            flushbarStatus = FLUSHBAR_STATUS.FAILED;
          }
          // showFlushbar = tempStatus;
        }
        int index = transferStatus.indexWhere((element) =>
            element.fileName == queuedFile.name &&
            contact.atSign == element.contactName);
        if (index != 1) {
          if (tempStatus) {
            transferStatus[index].status = TransferStatus.DONE;
          } else {
            transferStatus[index].status = TransferStatus.FAILED;
          }
        }
        // setStatus(SEND_FILES, Status.Done);
      });
    } catch (e) {
      // setError(SEND_FILES, e.toString());
    }
    // for (var i = 0; i < selectedFiles.length; i++) {
    //   bool tempStatus =
    //       await _backendService.sendFile(contact.atSign, selectedFiles[i].path);
    //   if (i == 0 && contact.atSign == temporaryContactList.first.atSign) {
    //     if (tempStatus) {
    //       flushbarStatus = FLUSHBAR_STATUS.SENDING;
    //     } else {
    //       flushbarStatus = FLUSHBAR_STATUS.FAILED;
    //     }
    //     // showFlushbar = tempStatus;
    //   }
    //   int index = transferStatus.indexWhere((element) =>
    //       element.fileName == selectedFiles[i].name &&
    //       contact.atSign == element.contactName);
    //   if (index != 1) {
    //     if (tempStatus) {
    //       transferStatus[index].status = TransferStatus.DONE;
    //     } else {
    //       transferStatus[index].status = TransferStatus.FAILED;
    //     }
    //   }
    //   // if (i == selectedFiles.length - 1 &&
    //   //     contact == temporaryContactList.last) {}
    // }

    // WelcomeScreenProvider().selectedContacts.clear();
    // selectedFiles.clear();
    // notifyListeners();
    // getStatus(id, contact.atSign);
  }

  sendFileWithFileBin(List<PlatformFile> selectedFiles,
      List<GroupContactsModel> contactList) async {
    flushBarStatusSink.add(FLUSHBAR_STATUS.SENDING);
    setStatus(SEND_FILES, Status.Loading);
    try {
      FileTransfer filesToTransfer = FileTransfer(platformFiles: selectedFiles);
      filesToTransfer.isUpdate = false;
      var shareStatus = <ShareStatus>[];
      contactList.forEach((element) {
        shareStatus.add(ShareStatus(element.contact.atSign, false));
      });

      var backendService = BackendService.getInstance();
      String microSecondsSinceEpochId =
          DateTime.now().microsecondsSinceEpoch.toString();
      String container =
          '${backendService.currentAtSign.substring(1, backendService.currentAtSign.length)}' +
              microSecondsSinceEpochId;
      print('filebin container: ${container}');
      bool isFilesUploaded = false;

      for (var groupContact in contactList) {
        // encrypt file
        var fileEncryptionKey = await backendService
            .atClientInstance.encryptionService
            .generateFileEncryptionSharedKey(
                backendService.currentAtSign, groupContact.contact.atSign);

        if (!isFilesUploaded) {
          for (var file in selectedFiles) {
            int indexToEdit = filesToTransfer.files
                .indexWhere((element) => element.name == file.name);

            /// TODO: To fail first file upload
            // if (indexToEdit != 0) {
            //   filesToTransfer.files[indexToEdit].isUploaded = false;
            //   await File('${file.path}').copy(
            //       MixedConstants.SENT_FILE_DIRECTORY +
            //           '/${filesToTransfer.files[indexToEdit].name}');

            //   filesToTransfer.files[indexToEdit].path =
            //       '${MixedConstants.SENT_FILE_DIRECTORY}/${filesToTransfer.files[indexToEdit].name}';
            //   continue;
            // }

            var selectedFile = File(file.path);
            var bytes = selectedFile.readAsBytesSync();

            var encryptedFileContent = await backendService
                .atClientInstance.encryptionService
                .encryptFile(bytes, fileEncryptionKey);

            var response = await uploadFileToFilebin(
                container, file.name, encryptedFileContent);

            if (response != null && response is http.Response) {
              // updating name and isUploaded when file upload is success.
              Map fileInfo = jsonDecode(response.body);
              if (indexToEdit > -1) {
                filesToTransfer.files[indexToEdit].name =
                    fileInfo['file']['filename'];
                filesToTransfer.files[indexToEdit].isUploaded = true;
              }
            } else {
              filesToTransfer.files[indexToEdit].isUploaded = false;
            }

            await File('${file.path}').copy(MixedConstants.SENT_FILE_DIRECTORY +
                '/${filesToTransfer.files[indexToEdit].name}');

            filesToTransfer.files[indexToEdit].path =
                '${MixedConstants.SENT_FILE_DIRECTORY}/${filesToTransfer.files[indexToEdit].name}';
          }
          isFilesUploaded = true;
        }

        // creating file url
        String downloadUrl =
            MixedConstants.FILEBIN_URL + 'archive/' + container + '/zip';
        filesToTransfer.url = downloadUrl;
        filesToTransfer.key =
            '${MixedConstants.FILE_TRANSFER_KEY}-${microSecondsSinceEpochId}';
        filesToTransfer.sender = backendService.currentAtSign;

        /// TODO: To fail first user
        // if (contactList.indexOf(groupContact) == 0) {
        //   shareStatus[shareStatus.indexWhere(
        //           (element) => element.atsign == groupContact.contact.atSign)]
        //       .isNotificationSend = false;
        //   continue;
        // }

        // put data
        var result = await sendFileNotificationKey(
          groupContact.contact.atSign,
          '${MixedConstants.FILE_TRANSFER_KEY}-${microSecondsSinceEpochId}',
          filesToTransfer,
        );

        shareStatus[shareStatus.indexWhere(
                (element) => element.atsign == groupContact.contact.atSign)]
            .isNotificationSend = result;
      }
      flushBarStatusSink.add(FLUSHBAR_STATUS.DONE);

      FileHistory fileHistory =
          FileHistory(filesToTransfer, shareStatus, HistoryType.send);
      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(fileHistory);

      setStatus(SEND_FILES, Status.Done);
    } catch (e) {
      print('error in sending file : $e');
      setError(SEND_FILES, e.toString());
      setStatus(SEND_FILES, Status.Error);
      flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
    }
  }

  sendFileNotificationKey(
      String _atsign, String _key, FileTransfer _filesToTransfer) async {
    try {
      var backendService = BackendService.getInstance();
      AtKey atKey = AtKey()
        ..metadata = Metadata()
        ..metadata.ttr = -1
        ..metadata.ccd = true
        ..key = _key
        ..sharedWith = _atsign
        ..metadata.ttl = MixedConstants.FILE_TRANSFER_TTL
        ..sharedBy = backendService.currentAtSign;
      print('atkey : ${atKey}');

      // put data
      var _result = await backendService.atClientInstance
          .put(atKey, jsonEncode(_filesToTransfer.toJson()));

      return _result;
    } catch (e) {
      print('Error in sendFileNotificationKey for $_atsign');
      return false;
    }
  }

  reuploadFile(
      List<FileData> _filesList, int _index, FileHistory _sentHistory) async {
    try {
      var filesToTransfer = _sentHistory.fileDetails;
      var backendService = BackendService.getInstance();

      var fileEncryptionKey = await backendService
          .atClientInstance.encryptionService
          .generateFileEncryptionSharedKey(
              backendService.currentAtSign, _sentHistory.sharedWith[0].atsign);

      var selectedFile = File(_filesList[_index].path);
      var bytes = selectedFile.readAsBytesSync();

      var encryptedFileContent = await backendService
          .atClientInstance.encryptionService
          .encryptFile(bytes, fileEncryptionKey);

      String container
       = filesToTransfer.url.replaceAll(MixedConstants.FILEBIN_URL, '');
      container = container.replaceAll('archive/', '');
      container = container.replaceAll('/zip', '');

      var response = await uploadFileToFilebin(
          container, _filesList[_index].name, encryptedFileContent);

      if (response != null && response is http.Response) {
        // updating name and isUploaded when file upload is success.
        Map fileInfo = jsonDecode(response.body);
        if (_index > -1) {
          filesToTransfer.files[_index].name = fileInfo['file']['filename'];
          filesToTransfer.files[_index].isUploaded = true;
          await File('${_filesList[_index].path}').copy(
              MixedConstants.SENT_FILE_DIRECTORY +
                  '/${filesToTransfer.files[_index].name}');

          filesToTransfer.files[_index].path =
              '${MixedConstants.SENT_FILE_DIRECTORY}/${filesToTransfer.files[_index].name}';
        }
      } else {
        filesToTransfer.files[_index].isUploaded = false;
      }

      filesToTransfer.isUpdate = true;
      for (var contact in _sentHistory.sharedWith) {
        var result = await sendFileNotificationKey(
            contact.atsign, filesToTransfer.key, filesToTransfer);

        contact.isNotificationSend = result;
      }

      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(_sentHistory, isEdit: true);
    } catch (e) {
      print('Error in reuploadFile $e');
      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(_sentHistory, isEdit: true);
    }
  }

  sendFileNotification(FileHistory fileHistory, String atsign) async {
    print('sendFileNotification : ${fileHistory.fileDetails.key}');
    print('sendFileNotification atsign : ${atsign}');
    try {
      AtKey atKey = AtKey()
        ..metadata = Metadata()
        ..metadata.ttr = -1
        ..metadata.ccd = true
        ..key = fileHistory.fileDetails.key
        ..sharedWith = atsign
        ..metadata.ttl = 60000 * 60 * 24 * 6
        ..sharedBy = BackendService.getInstance().currentAtSign;

      var result = await BackendService.getInstance()
          .atClientInstance
          .put(atKey, jsonEncode(fileHistory.fileDetails.toJson()));

      if (result is bool && result) {
        fileHistory.sharedWith.forEach((element) {
          if (atsign == element.atsign) {
            element.isNotificationSend = true;
          }
        });
      }

      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(fileHistory, isEdit: true);
    } catch (e) {
      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(fileHistory, isEdit: true);
      print('error in sending notification : $e');
    }
  }

  Future uploadFileToFilebin(
      String container, String fileName, List<int> dataBytes) async {
    try {
      var response = await http.post(Uri.parse(MixedConstants.FILEBIN_URL),
          headers: <String, String>{"bin": container, "filename": fileName},
          body: dataBytes);
      return response;
    } catch (e) {
      print('error in uploading file: ${e}');
    }
  }

  TransferStatus getStatus(int id, String atSign) {
    TransferStatus status;
    transferStatus.forEach((element) {
      if (element.id == id &&
          element.contactName == atSign &&
          status != TransferStatus.PENDING) {
        if (element.status == TransferStatus.PENDING) {
          status = TransferStatus.PENDING;
        } else if (element.status == TransferStatus.FAILED) {
          status = TransferStatus.FAILED;
        } else if (element.status != TransferStatus.FAILED) {
          status = TransferStatus.DONE;
        }
      }
    });

    return status;
  }
}

enum FLUSHBAR_STATUS { IDLE, SENDING, FAILED, DONE }
