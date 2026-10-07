import 'package:bible_handler/bible_handler.dart';
import 'package:test/test.dart';

const _fixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<bible translation="Portuguese NAA 2017 (Nova Almeida Atualizada)"
       status="NAA &copy; 2017 Sociedade B\u00edblica do Brasil."
       link="https://www.bible.com/bible/1840/GEN.1.NAA">
  <testament name="Old">
    <book number="1">
      <chapter number="1">
        <verse number="1">No princ\u00edpio, Deus criou os c\u00e9us e a terra.</verse>
        <verse number="2">A terra era sem forma e vazia.</verse>
        texto solto fora de verse (sujeira do corpus)
        <verse number="3">Ent\u00e3o Deus disse: Haja luz!</verse>
      </chapter>
      <chapter>
        <verse number="1">Cap\u00edtulo sem atributo number.</verse>
      </chapter>
    </book>
  </testament>
  <testament name="New">
    <!-- NT-only mant\u00e9m numera\u00e7\u00e3o global: Mateus = 40 -->
    <book number="40">
      <chapter number="1">
        <verse number="1">Livro da genealogia de Jesus Cristo.</verse>
        <verse number="x">n\u00famero n\u00e3o num\u00e9rico</verse>
      </chapter>
    </book>
    <!-- Ap\u00f3crifo: ordinal fora do c\u00e2non 1-66 -->
    <book number="67">
      <chapter number="1">
        <verse number="1">Verso de livro ap\u00f3crifo.</verse>
      </chapter>
    </book>
  </testament>
</bible>
''';

void main() {
  group('BebliaXmlParser', () {
    late Bible bible;

    setUp(() async {
      bible = await const BebliaXmlParser().parse(
        _fixture,
        versionId: 'NAA',
      );
    });

    test('extracts metadata from translation/status attributes', () {
      expect(bible.name, 'Portuguese NAA 2017 (Nova Almeida Atualizada)');
      expect(bible.copyright, contains('NAA'));
      expect(bible.abbreviation, 'NAA'); // vem do versionId do chamador
    });

    test('falls back to name/info attributes and parenthesized abbr', () async {
      final alt = await const BebliaXmlParser().parse('''
<bible name="Tradução Alternativa" info="No Info">
  <testament name="Old">
    <book number="1">
      <chapter number="1"><verse number="1">Texto.</verse></chapter>
    </book>
  </testament>
</bible>
''');
      expect(alt.name, 'Tradução Alternativa');
      expect(alt.copyright, 'No Info');
      expect(alt.abbreviation, 'XML'); // sem versionId e sem acrônimo
    });

    test('maps global book ordinals to canonical ids', () {
      final ids = bible.books.map((b) => b.id).toSet();
      expect(ids, containsAll(['GEN', 'MAT']));
    });

    test('nt-only files keep global numbering (book 40 = Mateus)', () {
      final matthew = bible.books.firstWhere((b) => b.id == 'MAT');
      expect(matthew.name, 'Mateus');
      expect(
        matthew.chapters.first.verses.first.text,
        'Livro da genealogia de Jesus Cristo.',
      );
    });

    test('ignores loose text between verses', () {
      final genesis = bible.books.firstWhere((b) => b.id == 'GEN');
      final chapter1 = genesis.chapters.firstWhere((c) => c.number == 1);
      final texts = chapter1.verses.map((v) => v.text).toList();
      expect(texts, hasLength(3));
      // Nenhum verso absorveu a sujeira "texto solto fora de verse".
      expect(texts.join(' '), isNot(contains('sujeira')));
      expect(texts.join(' '), isNot(contains('texto solto')));
      // O conteúdo dos versos declarados foi preservado.
      expect(texts.first, contains('princípio'));
      expect(texts.last, contains('Haja luz'));
    });

    test('handles chapters/verses without number attributes', () {
      final genesis = bible.books.firstWhere((b) => b.id == 'GEN');
      expect(genesis.chapters.length, 2);
      final implicitChapter = genesis.chapters[1];
      expect(implicitChapter.number, 2);
      expect(implicitChapter.verses.first.number, 1);
    });

    test('falls back to implicit numbering for non-numeric verse numbers', () {
      final matthew = bible.books.firstWhere((b) => b.id == 'MAT');
      final numbers = matthew.chapters.first.verses.map((v) => v.number);
      expect(numbers, contains(2)); // "x" vira verso implícito
    });

    test('preserves apocryphal books (ordinal > 66) with synthetic id', () {
      final apocryphal = bible.books.firstWhere((b) => b.id == 'B67');
      expect(apocryphal.name, 'Livro 67');
      expect(apocryphal.chapters.first.verses.first.text, contains('apócrifo'));
    });

    test('throws on missing translation/name', () {
      expect(
        () => const BebliaXmlParser().parse('<bible></bible>'),
        throwsException,
      );
    });

    test('throws on unexpected root element', () {
      expect(
        () => const BebliaXmlParser().parse('<notabible></notabible>'),
        throwsException,
      );
    });

    test('no <book> elements throws', () {
      expect(
        () => const BebliaXmlParser().parse('<bible name="x"></bible>'),
        throwsException,
      );
    });
  });

  group('URL/magic helpers', () {
    test('looksLikeBebliaXmlUrl', () {
      expect(
        looksLikeBebliaXmlUrl(
          'https://raw.githubusercontent.com/Beblia/Holy-Bible-XML-Format/master/PortugueseNTLHBible.xml',
        ),
        isTrue,
      );
      expect(
        looksLikeBebliaXmlUrl(
          'https://raw.githubusercontent.com/paulinofonsecas/biblias/main/inst/usx/traducao/KJA.zip',
        ),
        isFalse,
      );
    });

    test('isZipMagic', () {
      expect(isZipMagic([0x50, 0x4B, 0x03, 0x04]), isTrue);
      expect(isZipMagic([0x3C, 0x3F]), isFalse);
      expect(isZipMagic([]), isFalse);
    });
  });
}
