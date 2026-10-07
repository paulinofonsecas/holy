import 'package:xml/xml.dart';

import '../models.dart';
import '../sorting/book_order.dart';
import '../sorting/book_sorter.dart';
import '../sorting/canonical_book_sorter.dart';

/// Parser para o formato "Simple XML" usado pelo repositório
/// [Beblia/Holy-Bible-XML-Format](https://github.com/Beblia/Holy-Bible-XML-Format)
/// (1000+ versões, 200+ idiomas).
///
/// Schema:
/// ```xml
/// <bible translation="..." status="..." link="...">
///   <testament name="Old">
///     <book number="1">
///       <chapter number="1">
///         <verse number="1">texto</verse>
/// ```
///
/// O corpus é heterogêneo (commits mostram "Normalize attribute capitalization",
/// "Remove text between verses", "Fix misspelled attributes"), então o parser é
/// leniente por design:
/// - nome da tradução vem de `translation` OU `name`;
/// - copyright vem de `status` OU `info`;
/// - atributos desconhecidos, `link="No Data"` e texto fora de `<verse>` são ignorados;
/// - livros com ordinal > 66 (apócrifos em Bíblias católicas) são preservados
///   com id sintático `B<n>`;
/// - versos com número não numérico são pulados.
///
/// Este arquivo NÃO depende de `dart:io` (o `package:xml` é puro Dart), então a
/// mesma implementação funciona em IO e Web — sem imports condicionais, ao
/// contrário do [UsxParser].
class BebliaXmlParser {
  const BebliaXmlParser();

  Future<Bible> parse(
    String xmlContent, {
    String? versionId,
    BookSorter sorter = const CanonicalBookSorter(),
  }) async {
    final document = XmlDocument.parse(xmlContent);
    final root = document.rootElement;
    if (root.name.local != 'bible') {
      throw Exception(
        'Expected root element <bible> in Beblia XML, '
        'found <${root.name.local}>',
      );
    }

    // --- Metadados (leniente) -------------------------------------------
    final translationName = _attr(root, 'translation') ?? _attr(root, 'name');
    if (translationName == null || translationName.isEmpty) {
      throw Exception('Beblia XML: missing translation/name attribute');
    }
    final copyright = _attr(root, 'status') ?? _attr(root, 'info');

    final abbreviation = _resolveAbbreviation(
      versionId: versionId,
      translationName: translationName,
    );

    // --- Livros -----------------------------------------------------------
    final books = <Book>[];
    for (final testament in root.findElements('testament')) {
      for (final bookElement in testament.findElements('book')) {
        final book = _parseBook(bookElement);
        if (book != null) books.add(book);
      }
    }

    // Fallback: alguns arquivos podem omitir <testament>.
    if (books.isEmpty) {
      for (final bookElement in root.findElements('book')) {
        final book = _parseBook(bookElement);
        if (book != null) books.add(book);
      }
    }

    if (books.isEmpty) {
      throw Exception('Beblia XML: no <book> elements found');
    }

    return Bible(
      name: translationName,
      abbreviation: abbreviation,
      description: translationName,
      languageName: null,
      languageIso: null,
      copyright: copyright,
      books: sorter.sort(books),
    );
  }

  /// Converte um elemento `<book>` em [Book].
  ///
  /// O corpus usa numeração global (1–66; até arquivos NT-only mantêm o
  /// ordinal global, ex.: Mateus = 40). Ordinais > 66 (apócrifos) recebem
  /// id sintático `B<n>`.
  Book? _parseBook(XmlElement bookElement) {
    final ordinal = int.tryParse(_attr(bookElement, 'number') ?? '');
    if (ordinal == null) return null;

    final id = _bookIdFor(ordinal);
    final ptName = _ptBookName(ordinal);
    final enName = _enBookName(ordinal);
    final displayName = ptName ?? enName ?? 'Livro $ordinal';

    final chapters = <Chapter>[];
    final seenChapterNumbers = <int>{};
    var lastChapterNumber = 0;

    for (final chapterElement in bookElement.findElements('chapter')) {
      final explicitNumber = int.tryParse(
        _attr(chapterElement, 'number') ?? '',
      );
      // Capítulo sem/ com atributo number não numérico: numeração implícita
      // que continua a sequência do último número conhecido.
      final chapterNumber = explicitNumber ?? lastChapterNumber + 1;
      if (explicitNumber != null) lastChapterNumber = explicitNumber;

      if (!seenChapterNumbers.add(chapterNumber)) continue;

      final verses = <Verse>[];
      final seenVerseNumbers = <int>{};
      var lastVerseNumber = 0;

      for (final verseElement in chapterElement.findElements('verse')) {
        final explicitVerse = int.tryParse(
          _attr(verseElement, 'number') ?? '',
        );
        final number = explicitVerse ?? lastVerseNumber + 1;
        if (explicitVerse != null) lastVerseNumber = explicitVerse;
        if (!seenVerseNumbers.add(number)) continue;

        final text = verseElement.innerText.trim();
        if (text.isEmpty) continue;
        verses.add(Verse(number: number, text: text));
      }

      if (verses.isNotEmpty) {
        chapters.add(Chapter(number: chapterNumber, verses: verses));
      }
    }

    if (chapters.isEmpty) return null;

    return Book(
      id: id,
      name: displayName,
      longName: displayName,
      abbreviation: id,
      chapters: chapters,
    );
  }

  /// ID canônico para o [ordinal] global do livro.
  String _bookIdFor(int ordinal) {
    if (ordinal >= 1 && ordinal <= canonicalBookOrder.length) {
      return canonicalBookOrder[ordinal - 1];
    }
    // Apócrifos / deuterocanônicos: id sintático estável.
    return 'B$ordinal';
  }

