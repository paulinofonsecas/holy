import 'dart:async';

import 'package:bible_handler/bible_handler.dart';
import 'package:stacked/stacked.dart';

import '../data/progress_persistence.dart';
import '../utils/formatters.dart';

class DownloadProgressViewModel extends StreamViewModel<DownloadProgress> {
  final DownloadService _downloadService;
  final ProgressPersistence _persistence;
  final String url;
  final String savePath;

  DownloadProgressViewModel({
    required DownloadService downloadService,
    required ProgressPersistence persistence,
    required this.url,
    required this.savePath,
  })  : _downloadService = downloadService,
        _persistence = persistence;

  @override
  Stream<DownloadProgress> get stream =>
      _downloadService.download(url, savePath);

  @override
  void onData(DownloadProgress? data) {
    if (data != null) {
      if (data.status == DownloadStatus.downloading ||
          data.status == DownloadStatus.completed) {
        _persistence.saveProgress(
          bytes: data.downloadedBytes,
          total: data.totalBytes,
          status: data.status.name,
        );
      }
    }
  }

  String get progressText {
    final currentData = data ?? DownloadProgress.idle();
    return DownloadFormatters.formatProgressText(
      currentData.downloadedBytes,
      currentData.totalBytes,
    );
  }

  double get percent => data?.percent ?? 0.0;

  bool get isError => data?.status == DownloadStatus.error;
  String? get errorMessage => data?.message;

  bool get isCompleted => data?.status == DownloadStatus.completed;

  void retry() {
    notifySourceChanged();
  }
}
