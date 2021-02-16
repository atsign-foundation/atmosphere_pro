import 'dart:convert';

enum HistoryType { send, received }

class FilesModel {
  String name;
  String handle;
  String date;
  double totalSize;
  HistoryType historyType;

  List<FilesDetail> files;

  FilesModel(
      {this.name,
      this.handle,
      this.date,
      this.files,
      this.historyType,
      this.totalSize});

  FilesModel.fromJson(json) {
    name = json['name'].toString();
    handle = json['handle'].toString();
    date = json['date'].toString();
    totalSize = double.parse(json['total_size'].toString());

    if (json['files'] != null) {
      files = List<FilesDetail>();
      json['files'].forEach((v) {
        files.add(FilesDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['handle'] = this.handle;
    data['date'] = this.date;
    data['total_size'] = this.totalSize;
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
  String date;
  FilesDetail({
    this.fileName,
    this.filePath,
    this.size,
    this.type,
    this.date,
  });

  FilesDetail copyWith({
    String fileName,
    String filePath,
    double size,
    String type,
    String date,
  }) {
    return FilesDetail(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      size: size ?? this.size,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'size': size,
      'type': type,
      'date': date,
    };
  }

  factory FilesDetail.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return FilesDetail(
      fileName: map['fileName'],
      filePath: map['filePath'],
      size: map['size'],
      type: map['type'],
      date: map['date'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FilesDetail.fromJson(String source) =>
      FilesDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FilesDetail(fileName: $fileName, filePath: $filePath, size: $size, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FilesDetail &&
        o.fileName == fileName &&
        o.filePath == filePath &&
        o.size == size &&
        o.type == type &&
        o.date == date;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        filePath.hashCode ^
        size.hashCode ^
        type.hashCode ^
        date.hashCode;
  }
}
