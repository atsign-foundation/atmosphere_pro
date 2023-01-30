enum FileType { all, photo, video, audio, apk, document, unknown }

extension GenderTypeExtension on FileType {
  String get text {
    switch (this) {
      case FileType.all:
        return 'All';
      case FileType.photo:
        return 'Photo';
      case FileType.video:
        return 'Video';
      case FileType.audio:
        return 'Audio';
      case FileType.apk:
        return 'APK';
      case FileType.document:
        return 'Document';
      case FileType.unknown:
        return 'Unknown';
      default:
        return '';
    }
  }
}
