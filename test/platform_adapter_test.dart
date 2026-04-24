import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/core/platform/platform_adapter.dart';

void main() {
  test('PlatformAdapter.createForEnvironment returns a PlatformAdapter', () async {
    final pa = await PlatformAdapter.createForEnvironment();
    expect(pa, isA<PlatformAdapter>());
    final persistence = pa.getPersistence();
    expect(persistence, isNotNull);
    await persistence.open();
    await persistence.put('k', 'v');
    final v = await persistence.get('k');
    expect(v, equals('v'));
    await persistence.close();
  });
}
