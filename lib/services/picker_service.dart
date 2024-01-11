import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PickerService {
  PickerService._();

  static final picker = ImagePicker();

  static Future<void> pickImage({
    required Function(Uint8List result) onPickedImage,
  }) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
     final result = await File(image.path).readAsBytes();
     onPickedImage.call(result);
    }
  }
}
