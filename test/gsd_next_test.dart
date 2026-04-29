import 'package:test/test.dart';
import 'dart:io';
import '../tools/gsd_next.dart' as gsd;

void main() {
  test('parsePhasesFromRoadmap extracts phase numbers', () {
    final md = '### Phase 1\nSome text\n### Phase 4 — Web Migration';
    final phases = gsd.parsePhasesFromRoadmap(md);
    expect(phases, containsAll([1,4]));
  });

  test('normalizePhaseDirName returns constructed name when missing', () {
    final out = gsd.normalizePhaseDirName(4, ['.planning/phases/01-foundations']);
    expect(out, contains('04-'));
  });
}
