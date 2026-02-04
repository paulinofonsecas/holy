import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

class DownloadProgressBar extends StatelessWidget {
  final DownloadProgress progress;
  final VoidCallback? onRetry;

  const DownloadProgressBar({
    super.key,
    required this.progress,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isError = progress.status == DownloadStatus.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.percent > 0 ? progress.percent : null,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress.percent * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DownloadFormatters.formatProgressText(
                progress.downloadedBytes,
                progress.totalBytes,
              ),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        if (isError) ...[
          const SizedBox(height: 16),
          Text(
            progress.message ?? 'Erro desconhecido',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ],
    );
  }
}
