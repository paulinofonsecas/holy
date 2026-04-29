import 'package:flutter/foundation.dart';

import 'persistence_adapter.dart';
import 'web_persistence_adapter.dart' as web_adapter;

export 'persistence_adapter.dart';

/// Platform adapter that selects the correct persistence implementation per environment.
abstract class PlatformAdapter {
  PersistenceAdapter getPersistence();

  static Future<PlatformAdapter> createForEnvironment() async {
    if (kIsWeb) {
      return _WebPlatformAdapter();
    }
    return _DefaultPlatformAdapter();
  }
}

class _WebPlatformAdapter implements PlatformAdapter {
  final web_adapter.WebPersistenceAdapter _p =
      web_adapter.WebPersistenceAdapter();

  @override
  PersistenceAdapter getPersistence() => _p;
}

class _DefaultPlatformAdapter implements PlatformAdapter {
  final _InMemoryPersistence _p = _InMemoryPersistence();

  @override
  PersistenceAdapter getPersistence() => _p;
}

class _InMemoryPersistence implements PersistenceAdapter {
  final Map<String, String> _store = {};

  @override
  Future<void> close() async {}

  @override
  Future<String?> get(String key) async => _store[key];

  @override
  Future<void> open() async {}

  @override
  Future<void> put(String key, String value) async {
    _store[key] = value;
  }
}
