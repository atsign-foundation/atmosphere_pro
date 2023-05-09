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

  List<Color> get backgroundColor {
    switch (this) {
      case FileType.photo:
        return [
          Color(0xFFF07C50),
          Color(0xFFD86033),
        ];
      case FileType.file:
        return [
          Color(0xFFE98C49),
          Color(0xFFFE8228),
        ];
      case FileType.audio:
        return [
          Color(0xFFFFB13D),
          Color(0xFFFFAD33),
        ];
      case FileType.video:
        return [
          Color(0xFFE47140),
          Color(0xFFF67137),
        ];
      case FileType.zips:
        return [
          Color(0xFFF09650),
          Color(0xFFFD8E28),
        ];
      case FileType.other:
        return [
          Color(0xFFF1B65C),
          Color(0xFFFFB545),
        ];
    }
  }
}
