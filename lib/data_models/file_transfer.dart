import 'dart:convert';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_object.dart';
import 'package:file_picker/file_picker.dart';

class FileTransfer {
  late String key, url;
  String? sender;
  List<FileData>? files;
  DateTime? date, expiry;
  List<PlatformFile>? platformFiles;
  bool? isUpdate;
  bool? isWidgetOpen;
  String? notes;
  String? fileEncryptionKey;
  List<String>? atSigns;
  FileTransfer(
      {required this.url,
      this.files,
      this.expiry,
      this.platformFiles,
      this.date,
      required this.key,
      this.isUpdate = false,
      this.isWidgetOpen = false,
      this.notes,
      required this.fileEncryptionKey,
      this.atSigns}) {
    expiry = expiry ?? DateTime.now().add(const Duration(days: 6));
    date = date ?? DateTime.now();

    files ??= platformFileToFileData(platformFiles);
  }

  FileTransfer.fromJson(Map<String, dynamic> json) {
    isUpdate = json['isUpdate'];
    isWidgetOpen = json['isWidgetOpen'];
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
      files!.add(file);
    });
    fileEncryptionKey = json['fileEncryptionKey'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isUpdate'] = isUpdate;
    data['isWidgetOpen'] = isWidgetOpen;
    data['url'] = url;
    data['sender'] = sender;
    data['key'] = key;
    data['files'] = [];
    data['notes'] = notes;
    for (var element in files!) {
      data['files'].add(jsonEncode(element.toJson()));
    }
    data['expiry'] = expiry!.toUtc().toString();
    data['date'] = date!.toUtc().toString();
    data['fileEncryptionKey'] = fileEncryptionKey;
    return data;
  }

  List<FileData> platformFileToFileData(List<PlatformFile>? platformFiles) {
    var fileData = <FileData>[];
    if (platformFiles == null) {
      return fileData;
    }
    for (var element in platformFiles) {
      fileData.add(
          FileData(name: element.name, size: element.size, path: element.path));
    }

    return fileData;
  }
}

class FileData {
  String? name;
  int? size;
  String? url;
  String? path;
  bool? isUploaded;
  bool? isUploading;
  bool? isDownloading;

  FileData({
    this.name,
    this.size,
    this.url,
    this.path,
    this.isUploaded = false,
    isUploading = false,
    isDownloading = false,
  });

  FileData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    size = json['size'];
    url = json['url'];
    path = json['path'];
    isUploaded = json['isUploaded'] ?? false;
    isUploading = json['isUploading'] ?? false;
    isDownloading = json['isDownloading'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['size'] = size;
    data['url'] = url;
    data['path'] = path;
    data['isUploaded'] = isUploaded;
    data['isUploading'] = isUploading;
    data['isDownloading'] = isDownloading;
    return data;
  }
}

class FileHistory {
  FileTransfer? fileDetails;
  List<ShareStatus>? sharedWith;
  HistoryType? type;
  FileTransferObject? fileTransferObject;
  String? groupName;
  // used to determine whether any opearation is running over this file or not
  // only for front end used , this value is not saved.
  bool? isOperating;
  String? notes;

  FileHistory(
      this.fileDetails, this.sharedWith, this.type, this.fileTransferObject,
      {this.isOperating, this.groupName, this.notes});
  FileHistory.fromJson(Map<String, dynamic> data) {
    if (data['fileDetails'] != null) {
      fileDetails = FileTransfer.fromJson(data['fileDetails']);
    }
    sharedWith = [];

    if (data['sharedWith'] != null) {
      data['sharedWith'].forEach((element) {
        ShareStatus shareStatus = ShareStatus.fromJson(element);
        sharedWith!.add(shareStatus);
      });
    }
    type = data['type'] == HistoryType.send.toString()
        ? HistoryType.send
        : HistoryType.received;

    if (data['fileTransferObject'] != null) {
      fileTransferObject =
          FileTransferObject.fromJson(jsonDecode(data['fileTransferObject']));
    }
    groupName = data['groupName'];
    notes = data['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileDetails'] = fileDetails;
    data['sharedWith'] = sharedWith;
    data['type'] = type.toString();
    data['fileTransferObject'] = jsonEncode(fileTransferObject!.toJson());
    data['groupName'] = groupName;
    data['notes'] = notes;
    return data;
  }
}

class ShareStatus {
  String? atsign;
  bool? isNotificationSend;
  bool? isFileDownloaded;

  // for front end reference only
  bool? isSendingNotification;

  ShareStatus(this.atsign, this.isNotificationSend,
      {this.isSendingNotification = false, this.isFileDownloaded = false});

  ShareStatus.fromJson(Map<String, dynamic> json) {
    atsign = json['atsign'];
    isNotificationSend = json['isNotificationSend'] ?? false;
    isFileDownloaded = json['isFileDownloaded'] ?? false;
    isSendingNotification = json['isSendingNotification'] ?? false;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['atsign'] = atsign;
    data['isNotificationSend'] = isNotificationSend;
    data['isFileDownloaded'] = isFileDownloaded;
    return data;
  }
}

class DownloadAcknowledgement {
  bool? isDownloaded;
  String? transferId;

  DownloadAcknowledgement(this.isDownloaded, this.transferId);

  DownloadAcknowledgement.fromJson(Map<String, dynamic> json) {
    isDownloaded = json['isDownloaded'];
    transferId = json['transferId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isDownloaded'] = isDownloaded;
    data['transferId'] = transferId;
    return data;
  }
}

class FileTransferProgress {
  FileState fileState;
  double? percent;
  String? fileName;
  double? fileSize;
  FileTransferProgress(
      this.fileState, this.percent, this.fileName, this.fileSize);
}

enum FileState { encrypt, decrypt, upload, download, processing }
