import 'dart:math';

class DownloadFormatters {
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length - 1) / 3;
    var index = i.floor();
    if (index >= suffixes.length) index = suffixes.length - 1;

    double value = bytes / pow(1024, index);

    return "${value.toStringAsFixed(decimals)} ${suffixes[index]}";
  }

  static String formatProgressText(int downloaded, int total) {
    if (total <= 0) return formatBytes(downloaded);
    return "${formatBytes(downloaded)} / ${formatBytes(total)}";
  }
}
