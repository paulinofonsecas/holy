enum DownloadStatus { idle, downloading, extracting, completed, error }

class DownloadProgress {
  final double percent;
  final int downloadedBytes;
  final int totalBytes;
  final DownloadStatus status;
  final String? message;

  const DownloadProgress({
    required this.percent,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.status,
    this.message,
  });

  factory DownloadProgress.idle() => const DownloadProgress(
    percent: 0,
    downloadedBytes: 0,
    totalBytes: 0,
    status: DownloadStatus.idle,
  );

  factory DownloadProgress.downloading({
    required int downloaded,
    required int total,
  }) {
    final double pct = total > 0 ? (downloaded / total) : 0;
    return DownloadProgress(
      percent: pct.clamp(0.0, 1.0),
      downloadedBytes: downloaded,
      totalBytes: total,
      status: DownloadStatus.downloading,
    );
  }

  factory DownloadProgress.extracting() => const DownloadProgress(
    percent: 1.0,
    downloadedBytes: 0,
    totalBytes: 0,
    status: DownloadStatus.extracting,
  );

  factory DownloadProgress.completed() => const DownloadProgress(
    percent: 1.0,
    downloadedBytes: 0,
    totalBytes: 0,
    status: DownloadStatus.completed,
  );

  factory DownloadProgress.error(String message) => DownloadProgress(
    percent: 0,
    downloadedBytes: 0,
    totalBytes: 0,
    status: DownloadStatus.error,
    message: message,
  );

  @override
  String toString() =>
      'DownloadProgress(percent: ${(percent * 100).toStringAsFixed(1)}%, status: $status)';
}
