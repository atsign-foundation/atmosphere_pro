import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;

class FilePickerProvider extends BaseModel {
  FilePickerProvider._();
  static FilePickerProvider _instance = FilePickerProvider._();
  factory FilePickerProvider() => _instance;
  String PICK_FILES = 'pick_files';
  String VIDEO_THUMBNAIL = 'video_thumbnail';
  String ACCEPT_FILES = 'accept_files';
  String SEND_FILES = 'send_files';
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  FilePickerResult result;
  PlatformFile file;
  static List<PlatformFile> appClosedSharedFiles = [];
  List<PlatformFile> selectedFiles = [];
  List<bool> sentStatus;
  Uint8List videoThumbnail;
  double totalSize = 0;
  final String MEDIA = 'MEDIA';
  final String FILES = 'FILES';
  BackendService _backendService = BackendService.getInstance();

  setFiles() async {
    setStatus(PICK_FILES, Status.Loading);
    try {
      selectedFiles = [];
      totalSize = 0;
      if (appClosedSharedFiles.isNotEmpty) {
        print('IN ! HERE');
        appClosedSharedFiles.forEach((element) {
          print('IN HERE @');
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
      _intentDataStreamSubscription =
          await ReceiveSharingIntent.getMediaStream().listen(
              (List<SharedMediaFile> value) {
        _sharedFiles = value;

        if (value.isNotEmpty) {
          value.forEach((element) async {
            File file = File(element.path);
            double length = await file.length() / 1024;
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
            var length = await test.length() / 1024;
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

  sendFiles(
      List<PlatformFile> selectedFiles, List<AtContact> contactList) async {
    setStatus(SEND_FILES, Status.Loading);
    try {
      sentStatus = List<bool>.generate(selectedFiles.length, (index) => false);
      List<Isolate> isolates =
          List.generate(contactList.length, (index) => null);
      ;
      // if (contactList.length > 20) {
      //   length = 20;
      // } else {
      //   length = contactList.length;
      // }
      print('before isolates');
      for (int i = 0; i < contactList.length; i++) {
        print('index======>$i');
        isolates[i] = await Isolate.spawn((message) {
          Isolate.spawn((message) {
            // send(contactList[i].atSign, selectedFiles, _backendService);
            print('IN ISOLATE');
          }, 'message');
        }, 'message');
      }
      print('ISOLATE LIST====>${isolates[0]}======>$isolates');
      // contactList.forEach((contact) {
      //   // selectedFiles.forEach((file) {
      //   //   _backendService.sendFile(contact.atSign, file.path);
      //   //   print('file path====>${file.path}');
      //   // });
      //   isolates = List.generate(conta, (index) => null);
      //   print('contact.atSign=====>${contact.atSign}');
      // });
      // selectedFiles.forEach((file) {
      //   contactList.forEach((contact) async {
      //     await _backendService.sendFile(contact.atSign, file.path);
      //   });
      // });
      print('SENT STATUS=====>${sentStatus.length}========>$sentStatus');
      setStatus(SEND_FILES, Status.Done);
    } catch (error) {
      setError(SEND_FILES, error.toString());
    }
  }

  static send(String contact, List selectedFiles, _backendService) async {
    // await _backendService.sendFile(
    //     contactList[contact].atSign, selectedFiles[file].path);
    selectedFiles.forEach((file) async {
      await _backendService.sendFile(contact, file.path);
    });
  }
}
