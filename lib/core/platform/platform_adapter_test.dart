import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/core/platform/platform_adapter.dart';
import 'package:eu_sou/core/platform/web_persistence_adapter.dart';
import 'package:eu_sou/core/services/storage_service.dart';

void main() {
  group('PlatformAdapter', () {
    test('createForEnvironment returns a PlatformAdapter', () async {
      final pa = await PlatformAdapter.createForEnvironment();
      expect(pa, isA<PlatformAdapter>());
    });

    test('getPersistence returns a PersistenceAdapter', () async {
      final pa = await PlatformAdapter.createForEnvironment();
      final p = pa.getPersistence();
      expect(p, isA<PersistenceAdapter>());
    });

    test('put and get round-trip', () async {
      final pa = await PlatformAdapter.createForEnvironment();
      final p = pa.getPersistence();
      await p.open();
      await p.put('wire-test', 'ok');
      final v = await p.get('wire-test');
      expect(v, equals('ok'));
      await p.close();
    });
  });

  group('WebPersistence', () {
    test('WebPersistenceAdapter implements PersistenceAdapter', () async {
      final adapter = WebPersistenceAdapter();
      expect(adapter, isA<PersistenceAdapter>());
      await adapter.open();
      await adapter.put('web-test', 'value');
      final v = await adapter.get('web-test');
      expect(v, equals('value'));
      await adapter.close();
    });

    test('WebPersistenceAdapter returns null for missing key', () async {
      final adapter = WebPersistenceAdapter();
      await adapter.open();
      final v = await adapter.get('nonexistent-key');
      expect(v, isNull);
      await adapter.close();
    });
  });

  group('StorageService wiring', () {
    test('StorageService uses PlatformAdapter.getPersistence()', () async {
      await StorageService().ready();
      final pa = await PlatformAdapter.createForEnvironment();
      final adapter = pa.getPersistence();
      await adapter.open();
      const key = 'wiring-test';
      await StorageService().put(key, 'wired');
      final value = await StorageService().get(key);
      expect(value, equals('wired'));
      await adapter.close();
    });
  });
}
