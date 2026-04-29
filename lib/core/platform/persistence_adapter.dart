/// Abstract contract for platform-specific persistence.
abstract class PersistenceAdapter {
  Future<void> open();
  Future<void> close();
  Future<void> put(String key, String value);
  Future<String?> get(String key);
}
