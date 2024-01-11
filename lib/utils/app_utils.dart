import 'dart:math';
import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AppUtils {
  static String getFileSizeString({required double bytes, int decimals = 0}) {
    const suffixes = ["b", "Kb", "Mb", "Gb", "Tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static isFilesAvailableToDownload(String dateString) {
    DateTime date = DateTime.parse(dateString);
    var expiryDate = date.add(Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > Duration(seconds: 0)) {
      return true;
    }

    return false;
  }

  static Future<void> checkGroupImageSize({
    required Uint8List image,
    required Function(Uint8List) onSatisfy,
  }) async {
    if (image.lengthInBytes <= 153600) {
      onSatisfy.call(image);
    } else {
      Uint8List data = await FlutterImageCompress.compressWithList(
        image,
        quality: 50,
        minWidth: 400,
        minHeight: 200,
      );
      if (data.lengthInBytes <= 153600) {
        onSatisfy.call(data);
      } else {
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          TextStrings.groupImageFileSizeLimit,
          bgColor: ColorConstants.redAlert,
        );
      }
    }
  }
}
