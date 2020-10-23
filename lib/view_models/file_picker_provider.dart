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
      print('SELECTED LIST INITIAL====>$selectedFiles');
      List<PlatformFile> tempList = [];
      if (selectedFiles.isNotEmpty) {
        tempList = selectedFiles;
      }
      print('TEMP LIST INITIAL====>$tempList');
      selectedFiles = [];

      totalSize = 0;
      result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.media,
          allowCompression: true,
          withData: true);
      if (result?.files != null) {
        selectedFiles = [...tempList];
        tempList = [];
        print('SLECRED FILES FIRST====>$selectedFiles');
        result.files.forEach((element) {
          selectedFiles.add(element);
        });
        // selectedFiles = [...result?.files];
        print('SELECTED LIST FINAL !=====>$selectedFiles');
        calculateSize();
      }
      print('SELECTED LIST FINAL AFETR SIZE=====>$selectedFiles');
      setStatus(PICK_FILES, Status.Done);
    } catch (e) {
      setStatus(PICK_FILES, Status.Error);
    }
  }

  calculateSize() async {
    totalSize = 0;
    print('selected files lenhh====>${selectedFiles.length}');
    print('tota;l size efore====>$totalSize');
    selectedFiles?.forEach((element) {
      totalSize += element.size;
    });
    print('tota;l size after====>$totalSize');
  }
}
