import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart' show databaseFactoryWeb;

import 'persistence_adapter.dart';

/// A WebPersistenceAdapter that uses sembast_web (IndexedDB).
/// Falls back to in-memory storage if IndexedDB is unavailable.
class WebPersistenceAdapter implements PersistenceAdapter {
  Database? _db;
  final StoreRef<String, Map<String, Object?>> _store =
      stringMapStoreFactory.store('app_store');
  bool _useFallback = false;
  final Map<String, String> _fallbackStore = {};

  @override
  Future<void> open() async {
    try {
      final dbFactory = databaseFactoryWeb;
      _db = await dbFactory.openDatabase('eu_sou_web.db');
    } catch (_) {
      _useFallback = true;
    }
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<String?> get(String key) async {
    if (_db == null) await open();
    if (_useFallback) return _fallbackStore[key];
    final rec = await _store.record(key).get(_db!);
    return rec?['value'] as String?;
  }

  @override
  Future<void> put(String key, String value) async {
    if (_db == null) await open();
    if (_useFallback) {
      _fallbackStore[key] = value;
      return;
    }
    await _store.record(key).put(_db!, {'value': value});
  }
}
