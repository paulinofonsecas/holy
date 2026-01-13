import 'package:bible_handler/src/models/web_database_status.dart';
import 'package:bible_handler/src/services/web_database_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WebDatabaseLoader initial status on non-web should be ready', () async {
    final loader = WebDatabaseLoader();

    // We expect it to complete immediately on non-web
    final futureStatus = loader.status.first;
    await loader.initialize();

    final status = await futureStatus;
    expect(status.type, WebDatabaseStatusType.ready);
  });
}
