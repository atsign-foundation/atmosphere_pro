import 'dart:convert';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:file_picker/file_picker.dart';

class FileTransfer {
  String key, url, sender;
  List<FileData> files;
  DateTime date, expiry;
  List<PlatformFile> platformFiles;
  FileTransfer(
      {this.url,
      this.files,
      this.expiry,
      this.platformFiles,
      this.date,
      this.key}) {
    this.expiry = expiry ?? DateTime.now().add(Duration(days: 6));
    this.date = DateTime.now();

    if (files == null) {
      this.files = platformFileToFileData(platformFiles);
    }
  }

  FileTransfer.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    sender = json['sender'];
    key = json['key'];
    expiry = json['expiry'] != null
        ? DateTime.parse(json['expiry']).toLocal()
        : null;
    date = json['date'] != null ? DateTime.parse(json['date']).toLocal() : null;
    files = [];
    json['files'].forEach((element) {
      FileData file = FileData.fromJson(jsonDecode(element));
      files.add(file);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['sender'] = this.sender;
    data['key'] = this.key;
    data['files'] = [];
    this.files.forEach((element) {
      data['files'].add(jsonEncode(element.toJson()));
    });
    data['expiry'] = this.expiry.toUtc().toString();
    data['date'] = this.date.toUtc().toString();
    return data;
  }

  List<FileData> platformFileToFileData(List<PlatformFile> platformFiles) {
    var fileData = <FileData>[];
    if (platformFiles == null) {
      return fileData;
    }
    platformFiles.forEach((element) {
      fileData.add(
          FileData(name: element.name, size: element.size, path: element.path));
    });

    return fileData;
  }
}

class FileData {
  String name;
  int size;
  String url;
  String path;

  FileData({this.name, this.size, this.url, this.path});

  FileData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    size = json['size'];
    url = json['url'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['size'] = this.size;
    data['url'] = this.url;
    data['path'] = this.path;
    return data;
  }
}

class FileHistory {
  FileTransfer fileDetails;
  List<ShareStatus> sharedWith;
  HistoryType type;

  FileHistory(this.fileDetails, this.sharedWith, this.type);
  FileHistory.fromJson(Map<String, dynamic> json) {
    if (json['fileDetails'] != null) {
      fileDetails = FileTransfer.fromJson(json['fileDetails']);
    }
    sharedWith = [];

    if (json['sharedWith'] != null) {
      json['sharedWith'].forEach((element) {
        ShareStatus shareStatus = ShareStatus.fromJson(element);
        sharedWith.add(shareStatus);
      });
    }
    type = json['type'] == HistoryType.send.toString()
        ? HistoryType.send
        : HistoryType.received;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['fileDetails'] = this.fileDetails;
    data['sharedWith'] = this.sharedWith;
    data['type'] = this.type.toString();
    return data;
  }
}

class ShareStatus {
  String atsign;
  bool isNotificationSend;

  ShareStatus(this.atsign, this.isNotificationSend);

  ShareStatus.fromJson(Map<String, dynamic> json) {
    atsign = json['atsign'];
    isNotificationSend = json['isNotificationSend'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['atsign'] = this.atsign;
    data['isNotificationSend'] = this.isNotificationSend;
    return data;
  }
}
