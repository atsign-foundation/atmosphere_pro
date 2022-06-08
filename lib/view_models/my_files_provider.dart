import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_apk.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_audios.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_documents.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_photos.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_recent.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_unknowns.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_videos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/apk.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/audios.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/documents.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/photos.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/unknowns.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/videos.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';

import '../screens/my_files/widgets/recents.dart';

class MyFilesProvider extends BaseModel {
  var myFiles = <FileTransfer>[];
  List<FilesDetail> receivedPhotos = [],
      receivedVideos = [],
      receivedAudio = [],
      receivedApk = [],
      receivedDocument = [],
      recentFile = [],
      receivedUnknown = [];
  List<String> tabNames = ['Recents'];
  String SORT_FILES = 'sort_files';
  String POPULATE_TABS = 'populate_tabs';
  String SORT_LIST = 'sort_list';
  String RECENT_HISTORY = 'recent_history';
  String MY_FILES = 'my_files';

  List<Widget> tabs = [Recents()];

  init() async {
    await getMyFilesRecords();
    await sortFiles();
    await populateTabs();
  }

  resetData() {
    receivedPhotos = [];
    receivedVideos = [];
    receivedAudio = [];
    receivedApk = [];
    receivedDocument = [];
    recentFile = [];
    receivedUnknown = [];
    tabs = [Recents()];
    tabNames = ['Recents'];
  }

  getMyFilesRecords() async {
    var atClient = AtClientManager.getInstance().atClient;

    setStatus(MY_FILES, Status.Loading);
    List<FileTransfer> myFilesRecord = [];
    var myFilesAtKeys =
        await atClient.getAtKeys(regex: MixedConstants.MY_FILES_KEY);

    await Future.forEach(myFilesAtKeys, (AtKey atkey) async {
      AtValue atvalue = await atClient.get(atkey).catchError(
        (e) {
          print("Exception in getting my files atValue: $e");
          return AtValue();
        },
      );

      if (atvalue.value != null) {
        try {
          FileTransfer fileTransferObject =
              FileTransfer.fromJson(jsonDecode(atvalue.value));

          myFilesRecord.insert(0, fileTransferObject);
        } catch (e) {
          print('error in getAllFileTransferData file model conversion: $e');
        }
      }
    });
    myFiles = myFilesRecord;
    await sortFiles();
    populateTabs();
    setStatus(MY_FILES, Status.Done);
  }

