import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sembast_web/sembast_web.dart' show databaseFactoryWeb;

import 'platform_adapter.dart';

/// A small WebPersistenceAdapter that uses sembast_web (IndexedDB).
class WebPersistenceAdapter implements PersistenceAdapter {
  Database? _db;
  final StoreRef<String, String> _store = stringMapStoreFactory.store('app_store');

  @override
  Future<void> open() async {
    // prefer web database factory when available
    final dbFactory = databaseFactoryWeb;
    _db = await dbFactory.openDatabase('eu_sou_web.db');
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<String?> get(String key) async {
    if (_db == null) await open();
    final rec = await _store.record(key).get(_db!);
    return rec;
  }

  @override
  Future<void> put(String key, String value) async {
    if (_db == null) await open();
    await _store.record(key).put(_db!, value);
  }
}
