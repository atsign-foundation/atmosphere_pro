import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/permission_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/file_recipients.dart';
import 'package:atsign_atmosphere_pro/services/exception_service.dart';
import 'package:atsign_atmosphere_pro/services/file_transfer_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/notification_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/file_progress_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/internet_connectivity_checker.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;

class FileTransferProvider extends BaseModel {
  FileTransferProvider._();

  static final FileTransferProvider _instance = FileTransferProvider._();

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
  List<GroupContactsModel> selectedContacts = [];
  List<FileTransferStatus> transferStatus = [];
  Map<String, List<Map<String, bool>>> transferStatusMap = {};
  bool sentStatus = false, isFileSending = false;
  Uint8List? videoThumbnail;
  double totalSize = 0;
  bool clearList = false;
  List<AtContact> temporaryContactList = [];
  bool hasSelectedFilesChanged = false, scrollToBottom = false;

  final _flushBarStream = StreamController<FLUSHBAR_STATUS>.broadcast();

  Stream<FLUSHBAR_STATUS> get flushBarStatusStream => _flushBarStream.stream;

  StreamSink<FLUSHBAR_STATUS> get flushBarStatusSink => _flushBarStream.sink;

  FileHistory? _selectedFileHistory;

  resetData() {
    selectedFiles = [];
    selectedContacts = [];
    setStatus(PICK_FILES, Status.Done);
  }

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
        for (var element in appClosedSharedFiles) {
          selectedFiles.add(element);
        }
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
    if (Platform.isAndroid &&
        ((await DeviceInfoPlugin().androidInfo).version.sdkInt < 33)) {
      PermissionStatus status = await Permission.storage.status;
      if (status.isDenied) {
        await showNoPermissionDialog();
        return;
      }
    }

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

