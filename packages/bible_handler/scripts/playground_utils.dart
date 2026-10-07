import 'dart:io';

import 'package:bible_handler/src/models.dart';
import 'package:bible_handler/src/sorting/book_order.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

// ---------------------------------------------------------------------------
// Estruturas do relatório
// ---------------------------------------------------------------------------

enum Severity { pass, warn, fail }

class Finding {
  final Severity severity;
  final String message;

  const Finding(this.severity, this.message);
}

// ---------------------------------------------------------------------------
// Validação individual dos arquivos .usx (antes do parse completo)
// ---------------------------------------------------------------------------

/// Valida o XML de cada arquivo .usx do bundle.
///
/// Arquivos completamente malformados viram FAIL; arquivos que só falham por
/// causa de tags vazias (`<>...</>`, toleradas pelo parser após sanitização)
/// viram WARN. Retorna um finding de PASS quando todos os arquivos são válidos.
List<Finding> validateUsxFiles(String rootPath) {
  final findings = <Finding>[];
  final files = Directory(rootPath)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => p.extension(f.path) == '.usx')
      .toList()
    ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

  if (files.isEmpty) {
    findings.add(
      Finding(Severity.fail, 'Nenhum arquivo .usx encontrado em $rootPath'),
    );
    return findings;
  }

  var warns = 0;
  for (final file in files) {
    final name = p.basename(file.path);
    final content = file.readAsStringSync();
    try {
      XmlDocument.parse(content);
    } on XmlParserException catch (rawError) {
      // Tenta de novo com a sanitização aplicada pelo parser (tags vazias).
      try {
        XmlDocument.parse(sanitizeUsx(content));
        warns++;
        findings.add(
          Finding(
            Severity.warn,
            '$name contém tags vazias `<>...</>` '
            '(toleradas pelo parser, mas corrigir no zip): $rawError',
          ),
        );
      } on XmlParserException {
        findings.add(
          Finding(Severity.fail, '$name tem XML inválido: $rawError'),
        );
      }
    }
  }

  if (warns == 0) {
    findings.add(
      Finding(Severity.pass, '${files.length} arquivos .usx com XML válido'),
    );
  }
  return findings;
}

/// Remove tags vazias `<>` e `</>` (mesma sanitização aplicada pelo UsxParser).
String sanitizeUsx(String content) {
  final withoutOpenTag = content.replaceAll('<>', '');
  final withoutCloseTag = withoutOpenTag.replaceAll('</>', '');
  return withoutCloseTag;
}

// ---------------------------------------------------------------------------
// Bateria de verificações de uma versão carregada
// ---------------------------------------------------------------------------

