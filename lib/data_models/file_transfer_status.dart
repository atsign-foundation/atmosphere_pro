import 'dart:convert';

class FileTransferStatus {
  int id;
  String contactName;
  String fileName;
  TransferStatus status;
  FileTransferStatus({
    this.id,
    this.contactName,
    this.fileName,
    this.status,
  });

  FileTransferStatus copyWith({
    int id,
    String contactName,
    String fileName,
    TransferStatus status,
  }) {
    return FileTransferStatus(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactName': contactName,
      'fileName': fileName,
      'status': status,
    };
  }

  factory FileTransferStatus.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return FileTransferStatus(
      id: map['id'],
      contactName: map['contactName'],
      fileName: map['fileName'],
      status: (map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory FileTransferStatus.fromJson(String source) =>
      FileTransferStatus.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FileTransferStatus(id: $id, contactName: $contactName, fileName: $fileName, status: $status)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FileTransferStatus &&
        o.id == id &&
        o.contactName == contactName &&
        o.fileName == fileName &&
        o.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        contactName.hashCode ^
        fileName.hashCode ^
        status.hashCode;
  }
}

enum TransferStatus { DONE, PENDING, FAILED }

enum FileOperation { REUPLOAD_FILE, RESEND_NOTIFICATION }

enum FileRecipientSection { DELIVERED, DOWNLOADED, FAILED }
