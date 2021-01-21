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
    // print("till here123");
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

  FilesDetail({this.fileName, this.size, this.type, this.filePath});

  FilesDetail.fromJson(json) {
    fileName = json['file_name'].toString();
    size = double.parse(json['size'].toString());
    type = json['type'].toString();
    filePath = json['file_path'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['file_name'] = this.fileName;
    data['size'] = this.size;
    data['type'] = this.type;
    data['file_path'] = this.filePath;
    return data;
  }
}