  /// Resolve a sigla da versão: o XML não traz sigla, então usa o [versionId]
  /// informado pelo chamador (o app já conhece o id); como fallback, tenta
  /// extrair um acrônimo do nome da tradução.
  String _resolveAbbreviation({
    required String? versionId,
    required String translationName,
  }) {
    final candidate = versionId?.trim();
    if (candidate != null && candidate.isNotEmpty) return candidate;

    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(translationName);
    if (parenMatch != null) {
      final inner = parenMatch.group(1)!.trim();
      if (inner.isNotEmpty) return inner;
    }
    return 'XML';
  }

  String? _attr(XmlElement element, String name) {
    // Leniente quanto à capitalização de atributos no corpus.
    for (final attribute in element.attributes) {
      if (attribute.name.local.toLowerCase() == name.toLowerCase()) {
        return attribute.value;
      }
    }
    return null;
  }
}

/// Detecta se uma URL aponta para um arquivo XML simples (Beblia) em vez de
/// um zip USX. Usado pelos loaders para escolher o fluxo de download/parse.
bool looksLikeBebliaXmlUrl(String url) {
  final path = url.split('?').first.toLowerCase();
  return path.endsWith('.xml');
}

/// Detecta o magic bytes `PK` de arquivos zip.
bool isZipMagic(List<int> bytes) =>
    bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;

// ---------------------------------------------------------------------------
// Tabelas de nomes de livros (o formato não inclui nomes)
// ---------------------------------------------------------------------------

/// Nomes em português, indexados por ordinal global (1–66).
const Map<int, String> _ptBookNames = {
  1: 'Gênesis',
  2: 'Êxodo',
  3: 'Levítico',
  4: 'Números',
  5: 'Deuteronômio',
  6: 'Josué',
  7: 'Juízes',
  8: 'Rute',
  9: '1 Samuel',
  10: '2 Samuel',
  11: '1 Reis',
  12: '2 Reis',
  13: '1 Crônicas',
  14: '2 Crônicas',
  15: 'Esdras',
  16: 'Neemias',
  17: 'Ester',
  18: 'Jó',
  19: 'Salmos',
  20: 'Provérbios',
  21: 'Eclesiastes',
  22: 'Cantares',
  23: 'Isaías',
  24: 'Jeremias',
  25: 'Lamentações',
  26: 'Ezequiel',
  27: 'Daniel',
  28: 'Oseias',
  29: 'Joel',
  30: 'Amós',
  31: 'Obadias',
  32: 'Jonas',
  33: 'Miqueias',
  34: 'Naum',
  35: 'Habacuque',
  36: 'Sofonias',
  37: 'Ageu',
  38: 'Zacarias',
  39: 'Malaquias',
  40: 'Mateus',
  41: 'Marcos',
  42: 'Lucas',
  43: 'João',
  44: 'Atos',
  45: 'Romanos',
  46: '1 Coríntios',
  47: '2 Coríntios',
  48: 'Gálatas',
  49: 'Efésios',
  50: 'Filipenses',
  51: 'Colossenses',
  52: '1 Tessalonicenses',
  53: '2 Tessalonicenses',
  54: '1 Timóteo',
  55: '2 Timóteo',
  56: 'Tito',
  57: 'Filemom',
  58: 'Hebreus',
  59: 'Tiago',
  60: '1 Pedro',
  61: '2 Pedro',
  62: '1 João',
  63: '2 João',
  64: '3 João',
  65: 'Judas',
  66: 'Apocalipse',
};

/// Nomes em inglês (fallback para versões não-portuguesas), por ordinal.
const Map<int, String> _enBookNames = {
  1: 'Genesis',
  2: 'Exodus',
  3: 'Leviticus',
  4: 'Numbers',
  5: 'Deuteronomy',
  6: 'Joshua',
  7: 'Judges',
  8: 'Ruth',
  9: '1 Samuel',
  10: '2 Samuel',
  11: '1 Kings',
  12: '2 Kings',
  13: '1 Chronicles',
  14: '2 Chronicles',
  15: 'Ezra',
  16: 'Nehemiah',
  17: 'Esther',
  18: 'Job',
  19: 'Psalms',
  20: 'Proverbs',
  21: 'Ecclesiastes',
  22: 'Song of Solomon',
  23: 'Isaiah',
  24: 'Jeremiah',
  25: 'Lamentations',
  26: 'Ezekiel',
  27: 'Daniel',
  28: 'Hosea',
  29: 'Joel',
  30: 'Amos',
  31: 'Obadiah',
  32: 'Jonah',
  33: 'Micah',
  34: 'Nahum',
  35: 'Habakkuk',
  36: 'Zephaniah',
  37: 'Haggai',
  38: 'Zechariah',
  39: 'Malachi',
  40: 'Matthew',
  41: 'Mark',
  42: 'Luke',
  43: 'John',
  44: 'Acts',
  45: 'Romans',
  46: '1 Corinthians',
  47: '2 Corinthians',
  48: 'Galatians',
  49: 'Ephesians',
  50: 'Philippians',
  51: 'Colossians',
  52: '1 Thessalonians',
  53: '2 Thessalonians',
  54: '1 Timothy',
  55: '2 Timothy',
  56: 'Titus',
  57: 'Philemon',
  58: 'Hebrews',
  59: 'James',
  60: '1 Peter',
  61: '2 Peter',
  62: '1 John',
  63: '2 John',
  64: '3 John',
  65: 'Jude',
  66: 'Revelation',
};

String? _ptBookName(int ordinal) => _ptBookNames[ordinal];
String? _enBookName(int ordinal) => _enBookNames[ordinal];
