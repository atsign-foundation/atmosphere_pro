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
import 'package:at_client/src/stream/file_transfer_object.dart';

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
  String RETRY_NOTIFICATION = 'retry_notification';
  String RETRY_UPLOAD = 'retry_upload';
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
  bool hasSelectedFilesChanged = false, scrollToBottom = false;

  final _flushBarStream = StreamController<FLUSHBAR_STATUS>.broadcast();
  Stream<FLUSHBAR_STATUS> get flushBarStatusStream => _flushBarStream.stream;
  StreamSink<FLUSHBAR_STATUS> get flushBarStatusSink => _flushBarStream.sink;

  FileHistory _selectedFileHistory;

  set selectedFileHistory(FileHistory fileHistory) {
    _selectedFileHistory = fileHistory;
  }

  FileHistory get getSelectedFileHistory => _selectedFileHistory;

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
        hasSelectedFilesChanged = true;
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
        // withReadStream: true,
      );

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
        hasSelectedFilesChanged = true;
      }

      calculateSize();

      setStatus(PICK_FILES, Status.Done);
      scrollToBottom = true;
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
            hasSelectedFilesChanged = true;
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
            hasSelectedFilesChanged = true;
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
      var _atclient = BackendService.getInstance().atClientInstance;
      FileTransfer filesToTransfer = FileTransfer(platformFiles: selectedFiles);
      var _files = <File>[];
      var _atSigns = <String>[];

      filesToTransfer.files.forEach((element) {
        _files.add(File(element.path));
      });

      contactList.forEach((groupContact) {
        if (groupContact.contact != null) {
          var index =
              _atSigns.indexWhere((el) => el == groupContact.contact.atSign);
          if (index == -1) _atSigns.add(groupContact.contact.atSign);
        } else if (groupContact.group != null) {
          groupContact.group.members.forEach((member) {
            var index = _atSigns.indexWhere((el) => el == member.atSign);
            if (index == -1) _atSigns.add(member.atSign);
          });
        }
      });

      var uploadResult = await _atclient.uploadFile(_files, _atSigns);
      await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .setFileTransferHistory(
              uploadResult[_atSigns[0]], _atSigns, uploadResult);

      flushBarStatusSink.add(FLUSHBAR_STATUS.DONE);
      setStatus(SEND_FILES, Status.Done);
    } catch (e) {
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

  reuploadFiles(
      List<FileData> _filesList, int _index, FileHistory _sentHistory) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);
    Provider.of<HistoryProvider>(NavService.navKey.currentContext,
            listen: false)
        .updateFileSendingStatus(
      isUploading: true,
      isUploaded: false,
      id: _sentHistory.fileDetails.key,
      filename: _filesList[_index].name,
    );

    var _atclient = BackendService.getInstance().atClientInstance;
    try {
      File file =
          File(MixedConstants.SENT_FILE_DIRECTORY + _filesList[_index].name);
      bool fileExists = await file.exists();
      if (!fileExists) {
        throw ('file not found');
      }

      var uploadStatus = await _atclient
          .reuploadFiles([file], _sentHistory.fileTransferObject);

      if (uploadStatus is List<FileStatus> && uploadStatus.isNotEmpty) {
        if (uploadStatus[0].isUploaded) {
          var index = _sentHistory.fileDetails.files
              .indexWhere((element) => element.name == _filesList[_index].name);

          if (index > -1) {
            _sentHistory.fileDetails.files[index].isUploaded = true;
          }

          var i = _sentHistory.fileTransferObject.fileStatus.indexWhere(
              (element) => element.fileName == _filesList[_index].name);
          if (i > -1) {
            _sentHistory.fileTransferObject.fileStatus[i].isUploaded = true;
          }

          // sending file upload notification to every atsign
          await Future.forEach(_sentHistory.sharedWith,
              (ShareStatus sharedWith) async {
            await reSendFileNotification(_sentHistory, sharedWith.atsign);
          });

          Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                  listen: false)
              .updateFileSendingStatus(
            isUploading: false,
            isUploaded: true,
            id: _sentHistory.fileDetails.key,
            filename: _filesList[_index].name,
          );
        }
      }
      setStatus(RETRY_NOTIFICATION, Status.Done);
    } catch (e) {
      setStatus(RETRY_NOTIFICATION, Status.Error);
      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .updateFileSendingStatus(
        isUploading: false,
        isUploaded: true,
        id: _sentHistory.fileDetails.key,
        filename: _filesList[_index].name,
      );
    }
  }

  reSendFileNotification(FileHistory fileHistory, String atsign) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);
    var _atclient = BackendService.getInstance().atClientInstance;

    Provider.of<HistoryProvider>(NavService.navKey.currentContext,
            listen: false)
        .updateSendingNotificationStatus(
            fileHistory.fileTransferObject.transferId, atsign, true);
    try {
      var sendResponse = await _atclient.shareFiles(
          [atsign],
          fileHistory.fileTransferObject.transferId,
          fileHistory.fileTransferObject.fileUrl,
          fileHistory.fileTransferObject.fileEncryptionKey,
          fileHistory.fileTransferObject.fileStatus,
          date: fileHistory.fileTransferObject.date);
      print(sendResponse);

      if (sendResponse[atsign].sharedStatus) {
        var indexToUpdate = fileHistory.sharedWith.indexWhere(
          (element) => element.atsign == atsign,
        );

        if (indexToUpdate > -1) {
          fileHistory.sharedWith[indexToUpdate].isNotificationSend = true;
        }
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                listen: false)
            .updateFileHistoryDetail(fileHistory);

        Provider.of<HistoryProvider>(NavService.navKey.currentContext,
                listen: false)
            .updateSendingNotificationStatus(
                fileHistory.fileTransferObject.transferId, atsign, false);

        setStatus(RETRY_NOTIFICATION, Status.Done);
      }
    } catch (e) {
      Provider.of<HistoryProvider>(NavService.navKey.currentContext,
              listen: false)
          .updateSendingNotificationStatus(
              fileHistory.fileTransferObject.transferId, atsign, false);
      setStatus(RETRY_NOTIFICATION, Status.Error);
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

  void resetSelectedFilesStatus() {
    hasSelectedFilesChanged = false;
  }
}

enum FLUSHBAR_STATUS { IDLE, SENDING, FAILED, DONE }