        for (var element in result!.files) {
          selectedFiles.add(element);
        }
        if (appClosedSharedFiles.isNotEmpty) {
          for (var element in appClosedSharedFiles) {
            selectedFiles.add(element);
          }
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

  void deleteFiles(int fileIndex) {
    selectedFiles.removeAt(fileIndex);
    notifyListeners();
  }

  showNoPermissionDialog() async {
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content: const PermissionDeniedMessage(
                  TextStrings.permissionRequireMessage));
        });
  }

  calculateSize() async {
    totalSize = 0;
    for (var element in selectedFiles) {
      totalSize += element.size;
    }
  }

  void acceptFiles() async {
    setStatus(ACCEPT_FILES, Status.Loading);
    try {
      ReceiveSharingIntent.getMediaStream().listen(
          (List<SharedMediaFile> value) {
        _sharedFiles = value;

        if (value.isNotEmpty) {
          value.forEach((element) async {
            File file = File(element.path);
            double length = double.parse(file.length().toString());

            selectedFiles.add(PlatformFile(
                name: basename(file.path),
                path: file.path,
                size: length.round(),
                bytes: await file.readAsBytes()));
            await calculateSize();
            hasSelectedFilesChanged = true;
          });
        }
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

      // For sharing images coming from outside the app while the app is closed
      await ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> value) {
        _sharedFiles = value;
        if ((_sharedFiles ?? []).isNotEmpty) {
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
  Future<dynamic> sendFileWithFileBin(
      List<PlatformFile> selectedFiles, List<GroupContactsModel?> contactList,
      {String? groupName, String? notes}) async {
    flushBarStatusSink.add(FLUSHBAR_STATUS.SENDING);
    var notifProvider = Provider.of<NotificationService>(
        NavService.navKey.currentContext!,
        listen: false);
    bool shareStatus = true;

    setStatus(SEND_FILES, Status.Loading);
    var fileUploadProvider = Provider.of<FileProgressProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    try {
      var historyProvider = Provider.of<HistoryProvider>(
          NavService.navKey.currentContext!,
          listen: false);

      var files = <File>[];
      var atSigns = <String>[];

      for (var element in selectedFiles) {
        files.add(File(element.path!));
      }

      for (var groupContact in contactList) {
        if (groupContact!.contact != null) {
          var index =
              atSigns.indexWhere((el) => el == groupContact.contact!.atSign);
          if (index == -1) atSigns.add(groupContact.contact!.atSign!);
        } else if (groupContact.group != null) {
          for (var member in groupContact.group!.members!) {
            var index = atSigns.indexWhere((el) => el == member.atSign);
            if (index == -1) atSigns.add(member.atSign!);
          }
        }
      }

      notifProvider.updateCurrentFileShareStatus(
        FileTransfer(
          url: '',
          key: '',
          fileEncryptionKey: '',
          files:
              files.map((File e) => FileData(name: e.path, size: 0)).toList(),
          atSigns: atSigns,
        ),
        FLUSHBAR_STATUS.SENDING,
      );

      var uploadResult = await FileTransferService.getInstance().uploadFile(
        files,
        atSigns,
        notes: notes,
      );

      await historyProvider.saveNewSentFileItem(
        uploadResult[atSigns[0]]!,
        atSigns,
        uploadResult,
        groupName: groupName,
      );

      historyProvider.changeIsUpcomingEvent();

      // checking if everyone received the notification or not.
      for (var atsignStatus in uploadResult.entries) {
        if (atsignStatus.value.sharedStatus != null &&
            !atsignStatus.value.sharedStatus!) {
          fileUploadProvider.removeSentFileProgress();
          setStatus(SEND_FILES, Status.Error);
          setError(
            SEND_FILES,
            ExceptionService.instance.notifyExceptions(
              atsignStatus.value.atClientException ?? Exception(),
            ),
          );
          flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
          await showRetrySending();
          shareStatus = false;
        }
      }

      FileHistory fileHistory =
          historyProvider.convertFileTransferObjectToFileHistory(
        uploadResult[atSigns[0]]!,
        atSigns,
        uploadResult,
      );
      notifProvider.updateCurrentFileShareStatus(
        null,
        FLUSHBAR_STATUS.DONE,
      );
      notifProvider.addRecentNotifications(fileHistory);

      fileUploadProvider.removeSentFileProgress();
      flushBarStatusSink.add(FLUSHBAR_STATUS.DONE);
      setStatus(SEND_FILES, Status.Done);
      return shareStatus;
    } catch (e) {
      fileUploadProvider.removeSentFileProgress();
      notifProvider.updateCurrentFileShareStatus(
        null,
        FLUSHBAR_STATUS.FAILED,
      );
      setStatus(SEND_FILES, Status.Error);
      setError(
        SEND_FILES,
        'Something went wrong',
      );
      flushBarStatusSink.add(FLUSHBAR_STATUS.FAILED);
      await showRetrySending();
    }
  }

  Future<void> showRetrySending() async {
    await NavService.navKey.currentContext!
        .read<InternetConnectivityChecker>()
        .checkConnectivity();
    final bool isInternetAvailable = NavService.navKey.currentContext!
        .read<InternetConnectivityChecker>()
        .isInternetAvailable;
    if (isInternetAvailable) {
      await openFileReceiptBottomSheet();
    } else {
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        await NavService.navKey.currentContext!
            .read<InternetConnectivityChecker>()
            .checkConnectivity();
        final bool isInternetAvailable = NavService.navKey.currentContext!
            .read<InternetConnectivityChecker>()
            .isInternetAvailable;
        if (isInternetAvailable) {
          timer.cancel();
          await openFileReceiptBottomSheet();
        }
      });
    }
  }

  openFileReceiptBottomSheet(
      {FileRecipientSection? fileRecipientSection}) async {
    await Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .getSentHistory();
    final List<FileHistory> sentList = Provider.of<HistoryProvider>(
            NavService.navKey.currentContext!,
            listen: false)
        .sentHistory;
    selectedFileHistory = sentList[0];

    if (!(sentList[0].fileDetails?.files ?? [])
        .any((element) => element.isUploaded == false)) {
      await showModalBottomSheet(
        context: NavService.navKey.currentContext!,
        isScrollControlled: true,
        shape: const StadiumBorder(),
        builder: (context) {
          return Container(
            height: SizeConfig().screenHeight * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(NavService.navKey.currentContext!)
                  .scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: FileRecipients(
              sentList[0].sharedWith,
              fileRecipientSection: fileRecipientSection,
              key: UniqueKey(),
            ),
          );
        },
      ).then((value) {
        resetData();
        Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
                listen: false)
            .resetData();
      });
    }
  }

// when file share fails and user taps on resend button.
// we would iterate over every atsigns and attempt to share the file again.
  Future<bool> reAttemptInSendingFiles() async {
    var historyProvider = Provider.of<HistoryProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    FileHistory fileHistory;
    if (historyProvider.sentHistory.isNotEmpty) {
      fileHistory = historyProvider.sentHistory[0];
    } else {
      return false;
    }

    try {
      flushBarStatusSink.add(FLUSHBAR_STATUS.SENDING);

      //  reuploading files
      for (var fileData in fileHistory.fileDetails!.files!) {
        if (fileData.isUploaded != null && !fileData.isUploaded!) {
          await reuploadFiles([fileData], 0, fileHistory);
        }
      }

      //  resending notifications
      for (var element in fileHistory.sharedWith!) {
        if (element.isNotificationSend != null &&
            !element.isNotificationSend!) {
          await reSendFileNotification(fileHistory, element.atsign!);
        }
      }

      // checking if any notification didn't go through
      fileHistory = historyProvider.sentHistory[0];
      for (var element in fileHistory.sharedWith!) {
        if (element.isNotificationSend != null &&
            !element.isNotificationSend!) {
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
      List<FileData> filesList, int index, FileHistory sentHistory) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);
    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateFileSendingStatus(
      isUploading: true,
      isUploaded: false,
      id: sentHistory.fileDetails!.key,
      filename: filesList[index].name,
    );

    try {
      File file =
          File(MixedConstants.DESKTOP_SENT_DIR + filesList[index].name!);

      bool fileExists = await file.exists();
      if (!fileExists) {
        throw Exception('file not found');
      }

      var uploadStatus = await FileTransferService.getInstance()
          .reuploadFiles([file], sentHistory.fileTransferObject!);

      if (uploadStatus.isNotEmpty && uploadStatus[0].isUploaded!) {
        var resultIndex = sentHistory.fileDetails!.files!
            .indexWhere((element) => element.name == filesList[index].name);

        if (resultIndex > -1) {
          sentHistory.fileDetails!.files![resultIndex].isUploaded = true;
        }

        var i = sentHistory.fileTransferObject!.fileStatus.indexWhere(
            (element) => element.fileName == filesList[resultIndex].name);
        if (i > -1) {
          sentHistory.fileTransferObject!.fileStatus[i].isUploaded = true;
        }

        // sending file upload notification to every atsign
        await Future.forEach(sentHistory.sharedWith!,
            (ShareStatus sharedWith) async {
          await reSendFileNotification(sentHistory, sharedWith.atsign!);
        });

        Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .updateFileSendingStatus(
          isUploading: false,
          isUploaded: true,
          id: sentHistory.fileDetails!.key,
          filename: filesList[resultIndex].name,
        );
      } else {
        Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .updateFileSendingStatus(
          isUploading: false,
          isUploaded: false,
          id: sentHistory.fileDetails!.key,
          filename: filesList[index].name,
        );
      }
      setStatus(RETRY_NOTIFICATION, Status.Done);
    } catch (e) {
      setStatus(RETRY_NOTIFICATION, Status.Error);
      Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
              listen: false)
          .updateFileSendingStatus(
        isUploading: false,
        isUploaded: true,
        id: sentHistory.fileDetails!.key,
        filename: filesList[index].name,
      );
    }
  }

  reSendFileNotification(FileHistory fileHistory, String atsign) async {
    setStatus(RETRY_NOTIFICATION, Status.Loading);

    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateSendingNotificationStatus(
            fileHistory.fileTransferObject!.transferId, atsign, true);

    Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
            listen: false)
        .updateSendingNotificationStatus(
            fileHistory.fileTransferObject!.transferId, atsign, true);
    try {
      var sendResponse = await FileTransferService.getInstance().shareFiles(
          [atsign],
          fileHistory.fileTransferObject!.transferId,
          fileHistory.fileTransferObject!.fileUrl,
          fileHistory.fileTransferObject!.fileEncryptionKey,
          fileHistory.fileTransferObject!.fileStatus,
          date: fileHistory.fileTransferObject!.date,
          notes: fileHistory.notes);

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

  notify() {
    notifyListeners();
  }

  void removeSelectedContact(int index) {
    selectedContacts.removeAt(index);
    notifyListeners();
  }
}

enum FLUSHBAR_STATUS { IDLE, SENDING, FAILED, DONE }
