import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/core/platform/web_persistence_adapter.dart';

void main() {
  test('WebPersistenceAdapter basic put/get works', () async {
    final adapter = WebPersistenceAdapter();
    await adapter.open();
    await adapter.put('test-key', 'hello');
    final v = await adapter.get('test-key');
    expect(v, equals('hello'));
    await adapter.close();
  });
}
