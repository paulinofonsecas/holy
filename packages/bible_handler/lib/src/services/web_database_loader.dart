import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../interfaces.dart';
import '../models/web_database_status.dart';

class WebDatabaseLoader implements IDatabaseLoader {
  final String dbName;
  final String? assetPath;
  final String? downloadUrl;

  final _progressController = StreamController<double>.broadcast();
  final _statusController = StreamController<WebDatabaseStatus>.broadcast();

  WebDatabaseLoader({
    this.dbName = 'holy_bible.db',
    this.assetPath,
    this.downloadUrl,
  });

  @override
  Stream<double> get progress => _progressController.stream;

  @override
  Stream<WebDatabaseStatus> get status => _statusController.stream;

  @override
  Future<void> initialize() async {
    if (!kIsWeb) {
      _statusController.add(WebDatabaseStatus.ready());
      _progressController.add(1.0);
      return;
    }

    try {
      final factory = databaseFactoryFfiWeb;
      final exists = await factory.databaseExists(dbName);

      if (exists) {
        _statusController.add(WebDatabaseStatus.ready());
        _progressController.add(1.0);
        return;
      }

      _statusController.add(WebDatabaseStatus.initializing());

      Uint8List bytes;

      if (assetPath != null) {
        _statusController.add(
          const WebDatabaseStatus(
            type: WebDatabaseStatusType.downloading,
            progress: 0.1,
          ),
        );
        final data = await rootBundle.load(assetPath!);
        bytes = data.buffer.asUint8List();
      } else if (downloadUrl != null) {
        _statusController.add(WebDatabaseStatus.downloading(0.0));
        final response = await http.get(Uri.parse(downloadUrl!));
        if (response.statusCode != 200) {
          throw Exception(
            'Failed to download database: ${response.statusCode}',
          );
        }
        bytes = response.bodyBytes;
      } else {
        // No source provided, just initialize empty
        _statusController.add(WebDatabaseStatus.ready());
        return;
      }

      if (assetPath?.endsWith('.gz') == true ||
          downloadUrl?.endsWith('.gz') == true) {
        _statusController.add(WebDatabaseStatus.extracting());
        bytes = Uint8List.fromList(GZipDecoder().decodeBytes(bytes));
      }

      _statusController.add(
        const WebDatabaseStatus(
          type: WebDatabaseStatusType.downloading,
          progress: 0.9,
        ),
      );

      await factory.setDatabasesPath('/databases');
      await factory.writeDatabaseBytes(dbName, bytes);

      _statusController.add(WebDatabaseStatus.ready());
      _progressController.add(1.0);
    } catch (e) {
      _statusController.add(WebDatabaseStatus.error(e.toString()));
      rethrow;
    }
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
  }
}
