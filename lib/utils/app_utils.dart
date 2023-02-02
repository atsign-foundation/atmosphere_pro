import 'dart:math';

class AppUtils{
  static String getFileSizeString({required double bytes, int decimals = 0}) {
    const suffixes = ["b", "Kb", "Mb", "Gb", "Tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}