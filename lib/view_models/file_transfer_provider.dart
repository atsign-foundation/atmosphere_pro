import 'dart:io';
import 'dart:typed_data';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
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
import 'package:http/http.dart';

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
                atSignName: contact.atSign,
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
    var backendService = BackendService.getInstance();
    String microSecondsSinceEpochId =
        DateTime.now().microsecondsSinceEpoch.toString();
    String container =
        '${backendService.currentAtSign.substring(1, backendService.currentAtSign.length)}' +
            microSecondsSinceEpochId;
    print('filebin container: ${container}');

    // encrypt file
    var fileEncryptionKey = await backendService
        .atClientInstance.encryptionService
        .generateFileEncryptionSharedKey(
            backendService.currentAtSign, contactList[0].contact.atSign);
    print('fileEncryptionKey : ${fileEncryptionKey}');

    for (var file in selectedFiles) {
      var selectedFile = File(file.path);
      var bytes = selectedFile.readAsBytesSync();
      print('file : ${selectedFile}');

      var encryptedFileContent = await backendService
          .atClientInstance.encryptionService
          .encryptFile(bytes, fileEncryptionKey);

      print('encryptedFileContent : ${encryptedFileContent}');

      try {
        var response = await post(Uri.parse(MixedConstants.FILEBIN_URL),
            headers: <String, String>{"bin": container, "filename": file.name},
            body: encryptedFileContent);
        print('file upload ${response.body}');
        print('container link: ${container}');
      } catch (e) {
        print('error in uploading');
      }
    }

    try {
      AtKey atKey = AtKey()
        ..metadata = Metadata()
        ..metadata.ttr = -1
        ..metadata.ccd = true
        ..key =
            '${MixedConstants.FILE_TRANSFER_KEY}-${microSecondsSinceEpochId}'
        ..sharedWith = contactList[0].contact.atSign
        ..metadata.ttl = 60000 * 60 * 24 * 6
        ..sharedBy = backendService.currentAtSign;
      print('atkey : ${atKey}');

      // creating file url
      String downloadUrl =
          MixedConstants.FILEBIN_URL + 'archive/' + container + '/zip';

      print('download url: ${downloadUrl}');

      // put data
      var result = await backendService.atClientInstance
          .put(atKey, downloadUrl); // jsonEncode missing

      print('notification sent: ${result}');
    } catch (e) {
      print('Error in upload $e');
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

enum FLUSHBAR_STATUS { IDLE, SENDING, FAILED }