  sortFiles() async {
    try {
      setStatus(SORT_FILES, Status.Loading);
      receivedAudio = [];
      receivedApk = [];
      receivedDocument = [];
      receivedPhotos = [];
      receivedVideos = [];
      receivedUnknown = [];
      recentFile = [];

      myFiles.sort((a, b) => b.date!.compareTo(a.date!));

      await Future.forEach(myFiles, (FileTransfer fileData) async {
        await Future.forEach(fileData.files!, (dynamic file) async {
          String? fileExtension = file.name.split('.').last;
          String filePath =
              BackendService.getInstance().downloadDirectory!.path +
                  Platform.pathSeparator +
                  file.name;

          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
            filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
                Platform.pathSeparator +
                fileData.sender! +
                Platform.pathSeparator +
                file.name;
          }
          FilesDetail fileDetail = FilesDetail(
              fileName: file.name,
              filePath: filePath,
              size: double.parse(file.size.toString()),
              date: fileData.date?.toLocal().toString(),
              type: file.name.split('.').last,
              contactName: fileData.sender,
              fileTransferId: fileData.key);

          // check if file exists
          File tempFile = File(fileDetail.filePath!);
          bool isFileDownloaded = await tempFile.exists();

          if (isFileDownloaded) {
            if (FileTypes.AUDIO_TYPES.contains(fileExtension)) {
              int index = receivedAudio.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedAudio.add(fileDetail);
              }
            } else if (FileTypes.VIDEO_TYPES.contains(fileExtension)) {
              int index = receivedVideos.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedVideos.add(fileDetail);
              }
            } else if (FileTypes.IMAGE_TYPES.contains(fileExtension)) {
              int index = receivedPhotos.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                // checking is photo is downloaded or not
                //if photo is downloaded then only it's shown in my files screen
                File file = File(fileDetail.filePath!);
                bool isFileDownloaded = await file.exists();

                if (isFileDownloaded) {
                  receivedPhotos.add(fileDetail);
                }
              }
            } else if (FileTypes.TEXT_TYPES.contains(fileExtension) ||
                FileTypes.PDF_TYPES.contains(fileExtension) ||
                FileTypes.WORD_TYPES.contains(fileExtension) ||
                FileTypes.EXEL_TYPES.contains(fileExtension)) {
              int index = receivedDocument.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedDocument.add(fileDetail);
              }
            } else if (FileTypes.APK_TYPES.contains(fileExtension)) {
              int index = receivedApk.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedApk.add(fileDetail);
              }
            } else {
              int index = receivedUnknown.indexWhere(
                  (element) => element.fileName == fileDetail.fileName);
              if (index == -1) {
                receivedUnknown.add(fileDetail);
              }
            }
          }
        });
      });
      getrecentHistoryFiles();
      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      setError(SORT_FILES, e.toString());
    }
  }

  populateTabs() {
    bool isDesktop = false;
    tabNames = ['Recents'];
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      isDesktop = true;
    }
    tabs = [];
    tabs = [isDesktop ? DesktopRecents() : Recents()];

    try {
      setStatus(POPULATE_TABS, Status.Loading);

      if (receivedApk.isNotEmpty) {
        if (!tabs.contains(APK)) {
          tabs.add(isDesktop ? DesktopAPK() : APK());
          tabNames.add('APK');
        }
      }
      if (receivedAudio.isNotEmpty) {
        if (!tabs.contains(Audios)) {
          tabs.add(isDesktop ? DesktopAudios() : Audios());
          tabNames.add('Audios');
        }
      }
      if (receivedDocument.isNotEmpty) {
        if (!tabs.contains(Documents)) {
          tabs.add(isDesktop ? DesktopDocuments() : Documents());
          tabNames.add('Documents');
        }
      }
      if (receivedPhotos.isNotEmpty) {
        if (!tabs.contains(Photos)) {
          tabs.add(isDesktop ? DesktopPhotos() : Photos());
          tabNames.add('Photos');
        }
      }
      if (receivedVideos.isNotEmpty) {
        if (!tabs.contains(Videos)) {
          tabs.add(isDesktop ? DesktopVideos() : Videos());
          tabNames.add('Videos');
        }
      }
      if (receivedUnknown.isNotEmpty) {
        if (!tabs.contains(Unknowns())) {
          tabs.add(isDesktop ? DesktopUnknowns() : Unknowns());
          tabNames.add('Unknowns');
        }
      }
      setStatus(POPULATE_TABS, Status.Done);
    } catch (e) {
      setError(POPULATE_TABS, e.toString());
    }
  }

  sortByName(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) => a.fileName!.compareTo(b.fileName!));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortBySize(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) => a.size!.compareTo(b.size!));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortByType(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);
      list.sort((a, b) =>
          a.fileName!.split('.').last.compareTo(b.fileName!.split('.').last));

      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  sortByDate(List<FilesDetail> list) {
    try {
      setStatus(SORT_LIST, Status.Loading);

      list.sort(
          (a, b) => DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!)));
      setStatus(SORT_LIST, Status.Done);
    } catch (e) {
      setError(SORT_LIST, e.toString());
    }
  }

  getrecentHistoryFiles() async {
    // finding last 15 received files data for recent tab
    setStatus(RECENT_HISTORY, Status.Loading);
    try {
      var lastTenFilesData =
          myFiles.sublist(0, myFiles.length > 15 ? 15 : myFiles.length);

      await Future.forEach(lastTenFilesData, (FileTransfer fileData) async {
        await Future.forEach(fileData.files!, (FileData file) async {
          String filePath;

          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
            filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
                Platform.pathSeparator +
                fileData.sender! +
                Platform.pathSeparator +
                (file.name ?? '');
          } else {
            filePath = BackendService.getInstance().downloadDirectory!.path +
                Platform.pathSeparator +
                (file.name ?? '');
          }

          FilesDetail fileDetail = FilesDetail(
              fileName: file.name,
              filePath: filePath,
              size: double.parse(file.size.toString()),
              date: fileData.date?.toLocal().toString(),
              type: file.name!.split('.').last,
              contactName: fileData.sender,
              fileTransferId: fileData.key);

          File tempFile = File(fileDetail.filePath!);
          bool isFileDownloaded = await tempFile.exists();
          int index = recentFile
              .indexWhere((element) => element.fileName == fileDetail.fileName);

          if (isFileDownloaded && index == -1) {
            recentFile.add(fileDetail);
          }
        });
      });
      setStatus(RECENT_HISTORY, Status.Done);
    } catch (e) {
      setStatus(RECENT_HISTORY, Status.Error);
    }
  }

  /// loops over receivedHistoryData and checks if my files is saved for a particular item.
  // saveMyFilesItems(List<FileTransfer> receivedHistoryLogs) async {
  //   var _atClient = AtClientManager.getInstance().atClient;
  //   var keyStore = _atClient.getLocalSecondary()!.keyStore!;
  //   bool _isNewKeyAdded = false;

  //   for (int i = 0; i < receivedHistoryLogs.length; i++) {
  //     String transferUniqueId = receivedHistoryLogs[i]
  //         .key
  //         .replaceAll(MixedConstants.FILE_TRANSFER_KEY, '');
  //     var fileAtKey = formMyFileAtKey(transferUniqueId);

  //     print(
  //         'transferId : ${transferUniqueId}: ${_atClient.getLocalSecondary()!.keyStore!.isKeyExists(fileAtKey.key!)}');
  //     if (!keyStore.isKeyExists(fileAtKey.key!)) {
  //       _isNewKeyAdded = true;
  //       var res = await _atClient.put(
  //         fileAtKey,
  //         jsonEncode(receivedHistoryLogs[i].toJson()),
  //       );

  //       if (res) {
  //         myFiles.insert(0, receivedHistoryLogs[i]);
  //       }

  //       print('res: ${res}');
  //     }
  //   }

  //   if (_isNewKeyAdded) {
  //     await sortFiles();
  //     populateTabs();
  //   }
  // }

  saveNewDataInMyFiles(FileTransfer fileTransfer) async {
    var _atClient = AtClientManager.getInstance().atClient;
    var _keyStore = _atClient.getLocalSecondary()!.keyStore!;

    var fileAtKey = formMyFileAtKey(fileTransfer.key);

    if (!_keyStore.isKeyExists(fileAtKey.key!)) {
      var res = await _atClient.put(
        fileAtKey,
        jsonEncode(fileTransfer.toJson()),
      );

      if (res) {
        myFiles.insert(
          0,
          FileTransfer.fromJson(
            jsonDecode(
              jsonEncode(
                fileTransfer.toJson(),
              ),
            ),
          ),
        );
        await sortFiles();
        populateTabs();
      }
    }
  }

  Future<bool> removeParticularFile(
      String fileTransferId, String filename) async {
    var myFileIndex =
        myFiles.indexWhere((element) => element.key == fileTransferId);
    var fileIndex = -1;
    if (myFileIndex != -1) {
      var myFile = myFiles[myFileIndex];
      for (int i = 0; i < myFile.files!.length; i++) {
        if (myFile.files![i].name!.toLowerCase().contains(
              filename.toLowerCase(),
            )) {
          fileIndex = i;
          break;
        }
      }
      if (fileIndex != -1) {
        myFiles[myFileIndex].files!.removeAt(fileIndex);
      }
    }

    bool res = false;
    if (myFiles[myFileIndex].files!.isEmpty) {
      res = await deletMyFileRecord(fileTransferId);
    } else {
      res = await updateMyFilesData(myFiles[myFileIndex]);
    }

    if (res) {
      await sortFiles();
      populateTabs();
    }
    return res;
  }

  Future<bool> updateMyFilesData(FileTransfer fileTransfer) async {
    var _atClient = AtClientManager.getInstance().atClient;
    var fileAtKey = formMyFileAtKey(fileTransfer.key);

    return await _atClient.put(fileAtKey, jsonEncode(fileTransfer.toJson()));
  }

  AtKey formMyFileAtKey(String fileTransferId) {
    String transferUniqueId =
        fileTransferId.replaceAll(MixedConstants.FILE_TRANSFER_KEY, '');
    return AtKey()
      ..key = MixedConstants.MY_FILES_KEY + transferUniqueId
      ..sharedBy = AtClientManager.getInstance().atClient.getCurrentAtSign()
      ..metadata = Metadata();
  }

  Future<bool> deletMyFileRecord(String fileTransferId) async {
    var _atClient = AtClientManager.getInstance().atClient;
    var myFileAtKey = formMyFileAtKey(fileTransferId);
    var res = await _atClient.delete(myFileAtKey);
    if (res) {
      var i = myFiles.indexWhere((element) => element.key == fileTransferId);
      if (i != -1) {
        myFiles.removeAt(i);
      }
    }

    return res;
  }

  /// for testing only
  // deleteMyfilekeys() async {
  //   var atClient = AtClientManager.getInstance().atClient;
  //   var myFilesAtKeys =
  //       await atClient.getAtKeys(regex: MixedConstants.MY_FILES_KEY);

  //   await Future.forEach(myFilesAtKeys, (AtKey atkey) async {
  //     var deleted = await atClient.delete(atkey);
  //     print('deleted : ${deleted}');
  //   });

  //   await sortFiles();
  //   populateTabs();
  // }
}
