import 'dart:typed_data';

import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FilePickerProvider extends BaseModel {
  FilePickerProvider._();
  static FilePickerProvider _instance = FilePickerProvider._();
  factory FilePickerProvider() => _instance;
  String PICK_FILES = 'pick_files';
  String VIDEO_THUMBNAIL = 'video_thumbnail';
  FilePickerResult result;
  PlatformFile file;
  List<PlatformFile> selectedFiles = [];
  Uint8List videoThumbnail;
  double totalSize = 0;

  Future videoThumbnailBuilder(String path) async {
    setStatus(VIDEO_THUMBNAIL, Status.Loading);
    try {
      videoThumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );
      setStatus(VIDEO_THUMBNAIL, Status.Done);
      return videoThumbnail;
    } catch (e) {
      setStatus(VIDEO_THUMBNAIL, Status.Error);
    }
  }

  pickFiles() async {
    setStatus(PICK_FILES, Status.Loading);
    try {
      selectedFiles = [];
      totalSize = 0;
      result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.media,
          allowCompression: true,
          withData: true);
      if (result?.files != null) {
        selectedFiles = [...result?.files];
        selectedFiles.forEach((element) {
          totalSize += element.size;
        });
      }

      setStatus(PICK_FILES, Status.Done);
    } catch (e) {
      setStatus(PICK_FILES, Status.Error);
    }
  }
}
