import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';

enum FileType { photo, file, audio, video, zips, other }

extension GenderTypeExtension on FileType {
  String get text {
    switch (this) {
      case FileType.photo:
        return 'Photos';
      case FileType.file:
        return 'Files';
      case FileType.audio:
        return 'Audio';
      case FileType.video:
        return 'Videos';
      case FileType.zips:
        return 'Zips';
      case FileType.other:
        return 'Other';
    }
  }

  String get image {
    switch (this) {
      case FileType.photo:
        return AppVectors.icCategoryImage;
      case FileType.file:
        return AppVectors.icCategoryFiles;
      case FileType.audio:
        return AppVectors.icCategoryVolume;
      case FileType.video:
        return AppVectors.icCategoryPlay;
      case FileType.zips:
        return AppVectors.icCategoryFolder;
      case FileType.other:
        return AppVectors.icCategoryOther;
    }
  }

  String get icon {
    switch (this) {
      case FileType.photo:
        return AppVectors.icPhotos;
      case FileType.file:
        return AppVectors.icFiles;
      case FileType.audio:
        return AppVectors.icAudio;
      case FileType.video:
        return AppVectors.icVideos;
      case FileType.zips:
        return AppVectors.icZips;
      case FileType.other:
        return AppVectors.icOther;
    }
  }

  List<String> get suffixName {
    switch (this) {
      case FileType.photo:
        return FileTypes.IMAGE_TYPES;
      case FileType.file:
        return FileTypes.PDF_TYPES +
            FileTypes.WORD_TYPES +
            FileTypes.EXEL_TYPES;
      case FileType.audio:
        return FileTypes.AUDIO_TYPES;
      case FileType.video:
        return FileTypes.VIDEO_TYPES;
      case FileType.zips:
        return FileTypes.ZIP_TYPES;
      default:
        return [];
    }
  }

  List<Color> get backgroundColor {
    switch (this) {
      case FileType.photo:
        return [
          const Color(0xFFF07C50),
          const Color(0xFFD86033),
        ];
      case FileType.file:
        return [
          const Color(0xFFE98C49),
          const Color(0xFFFE8228),
        ];
      case FileType.audio:
        return [
          const Color(0xFFFFB13D),
          const Color(0xFFFFAD33),
        ];
      case FileType.video:
        return [
          const Color(0xFFE47140),
          const Color(0xFFF67137),
        ];
      case FileType.zips:
        return [
          const Color(0xFFF09650),
          const Color(0xFFFD8E28),
        ];
      case FileType.other:
        return [
          const Color(0xFFF1B65C),
          const Color(0xFFFFB545),
        ];
    }
  }
}
