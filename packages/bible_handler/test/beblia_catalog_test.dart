import 'package:bible_handler/bible_handler.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('BebliaCatalogEntry name parsing', () {
    BebliaCatalogEntry entryFor(String fileName) {
      final catalog = BebliaCatalog();
      return catalog.entryFromFileInfo({
        'name': fileName,
        'size': 1234,
      })!;
    }

    test('derives id from file stem', () {
      final e = entryFor('PortugueseNAABible.xml');
      expect(e.id, 'PortugueseNAABible');
      expect(e.downloadUrl, contains('PortugueseNAABible.xml'));
      expect(e.sizeBytes, 1234);
    });

    test('extracts year from file name', () {
      expect(entryFor('Afrikaans1983Bible.xml').year, 1983);
      expect(entryFor('PortugueseNAABible.xml').year, isNull);
      expect(entryFor('ChineseWenli1823Bible.xml').year, 1823);
    });

    test('maps known language prefixes', () {
      expect(entryFor('PortugueseNAABible.xml').language, 'Português');
      expect(entryFor('EnglishNKJBible.xml').language, 'Inglês');
      expect(entryFor('HebrewLeningradCodexBible.xml').language, 'Hebraico');
      expect(entryFor('ArabicBible.xml').language, 'Árabe');
    });

    test('builds readable title from camelCase', () {
      expect(entryFor('PortugueseNAABible.xml').title, 'Portuguese NAA');
      expect(entryFor('EnglishNIVBible.xml').title, 'English NIV');
      expect(entryFor('Afrikaans1983Bible.xml').title, 'Afrikaans 1983');
    });

    test('ignores non-xml files', () {
      final catalog = BebliaCatalog();
      expect(
        catalog.entryFromFileInfo({'name': 'README.md'}),
        isNull,
      );
    });
  });

  group('BebliaCatalog.fetch', () {
    test('returns empty list on network failure', () async {
      final catalog = BebliaCatalog(client: _FailingClient());
      final entries = await catalog.fetch();
      expect(entries, isEmpty);
    });
  });
}

class _FailingClient implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async =>
      throw Exception('offline');

  @override
  void close() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
