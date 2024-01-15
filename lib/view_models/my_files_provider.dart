import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
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

import '../screens/my_files/widgets/recent.dart';

class MyFilesProvider extends BaseModel {
  var myFiles = <FileTransfer>[];
  List<FilesDetail> receivedPhotos = [],
      receivedVideos = [],
      receivedAudio = [],
      receivedApk = [],
      receivedZip = [],
      receivedDocument = [],
      recentFile = [],
      allFiles = [],
      displayFiles = [],
      receivedUnknown = [];

  List<String> tabNames = ['Recents'];
  String SORT_FILES = 'sort_files';
  String POPULATE_TABS = 'populate_tabs';
  String SORT_LIST = 'sort_list';
  String RECENT_HISTORY = 'recent_history';
  String ALL_FILES = 'all_files';
  String MY_FILES = 'my_files';
  String FETCH_AND_SORT = "fetch_and_sort";
  String fileSearchText = '';

  List<Widget> tabs = [Recent()];

  Map<String, List<FilesDetail>> filesByAlpha = {};
  FileType? typeSelected;

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
    receivedZip = [];
    receivedDocument = [];
    recentFile = [];
    receivedUnknown = [];
    allFiles = [];
    tabs = [Recent()];
    tabNames = ['Recents'];
  }

  void changeTypeSelected(FileType? type) {
    typeSelected = type;
    displayFiles = filterFiles(type);
  }

  List<FilesDetail> filterFiles(FileType? type) {
    switch (type) {
      case FileType.photo:
        return receivedPhotos;
      case FileType.video:
        return receivedVideos;
      case FileType.audio:
        return receivedAudio;
      case FileType.zips:
        return receivedZip;
      case FileType.document:
        return receivedDocument;
      case FileType.other:
        return receivedUnknown;
      default:
        return allFiles;
    }
  }

  Future<void> getMyFilesRecords() async {
    var atClient = AtClientManager.getInstance().atClient;

    setStatus(MY_FILES, Status.Loading);
    List<FileTransfer> myFilesRecord = [];
    var myFilesAtKeys =
        await atClient.getAtKeys(regex: MixedConstants.MY_FILES_KEY);

    await Future.forEach(myFilesAtKeys, (AtKey atKey) async {
      AtValue atValue = await atClient.get(atKey).catchError(
        (e) {
          print("Exception in getting my files atValue: $e");
          return AtValue();
        },
      );

      if (atValue.value != null) {
        try {
          FileTransfer fileTransferObject =
              FileTransfer.fromJson(jsonDecode(atValue.value));

          myFilesRecord.insert(0, fileTransferObject);
        } catch (e) {
          print('error in getAllFileTransferData file model conversion: $e');
        }
      }
    });
    myFiles = myFilesRecord;
    print('myFiles length: ${myFiles.length}');
    await sortFiles();
    populateTabs();
    setStatus(MY_FILES, Status.Done);
  }

  fetchAndSortFiles() async {
    var atClient = AtClientManager.getInstance().atClient;

    setStatus(FETCH_AND_SORT, Status.Loading);
    List<FileTransfer> myFilesRecord = [];
    var myFilesAtKeys =
        await atClient.getAtKeys(regex: MixedConstants.MY_FILES_KEY);

    await Future.forEach(myFilesAtKeys, (AtKey atkey) async {
      AtValue atValue = await atClient.get(atkey).catchError(
        (e) {
          print("Exception in getting my files atValue: $e");
          return AtValue();
        },
      );

      if (atValue.value != null) {
        try {
          FileTransfer fileTransferObject =
              FileTransfer.fromJson(jsonDecode(atValue.value));

          myFilesRecord.insert(0, fileTransferObject);
        } catch (e) {
          print('error in getAllFileTransferData file model conversion: $e');
        }
      }
    });
    myFiles = myFilesRecord;
    print('myFiles length: ${myFiles.length}');
    await getAllFiles();
    await sortFiles();
    await getrecentHistoryFiles();

    // populateTabs();
    setStatus(FETCH_AND_SORT, Status.Done);
  }

  sortAllFiles() async {
    try {
      setStatus(SORT_FILES, Status.Loading);
      receivedAudio = [];
      receivedApk = [];
      receivedZip = [];
      receivedDocument = [];
      receivedPhotos = [];
      receivedVideos = [];
      receivedUnknown = [];
      recentFile = [];

      await Future.forEach(allFiles, (FilesDetail file) async {
        var fileExtension = file.fileName?.split('.').last ?? "";
        if (FileTypes.AUDIO_TYPES.contains(fileExtension)) {
          int index = receivedAudio
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            receivedAudio.add(file);
          }
        } else if (FileTypes.VIDEO_TYPES.contains(fileExtension)) {
          int index = receivedVideos
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            receivedVideos.add(file);
          }
        } else if (FileTypes.IMAGE_TYPES.contains(fileExtension)) {
          int index = receivedPhotos
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            // checking is photo is downloaded or not
            //if photo is downloaded then only it's shown in my files screen
            // File file = File(element.filePath!);
            // bool isFileDownloaded = await file.exists();

            // if (isFileDownloaded) {
            receivedPhotos.add(file);
            // }
          }
        } else if (FileTypes.TEXT_TYPES.contains(fileExtension) ||
            FileTypes.PDF_TYPES.contains(fileExtension) ||
            FileTypes.WORD_TYPES.contains(fileExtension) ||
            FileTypes.EXEL_TYPES.contains(fileExtension)) {
          int index = receivedDocument
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            receivedDocument.add(file);
          }
        } else if (FileTypes.ZIP_TYPES.contains(fileExtension)) {
          int index = receivedZip
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            receivedZip.add(file);
          }
        } else {
          int index = receivedUnknown
              .indexWhere((element) => element.fileName == file.fileName);
          if (index == -1) {
            receivedUnknown.add(file);
          }
        }
      });

      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      print(e);
      setStatus(SORT_FILES, Status.Done);
    }
  }

  sortFiles() async {
    try {
      setStatus(SORT_FILES, Status.Loading);
      receivedAudio = [];
      receivedApk = [];
      receivedZip = [];
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
                (fileData.sender ?? "") +
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
              message: fileData.notes,
              fileTransferId: fileData.key);

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
              receivedPhotos.add(fileDetail);
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
          } else if (FileTypes.ZIP_TYPES.contains(fileExtension)) {
            int index = receivedZip.indexWhere(
                (element) => element.fileName == fileDetail.fileName);
            if (index == -1) {
              receivedZip.add(fileDetail);
            }
          } else {
            int index = receivedUnknown.indexWhere(
                (element) => element.fileName == fileDetail.fileName);
            if (index == -1) {
              receivedUnknown.add(fileDetail);
            }
          }
          // }
        });
      });
      getrecentHistoryFiles();
      setStatus(SORT_FILES, Status.Done);
    } catch (e) {
      setError(SORT_FILES, e.toString());
    }
  }

  void searchFileByKeyword({
    required String key,
    FileType? type,
  }) {
    final result = filterFiles(type)
        .where(
          (element) => (element.fileName ?? '')
              .toLowerCase()
              .trim()
              .contains(key.toLowerCase().trim()),
        )
        .toList();
    displayFiles = result;
    notifyListeners();
  }

  populateTabs() {
    bool isDesktop = false;
    tabNames = ['Recents'];
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      isDesktop = true;
    }
    tabs = [];
    tabs = [isDesktop ? DesktopRecent() : Recent()];

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
                (fileData.sender ?? "") +
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
              message: fileData.notes,
              fileTransferId: fileData.key);

          // File tempFile = File(fileDetail.filePath!);
          // bool isFileDownloaded = await tempFile.exists();
          int index = recentFile
              .indexWhere((element) => element.fileName == fileDetail.fileName);

          if (index == -1) {
            recentFile.add(fileDetail);
          }
        });
      });
      setStatus(RECENT_HISTORY, Status.Done);
    } catch (e) {
      setStatus(RECENT_HISTORY, Status.Error);
    }
  }

  notify() {
    notifyListeners();
  }

  Future<void> getAllFiles() async {
    setStatus(ALL_FILES, Status.Loading);
    allFiles = [];
    try {
      await Future.forEach(myFiles, (FileTransfer fileData) async {
        await Future.forEach(fileData.files!, (FileData file) async {
          String filePath;

          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
            filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
                Platform.pathSeparator +
                (fileData.sender ?? "") +
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
            fileTransferId: fileData.key,
            message: fileData.notes,
          );

          allFiles.add(fileDetail);
        });
      });
      displayFiles = filterFiles(typeSelected);
      // await sortFilesByAlpha(allFiles);
      setStatus(ALL_FILES, Status.Done);
    } catch (e) {
      setStatus(ALL_FILES, Status.Error);
    }
  }

  Future<void> sortFilesByAlpha(List<FilesDetail> files) async {
    for (int i = 0; i < files.length; i++) {
      String fileName = (files[i].fileName ?? '').trim();
      bool isExist = false;
      final firstName = fileName.split('').first.toUpperCase();

      if (filesByAlpha.isNotEmpty) {
        for (int i = 0; i < filesByAlpha.length; i++) {
          if (firstName.contains(filesByAlpha.keys.toString())) {
            isExist = true;
            break;
          }
        }
      }

      if (filesByAlpha.isEmpty || !isExist) {
        filesByAlpha.addAll(
          {
            firstName: [files[i]],
          },
        );
      } else {
        filesByAlpha.update(firstName, (value) {
          value.add(files[i]);
          return value;
        });
      }
    }
    filesByAlpha.keys.toList().sort();
    print(filesByAlpha);
  }

  setFileSearchText(String str) {
    fileSearchText = str;
    notifyListeners();
  }

  saveNewDataInMyFiles(FileTransfer fileTransfer) async {
    for (FileTransfer myFile in myFiles) {
      if (myFile.key == fileTransfer.key) {
        return;
      }
    }

    var _atClient = AtClientManager.getInstance().atClient;
    var _keyStore = _atClient.getLocalSecondary()!.keyStore!;

    var fileAtKey = formMyFileAtKey(fileTransfer.key);

    if (!_keyStore.isKeyExists(fileAtKey.key!)) {
      var res = await _atClient.put(
        fileAtKey,
        jsonEncode(fileTransfer.toJson()),
      );

      if (res) {
        await Future.forEach(fileTransfer.files!, (FileData file) async {
          String filePath;

          if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
            filePath = MixedConstants.RECEIVED_FILE_DIRECTORY +
                Platform.pathSeparator +
                fileTransfer.sender! +
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
            date: fileTransfer.date?.toLocal().toString(),
            type: file.name!.split('.').last,
            contactName: fileTransfer.sender,
            message: fileTransfer.notes,
            fileTransferId: fileTransfer.key,
          );

          allFiles.insert(0, fileDetail);
        });

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
        // also remove file from allFiles
        FilesDetail? fileToDelete;
        for (var file in allFiles) {
          if (file.fileTransferId == fileTransferId &&
              file.fileName == filename) {
            fileToDelete = file;
            break;
          }
        }
        allFiles.remove(fileToDelete);
      }
    }

    bool res = false;
    if (myFiles[myFileIndex].files!.isEmpty) {
      res = await deleteMyFileRecord(fileTransferId);
    } else {
      res = await updateMyFilesData(myFiles[myFileIndex]);
    }

    if (res) {
      await sortFiles();
      populateTabs();
    }
    notifyListeners();
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
      ..metadata = Metadata()
      ..metadata!.ttr = -1;
  }

  Future<bool> deleteMyFileRecord(String fileTransferId) async {
    var _atClient = AtClientManager.getInstance().atClient;
    var myFileAtKey = formMyFileAtKey(fileTransferId);
    var res = await _atClient.delete(myFileAtKey);
    if (res) {
      var i = myFiles.indexWhere((element) => element.key == fileTransferId);
      if (i != -1) {
        myFiles.removeAt(i);
      }

      await sortFiles();
      populateTabs();
    }

    return res;
  }

  /// for testing only
  deleteMyFileKeys() async {
    var atClient = AtClientManager.getInstance().atClient;
    var myFilesAtKeys =
        await atClient.getAtKeys(regex: MixedConstants.MY_FILES_KEY);

    await Future.forEach(myFilesAtKeys, (AtKey atKey) async {
      var deleted = await atClient.delete(atKey);
      print('deleted : ${deleted}');
    });

    await sortFiles();
    populateTabs();
  }
}