List<Finding> runChecks(Bible bible, String version) {
  final findings = <Finding>[];

  // --- Metadados ------------------------------------------------------------
  if (bible.abbreviation.toUpperCase() != version) {
    findings.add(
      Finding(
        Severity.warn,
        'Abreviação nos metadados ("${bible.abbreviation}") difere da versão '
        'solicitada ("$version") — o zip pode conter outra tradução!',
      ),
    );
  }

  final metadata = <String, String?>{
    'name': bible.name,
    'abbreviation': bible.abbreviation,
    'nameLocal': bible.nameLocal,
    'description': bible.description,
    'scope': bible.scope,
    'bundleProducer': bible.bundleProducer,
    'languageName': bible.languageName,
    'languageIso': bible.languageIso,
    'languageScriptDirection': bible.languageScriptDirection,
    'copyright': bible.copyright,
  };

  stdout.writeln('\n   Metadados:');
  for (final entry in metadata.entries) {
    final value = entry.value;
    final display = (value == null || value.trim().isEmpty)
        ? '<vazio>'
        : (value.length > 80 ? '${value.substring(0, 80)}…' : value);
    stdout.writeln('     ${entry.key.padRight(24)} $display');

    if (entry.key == 'name' || entry.key == 'abbreviation') {
      if (value == null || value.trim().isEmpty) {
        findings.add(
          Finding(Severity.fail, 'Metadado obrigatório ausente: ${entry.key}'),
        );
      }
    } else if (value == null || value.trim().isEmpty) {
      findings
          .add(Finding(Severity.warn, 'Metadado opcional vazio: ${entry.key}'));
    }
  }

  // --- Livros -----------------------------------------------------------------
  stdout.writeln('\n   Livros:');
  final bookIds = bible.books.map((b) => b.id.toUpperCase()).toSet();
  final missing =
      canonicalBookOrder.where((id) => !bookIds.contains(id)).toList();
  final unknown =
      bookIds.where((id) => !canonicalBookOrder.contains(id)).toList();

  stdout.writeln('     total de livros: ${bible.books.length}');
  stdout
      .writeln('     ordem canônica respeitada: ${isInCanonicalOrder(bible)}');

  if (bible.books.length == 66) {
    findings.add(
      Finding(
          Severity.pass, '66 livros presentes (cânon protestante completo)'),
    );
  } else {
    findings.add(
      Finding(
        Severity.warn,
        '${bible.books.length} livros (esperados 66). '
        'Faltando: ${missing.isEmpty ? "nenhum" : missing.join(", ")}. '
        'Fora do cânon: ${unknown.isEmpty ? "nenhum" : unknown.join(", ")}',
      ),
    );
  }

  if (unknown.isNotEmpty) {
    findings.add(
      Finding(
        Severity.warn,
        'Livros com IDs fora da lista canônica '
        '(verificar book_order.dart): ${unknown.join(", ")}',
      ),
    );
  }

  if (isInCanonicalOrder(bible)) {
    findings.add(Finding(Severity.pass, 'Livros em ordem canônica'));
  } else {
    findings.add(Finding(Severity.fail, 'Livros fora da ordem canônica'));
  }

  // --- Capítulos e versos -----------------------------------------------------
  var totalChapters = 0;
  var totalVerses = 0;
  var emptyVerses = 0;
  var duplicateNumbers = 0;
  var zeroNumberedVerses = 0;

  for (final book in bible.books) {
    totalChapters += book.chapters.length;
    for (final chapter in book.chapters) {
      final seen = <int>{};
      for (final verse in chapter.verses) {
        totalVerses++;
        if (verse.text.trim().isEmpty) emptyVerses++;
        if (verse.number <= 0) zeroNumberedVerses++;
        if (!seen.add(verse.number)) duplicateNumbers++;
      }
    }
  }

  stdout.writeln('\n   Conteúdo:');
  stdout.writeln('     capítulos: $totalChapters');
  stdout.writeln('     versos: $totalVerses');
  stdout.writeln('     versos vazios: $emptyVerses');
  stdout.writeln('     versos com número <= 0: $zeroNumberedVerses');
  stdout.writeln('     números de verso duplicados: $duplicateNumbers');

  if (totalVerses < 31000) {
    findings.add(
      Finding(
        Severity.warn,
        'Poucos versos ($totalVerses). Uma Bíblia completa costuma ter ~31.100.',
      ),
    );
  } else {
    findings
        .add(Finding(Severity.pass, 'Total de versos plausível: $totalVerses'));
  }

  if (totalChapters != 1189) {
    findings.add(
      Finding(
        Severity.warn,
        'Total de capítulos ($totalChapters) difere do padrão de 1189.',
      ),
    );
  } else {
    findings.add(Finding(Severity.pass, 'Total de capítulos padrão: 1189'));
  }

  if (emptyVerses > 0) {
    findings.add(Finding(Severity.fail, '$emptyVerses versos com texto vazio'));
  } else {
    findings.add(Finding(Severity.pass, 'Nenhum verso vazio'));
  }

  if (zeroNumberedVerses > 0) {
    findings.add(
      Finding(Severity.warn, '$zeroNumberedVerses versos com número <= 0'),
    );
  }
  if (duplicateNumbers > 0) {
    findings.add(
      Finding(Severity.warn, '$duplicateNumbers números de verso duplicados'),
    );
  }

  // --- Versos de amostra --------------------------------------------------------
  stdout.writeln('\n   Versos de amostra:');
  const samples = <String, String>{
    'GEN': '1',
    'PSA': '23',
    'ISA': '53',
    'MAT': '5',
    'JHN': '3',
    'REV': '22',
  };
  for (final entry in samples.entries) {
    final book =
        bible.books.where((b) => b.id.toUpperCase() == entry.key).firstOrNull;
    if (book == null) {
      stdout.writeln('     ${entry.key} — livro não encontrado');
      findings.add(
          Finding(Severity.warn, 'Livro de amostra ausente: ${entry.key}'));
      continue;
    }
    final chapter = book.chapters
        .where((c) => c.number.toString() == entry.value)
        .firstOrNull;
    if (chapter == null || chapter.verses.isEmpty) {
      stdout.writeln(
          '     ${entry.key} ${entry.value} — capítulo não encontrado');
      findings.add(
        Finding(Severity.warn,
            'Capítulo de amostra ausente: ${entry.key} ${entry.value}'),
      );
      continue;
    }
    final verse = chapter.verses.first;
    final text = verse.text.trim();
    stdout
        .writeln('     ${book.name} ${chapter.number}:${verse.number} — $text');
    if (text.isEmpty) {
      findings.add(
        Finding(Severity.fail,
            'Verso de amostra vazio: ${entry.key} ${entry.value}:1'),
      );
    }
  }

  // --- Busca ------------------------------------------------------------------
  stdout.writeln('\n   Busca ("Deus"):');
  final stopwatch = Stopwatch()..start();
  final results = bible.search('Deus');
  stopwatch.stop();
  stdout.writeln(
    '     ${results.totalResults} resultados em ${stopwatch.elapsedMilliseconds} ms',
  );
  for (final result in results.results.take(3)) {
    stdout.writeln('     • $result');
  }
  if (results.totalResults == 0) {
    findings.add(
      Finding(
        Severity.warn,
        'Busca por "Deus" retornou 0 resultados (verificar encoding)',
      ),
    );
  } else {
    findings.add(
      Finding(
        Severity.pass,
        'Busca por "Deus": ${results.totalResults} resultados '
        '(${stopwatch.elapsedMilliseconds} ms)',
      ),
    );
  }

  // Busca com acento — expõe problemas de normalização/encoding.
  final accented = bible.search('espírito');
  if (accented.totalResults == 0) {
    final unaccented = bible.search('espirito');
    if (unaccented.totalResults > 0) {
      findings.add(
        Finding(
          Severity.warn,
          'Busca com acento ("espírito") falhou mas sem acento funciona — '
          'possível problema de encoding/normalização',
        ),
      );
    } else {
      findings.add(
        Finding(Severity.warn, 'Busca por "espírito" retornou 0 resultados'),
      );
    }
  }

  return findings;
}

