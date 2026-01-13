import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/download_progress.dart';

class DownloadService {
  final http.Client _client;

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  Stream<DownloadProgress> download(String url, String savePath) async* {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        yield DownloadProgress.error(
          'Failed to download: ${response.statusCode}',
        );
        return;
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;
      final file = File(savePath);
      final sink = file.openWrite();

      DateTime lastNotifyTime = DateTime.now();

      yield DownloadProgress.downloading(downloaded: 0, total: totalBytes);

      await for (final chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        final now = DateTime.now();
        if (now.difference(lastNotifyTime).inMilliseconds >= 500 ||
            downloadedBytes == totalBytes) {
          yield DownloadProgress.downloading(
            downloaded: downloadedBytes,
            total: totalBytes,
          );
          lastNotifyTime = now;
        }
      }

      await sink.close();
      yield DownloadProgress.completed();
    } catch (e) {
      yield DownloadProgress.error(e.toString());
    }
  }

  void dispose() {
    _client.close();
  }
}
