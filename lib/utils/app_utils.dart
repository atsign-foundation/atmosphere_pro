import 'dart:math';

class AppUtils {
  static String getFileSizeString({required double bytes, int decimals = 0}) {
    const suffixes = ["b", "Kb", "Mb", "Gb", "Tb"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static isFilesAvailableToDownload(String dateString) {
    DateTime date = DateTime.parse(dateString);
    var expiryDate = date.add(const Duration(days: 6));
    if (expiryDate.difference(DateTime.now()) > const Duration(seconds: 0)) {
      return true;
    }

    return false;
  }
}
