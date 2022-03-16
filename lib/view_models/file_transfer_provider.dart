import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;
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
  List<SharedMediaFile>? _sharedFiles;
  FilePickerResult? result;
  PlatformFile? file;
  FLUSHBAR_STATUS? flushbarStatus;
  List<PlatformFile> selectedFiles = [];
  List<FileTransferStatus> transferStatus = [];
  Map<String, List<Map<String, bool>>> transferStatusMap = {};
  bool sentStatus = false, isFileSending = false;
  Uint8List? videoThumbnail;
  double totalSize = 0;
  bool clearList = false;
  BackendService _backendService = BackendService.getInstance();
  List<AtContact> temporaryContactList = [];
  bool hasSelectedFilesChanged = false, scrollToBottom = false;

  final _flushBarStream = StreamController<FLUSHBAR_STATUS>.broadcast();
  Stream<FLUSHBAR_STATUS> get flushBarStatusStream => _flushBarStream.stream;
  StreamSink<FLUSHBAR_STATUS> get flushBarStatusSink => _flushBarStream.sink;

  FileHistory? _selectedFileHistory;

  set selectedFileHistory(FileHistory? fileHistory) {
    _selectedFileHistory = fileHistory;
  }

  FileHistory? get getSelectedFileHistory => _selectedFileHistory;

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

        result!.files.forEach((element) {
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

    // if ((totalSize / 1048576) >= 50) {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     _showFileSizeLimit();
    //   });
    // }
  }

  // _showFileSizeLimit() async {
  //   await showDialog(
  //       context: NavService.navKey.currentContext,
  //       builder: (_context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.toWidth),
  //           ),
  //           content: Container(
  //             color: Colors.white,
  //             width: 300.toWidth,
  //             padding: EdgeInsets.all(15.toFont),
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(TextStrings.fileSizeLimit,
  //                       style: CustomTextStyles.grey15),
  //                   SizedBox(
  //                     height: 10.toHeight,
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       TextButton(
  //                           onPressed: () {
  //                             Navigator.of(NavService.navKey.currentContext)
  //                                 .pop();
  //                           },
  //                           child: Text('Ok',
  //                               style: TextStyle(fontSize: 16.toFont)))
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });

  //   selectedFiles = [];
  //   totalSize = 0;
  //   hasSelectedFilesChanged = false;
  //   notifyListeners();
  // }

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
        if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
          _sharedFiles!.forEach((element) async {
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
          BuildContext c = NavService.navKey.currentContext!;
          Navigator.pushReplacementNamed(c, Routes.WELCOME_SCREEN);
        }
      });
      setStatus(ACCEPT_FILES, Status.Done);
    } catch (error) {
      setError(ACCEPT_FILES, error.toString());
    }
  }

  /// returns [true] when file is siccessfully saved and all recipients have received notification.
  /// returns [false] if file entry is saved in sent history but notification did not go to every recipient.
  /// returns [null] if file is not saved in sent history.
  Future<dynamic> sendFileWithFileBin(List<PlatformFile> selectedFiles,
      List<GroupContactsModel?> contactList) async {
    flushBarStatusSink.add(FLUSHBAR_STATUS.SENDING);
    setStatus(SEND_FILES, Status.Loading);
    try {
      var _atclient = BackendService.getInstance().atClientInstance!;
      var _historyProvider = Provider.of<HistoryProvider>(
          NavService.navKey.currentContext!,
          listen: false);

      FileTransfer filesToTransfer = FileTransfer(platformFiles: selectedFiles);
      var _files = <File>[];
      var _atSigns = <String>[];

      filesToTransfer.files!.forEach((element) {
        _files.add(File(element.path!));
      });

      contactList.forEach((groupContact) {
        if (groupContact!.contact != null) {
          var index =
              _atSigns.indexWhere((el) => el == groupContact.contact!.atSign);
          if (index == -1) _atSigns.add(groupContact.contact!.atSign!);
        } else if (groupContact.group != null) {
          groupContact.group!.members!.forEach((member) {
            var index = _atSigns.indexWhere((el) => el == member.atSign);
            if (index == -1) _atSigns.add(member.atSign!);
          });
        }
      });

      var uploadResult = await _atclient.uploadFile(_files, _atSigns);

      await _historyProvider.saveNewSentFileItem(
        uploadResult[_atSigns[0]]!,
        _atSigns,
        uploadResult,
      );

      // checking if everyone received the notification or not.
      for (var atsignStatus in uploadResult.entries) {
        if (atsignStatus.value.sharedStatus != null &&
            !atsignStatus.value.sharedStatus!) {
          setStatus(SEND_FILES, Status.Error);
          flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
          return false;
        }
      }

      flushBarStatusSink.add(FLUSHBAR_STATUS.DONE);
      setStatus(SEND_FILES, Status.Done);
      return true;
    } catch (e) {
      setStatus(SEND_FILES, Status.Error);
      flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
    }
  }

