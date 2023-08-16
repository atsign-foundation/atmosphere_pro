class FileTypes {
  static List<String> IMAGE_TYPES = [
    'JPG',
    'JPEG',
    'PNG',
    'png',
    'jpg',
    'jpeg'
  ];
  static List<String> VIDEO_TYPES = ['mp4', 'MP4', 'mov', 'MOV'];
  static List<String> AUDIO_TYPES = [
    'mp3',
    'wmv',
    'ogg',
    'aac',
    'flac',
    'MP3',
    'WMV',
    'OGG',
    'AAC',
    'FLAC'
  ];
  static List<String> APK_TYPES = ['apk', 'APK'];
  static List<String> PDF_TYPES = ['pdf', 'PDF'];
  static List<String> WORD_TYPES = ['doc', 'docx', 'DOC', 'DOCX'];
  static List<String> EXEL_TYPES = ['xls', 'xlsx', 'XLS', 'XLSX'];
  static List<String> TEXT_TYPES = ['txt', 'TXT'];
  static List<String> DOCUMENT_TYPES = [
    'txt',
    'TXT',
    'xls',
    'xlsx',
    'XLS',
    'XLSX',
    'doc',
    'docx',
    'DOC',
    'DOCX',
    'pdf',
    'PDF'
  ];
  static List<String> ZIP_TYPES = [
    'zip',
    'zipx',
    '7z',
    'rar',
    'tar.gz',
    'z',
    'jar'
  ];

  static List<String> ALL_TYPES = IMAGE_TYPES +
      VIDEO_TYPES +
      AUDIO_TYPES +
      PDF_TYPES +
      WORD_TYPES +
      EXEL_TYPES +
      TEXT_TYPES +
      ZIP_TYPES;
}
