import 'dart:convert';

import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';

enum HistoryType { send, received }

class FilesModel {
  List<String> name;
  String handle;
  String date;
  int id;
  double totalSize;
  HistoryType historyType;

  List<FilesDetail> files;

  FilesModel(
      {this.name,
      this.handle,
      this.date,
      this.files,
      this.id,
      this.historyType,
      this.totalSize});

  FilesModel.fromJson(json) {
    name = jsonDecode(json['name']);
    handle = json['handle'].toString();
    date = json['date'].toString();
    id = json['id'];
    totalSize = double.parse(json['total_size'].toString());

    if (json['files'] != null) {
      files = <FilesDetail>[];
      json['files'].forEach((v) {
        if (v.runtimeType == String) {
          files.add(FilesDetail.fromJson(v));
        } else {
          files.add(FilesDetail.fromMap(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = jsonEncode(this.name);
    data['handle'] = this.handle;
    data['date'] = this.date;
    data['total_size'] = this.totalSize;
    data['id'] = this.id;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FilesDetail {
  String fileName;
  String filePath;
  double size;
  String type;
  String contactName;
  int id;
  String date;
  FileTransferStatus status;
  FilesDetail({
    this.fileName,
    this.filePath,
    this.size,
    this.type,
    this.status,
    this.contactName,
    this.id,
    this.date,
  });

  FilesDetail copyWith({
    String fileName,
    String filePath,
    double size,
    String type,
    String date,
    FileTransferStatus status,
    String contactName,
    int id,
  }) {
    return FilesDetail(
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        size: size ?? this.size,
        type: type ?? this.type,
        date: date ?? this.date,
        status: status ?? this.status,
        id: id ?? this.id,
        contactName: contactName ?? this.contactName);
  }

  Map<String, dynamic> toMap() {
    return {
      'file_name': fileName,
      'file_path': filePath,
      'size': size,
      'type': type,
      'date': date,
      'id': id,
      'status': status,
      'contactName': contactName
    };
  }

  factory FilesDetail.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return FilesDetail(
        fileName: map['file_name'],
        filePath: map['file_path'],
        size: map['size'],
        type: map['type'],
        date: map['date'],
        id: map['id'],
        status: map['status'],
        contactName: map['contactName']);
  }

  String toJson() => json.encode(toMap());

  factory FilesDetail.fromJson(String source) =>
      FilesDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FilesDetail(fileName: $fileName, filePath: $filePath, size: $size, type: $type, date: $date, id:$id, contactName:$contactName, status:$status)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FilesDetail &&
        o.fileName == fileName &&
        o.filePath == filePath &&
        o.size == size &&
        o.type == type &&
        o.date == date &&
        o.status == status &&
        o.contactName == contactName &&
        o.id == id;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        filePath.hashCode ^
        size.hashCode ^
        type.hashCode ^
        date.hashCode ^
        id.hashCode ^
        status.hashCode ^
        contactName.hashCode;
  }
}