// when file share fails and user taps on resend button.
// we would iterate over every atsigns and attempt to share the file again.
  Future<bool> reAttemptInSendingFiles() async {
    var _historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    FileHistory _fileHistory;
    if (_historyProvider.sentHistory.isNotEmpty) {
      _fileHistory = _historyProvider.sentHistory[0];
    } else {
      return false;
    }

    try {
      flushBarStatusSink.add(FLUSHBAR_STATUS.SENDING);

      //  reuploading files
      for (var fileData in _fileHistory.fileDetails!.files!) {
        if (fileData.isUploaded != null && !fileData.isUploaded!) {
          await reuploadFiles([fileData], 0, _fileHistory);
        }
      }

      //  resending notifications
      for (var element in _fileHistory.sharedWith!) {
        if (element.isNotificationSend != null && !element.isNotificationSend!) {
          await reSendFileNotification(_fileHistory, element.atsign!);
        }
      }

      // checking if any notification didn't go through
      _fileHistory = _historyProvider.sentHistory[0];
      for (var element in _fileHistory.sharedWith!) {
        if (element.isNotificationSend != null && !element.isNotificationSend!) {
          flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
          return false;
        }
      }
      flushBarStatusSink.add(FLUSHBAR_STATUS.DONE);
      return true;
    } catch (e) {
      flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
      return false;
    }
  }

  reuploadFiles(
      List<FileData> _filesList, int _index, FileHistory _sentHistory) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);
    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateFileSendingStatus(
      isUploading: true,
      isUploaded: false,
      id: _sentHistory.fileDetails!.key,
      filename: _filesList[_index].name,
    );

    var _atclient = AtClientManager.getInstance().atClient;
    try {
      File file =
          File(MixedConstants.DESKTOP_SENT_DIR + _filesList[_index].name!);

      bool fileExists = await file.exists();
      if (!fileExists) {
        throw ('file not found');
      }

      var uploadStatus = await _atclient
          .reuploadFiles([file], _sentHistory.fileTransferObject!);

      if (uploadStatus is List<FileStatus> && uploadStatus.isNotEmpty) {
        if (uploadStatus[0].isUploaded!) {
          var index = _sentHistory.fileDetails!.files!
              .indexWhere((element) => element.name == _filesList[_index].name);

          if (index > -1) {
            _sentHistory.fileDetails!.files![index].isUploaded = true;
          }

          var i = _sentHistory.fileTransferObject!.fileStatus.indexWhere(
              (element) => element.fileName == _filesList[_index].name);
          if (i > -1) {
            _sentHistory.fileTransferObject!.fileStatus[i].isUploaded = true;
          }

          // sending file upload notification to every atsign
          await Future.forEach(_sentHistory.sharedWith!,
              (ShareStatus sharedWith) async {
            await reSendFileNotification(_sentHistory, sharedWith.atsign!);
          });

          Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .updateFileSendingStatus(
            isUploading: false,
            isUploaded: true,
            id: _sentHistory.fileDetails!.key,
            filename: _filesList[_index].name,
          );
        }
      }
      setStatus(RETRY_NOTIFICATION, Status.Done);
    } catch (e) {
      setStatus(RETRY_NOTIFICATION, Status.Error);
      Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .updateFileSendingStatus(
        isUploading: false,
        isUploaded: true,
        id: _sentHistory.fileDetails!.key,
        filename: _filesList[_index].name,
      );
    }
  }

  reSendFileNotification(FileHistory fileHistory, String atsign) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);
    var _atclient = AtClientManager.getInstance().atClient;

    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateSendingNotificationStatus(
            fileHistory.fileTransferObject!.transferId, atsign, true);

    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateSendingNotificationStatus(
            fileHistory.fileTransferObject!.transferId, atsign, true);
    try {
      var sendResponse = await _atclient.shareFiles(
          [atsign],
          fileHistory.fileTransferObject!.transferId,
          fileHistory.fileTransferObject!.fileUrl,
          fileHistory.fileTransferObject!.fileEncryptionKey,
          fileHistory.fileTransferObject!.fileStatus,
          date: fileHistory.fileTransferObject!.date);

      if (sendResponse[atsign]!.sharedStatus!) {
        var indexToUpdate = fileHistory.sharedWith!.indexWhere(
          (element) => element.atsign == atsign,
        );

        if (indexToUpdate > -1) {
          fileHistory.sharedWith![indexToUpdate].isNotificationSend = true;
        }
        await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .updateFileHistoryDetail(fileHistory);

        Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .updateSendingNotificationStatus(
                fileHistory.fileTransferObject!.transferId, atsign, false);

        setStatus(RETRY_NOTIFICATION, Status.Done);
      }
    } catch (e) {
      Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .updateSendingNotificationStatus(
              fileHistory.fileTransferObject!.transferId, atsign, false);
      setStatus(RETRY_NOTIFICATION, Status.Error);
    }
  }

  void resetSelectedFilesStatus() {
    hasSelectedFilesChanged = false;
  }

  updateFileSendingStatus(bool val) {
    isFileSending = val;
    notifyListeners();
  }
}

enum FLUSHBAR_STATUS { IDLE, SENDING, FAILED, DONE }
