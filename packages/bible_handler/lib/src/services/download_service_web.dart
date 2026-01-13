import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/download_progress.dart';

class DownloadService {
  DownloadService({http.Client? client});

  Stream<DownloadProgress> download(String url, String savePath) async* {
    yield DownloadProgress.error(
      'Download to file system not supported on Web',
    );
  }
}
