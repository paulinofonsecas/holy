import 'package:eu_sou/core/platform/platform_adapter.dart';

/// Simple storage service that delegates to PlatformAdapter's PersistenceAdapter.
///
/// This is intentionally minimal: it provides async put/get/close and
/// ensures the underlying adapter is opened before use. It's suitable for
/// verifying wiring during the Web migration (tests assert this behavior).
class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal() {
    _initFuture = _init();
  }

  late final Future<void> _initFuture;
  late final PersistenceAdapter _adapter;

  Future<void> _init() async {
    final pa = await PlatformAdapter.createForEnvironment();
    _adapter = pa.getPersistence();
    await _adapter.open();
  }

  /// Await readiness when needed by callers.
  Future<void> ready() => _initFuture;

  Future<void> put(String key, String value) async {
    await _initFuture;
    await _adapter.put(key, value);
  }

  Future<String?> get(String key) async {
    await _initFuture;
    return _adapter.get(key);
  }

  Future<void> close() async {
    await _initFuture;
    await _adapter.close();
  }
}
