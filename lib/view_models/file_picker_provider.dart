import 'dart:typed_data';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:file_picker/file_picker.dart';

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

  pickFiles() async {
    setStatus(PICK_FILES, Status.Loading);
    try {
      selectedFiles = [];
      totalSize = 0;
      // print("platform => $platform");
      result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.media,
          allowCompression: true,
          withData: true);
      print("comming till here");
      if (result?.files != null) {
        selectedFiles = [...result?.files];
        print("till here also1");
        calculateSize();
        print("till here also 2");
      }
      print("till here also3");
      setStatus(PICK_FILES, Status.Done);
    } catch (e) {
      print("error herer =. $e");
      setStatus(PICK_FILES, Status.Error);
    }
  }

  calculateSize() async {
    totalSize = 0;
    selectedFiles?.forEach((element) {
      totalSize += element.size;
    });
  }
}