bool isInCanonicalOrder(Bible bible) {
  final ids = bible.books.map((b) => b.id.toUpperCase()).toList();
  final canonical = ids.where(canonicalBookOrder.contains).toList();
  final sorted = List<String>.from(canonical)
    ..sort(
      (a, b) => canonicalBookOrder
          .indexOf(a)
          .compareTo(canonicalBookOrder.indexOf(b)),
    );
  return const ListEquality().equals(canonical, sorted);
}

// ---------------------------------------------------------------------------
// Relatório e formatação
// ---------------------------------------------------------------------------

void header(String title) {
  stdout.writeln('\n${'=' * 70}');
  stdout.writeln(title);
  stdout.writeln('=' * 70);
}

void section(String title) {
  stdout.writeln('\n--- $title ---');
}

String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value >= 100 || unit == 0 ? 0 : 1)} ${units[unit]}';
}

void printReport(String version, List<Finding> findings) {
  header('Relatório — $version');

  const icons = {Severity.pass: '✔', Severity.warn: '⚠', Severity.fail: '✖'};
  for (final f in findings) {
    stdout.writeln(
        '${icons[f.severity]} [${f.severity.name.toUpperCase()}] ${f.message}');
  }

  final fails = findings.where((f) => f.severity == Severity.fail).length;
  final warns = findings.where((f) => f.severity == Severity.warn).length;
  final passes = findings.where((f) => f.severity == Severity.pass).length;

  stdout.writeln('\nResumo: $passes PASS / $warns WARN / $fails FAIL');
  stdout.writeln(
    fails > 0
        ? 'Resultado: FALHOU — corrija os itens FAIL antes de publicar a versão.'
        : warns > 0
            ? 'Resultado: OK com avisos — revise os WARNs.'
            : 'Resultado: APROVADO — versão pronta para publicação.',
  );
}

// equals de lista simples (evita depender de package:collection)
class ListEquality {
  const ListEquality();

  bool equals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
