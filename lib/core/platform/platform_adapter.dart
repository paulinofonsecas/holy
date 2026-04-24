import 'package:flutter/foundation.dart';

import 'web_persistence_adapter.dart' as web_adapter;

/// Minimal platform adapter contract used by the plan.
abstract class PersistenceAdapter {
  Future<void> open();
  Future<void> close();
  Future<void> put(String key, String value);
  Future<String?> get(String key);
}

abstract class PlatformAdapter {
  PersistenceAdapter getPersistence();

  static Future<PlatformAdapter> createForEnvironment() async {
    if (kIsWeb) {
      return _WebPlatformAdapter();
    }
    // default mobile adapter stub
    return _DefaultPlatformAdapter();
  }
}

class _WebPlatformAdapter implements PlatformAdapter {
  final web_adapter.WebPersistenceAdapter _p = web_adapter.WebPersistenceAdapter();

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
