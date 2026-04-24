import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/core/platform/platform_adapter.dart';

void main() {
  test('StorageService wiring via PlatformAdapter', () async {
    final pa = await PlatformAdapter.createForEnvironment();
    final p = pa.getPersistence();
    // Basic contract checks
    await p.open();
    await p.put('wire-test', 'ok');
    final v = await p.get('wire-test');
    expect(v, equals('ok'));
    await p.close();
  });
}
