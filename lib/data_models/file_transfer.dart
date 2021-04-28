import 'dart:convert';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:file_picker/file_picker.dart';

class FileTransfer {
  String url;
  List<FileData> files;
  DateTime expiry;
  List<PlatformFile> platformFiles;
  FileTransfer({this.url, this.files, this.expiry, this.platformFiles}) {
    this.expiry = expiry ?? DateTime.now().add(Duration(days: 6));
    if (files == null) {
      this.files = platformFileToFileData(platformFiles);
    }
  }

  FileTransfer.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    expiry = json['expiry'] != null
        ? DateTime.parse(json['expiry']).toLocal()
        : null;
    files = [];
    json['files'].forEach((element) {
      FileData file = FileData.fromJson(jsonDecode(element));
      files.add(file);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['files'] = [];
    this.files.forEach((element) {
      data['files'].add(jsonEncode(element.toJson()));
    });

    data['expiry'] = this.expiry.toUtc().toString();
    return data;
  }

  List<FileData> platformFileToFileData(List<PlatformFile> platformFiles) {
    var fileData = <FileData>[];
    if (platformFiles == null) {
      return fileData;
    }
    platformFiles.forEach((element) {
      fileData.add(FileData(name: element.name, size: element.size));
    });

    return fileData;
  }
}

class FileData {
  String name;
  int size;
  String url;

  FileData({this.name, this.size, this.url});

  FileData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    size = json['size'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['size'] = this.size;
    data['url'] = this.url;
    return data;
  }
}

class FileHistory {
  FileTransfer fileDetails;
  List<String> atsign;
  HistoryType type;

  FileHistory(this.fileDetails, this.atsign, this.type);
  FileHistory.fromJson(Map<String, dynamic> json) {
    fileDetails = FileTransfer.fromJson(json['fileDetails']);
    atsign = [];
    json['atsign'].forEach((element) {
      atsign.add(element.toString());
    });
    type = json['type'] == HistoryType.send.toString()
        ? HistoryType.send
        : HistoryType.received;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['fileDetails'] = this.fileDetails;
    data['atsign'] = this.atsign;
    data['type'] = this.type.toString();
    return data;
  }
}
