// ignore: import_of_legacy_library_into_null_safe
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

Future<List<PlatformFile>?> desktopImagePicker() async {
  try {
    var selectedFiles = <PlatformFile>[];
    const XTypeGroup typeGroup = XTypeGroup();
    final List<XFile> files = await openFiles(acceptedTypeGroups: [typeGroup]);

    await Future.forEach(files, (XFile f) async {
      selectedFiles.add(
        PlatformFile(
          path: f.path,
          name: f.name,
          size: await f.length(),
        ),
      );
    });

    return selectedFiles;
  } catch (e) {
    print('Error in desktopImagePicker $e');
    return null;
  }
}
