import 'dart:io';

import 'package:archive/archive.dart';
// Imports diretos (evitam o barrel bible_handler.dart, que depende de Flutter
// via bible_cache_provider e impediria `dart run` fora do Flutter).
import 'package:bible_handler/src/models.dart';
import 'package:bible_handler/src/parsers/usx_parser_io.dart';
import 'package:bible_handler/src/services/download_service_io.dart';
import 'package:bible_handler/src/sorting/canonical_book_sorter.dart';
import 'package:path/path.dart' as p;

import 'playground_utils.dart';

/// Playground para testar uma NOVA versão da Bíblia (USX empacotado em .zip).
///
/// Uso:
///   dart run scripts/playground_bible_versions.dart `<VERSAO>`
///   dart run scripts/playground_bible_versions.dart NVI --keep
///   dart run scripts/playground_bible_versions.dart NOVA --url https://.../NOVA.zip
///
/// Fluxo:
///   1. Baixa o .zip da versão (GitHub ou --url customizada).
///   2. Extrai em um diretório temporário.
///   3. Faz o parse do USX.
///   4. Roda bateria de verificações (metadados, livros, capítulos, versos,
///      versos de amostra e busca).
///   5. Imprime um relatório PASS/WARN/FAIL e sai com código de erro se houver FAIL.
Future<void> main(List<String> args) async {
  final rawArgs = args.where((a) => a != '--keep').toList();
  final keepFiles = args.contains('--keep');
  final showHelp = rawArgs.contains('--help') || rawArgs.contains('-h');

  if (showHelp || rawArgs.isEmpty) {
    stdout.writeln('''
Playground de versões bíblicas — bible_handler

Uso:
  dart run scripts/playground_bible_versions.dart <VERSAO> [--url <url>] [--keep]

Exemplos:
  dart run scripts/playground_bible_versions.dart KJA
  dart run scripts/playground_bible_versions.dart NVI --keep
  dart run scripts/playground_bible_versions.dart NOVA \\
      --url https://raw.githubusercontent.com/paulinofonsecas/biblias/main/inst/usx/traducao/NOVA.zip

Opções:
  --url <url>  Baixa de uma URL customizada (útil para versões ainda não publicadas).
  --keep       Mantém o diretório temporário com os arquivos extraídos para inspeção.''');
    exit(showHelp ? 0 : 64);
  }

  final version = rawArgs.first.toUpperCase();

  final urlIndex = rawArgs.indexOf('--url');
  final url = urlIndex != -1 && urlIndex + 1 < rawArgs.length
      ? rawArgs[urlIndex + 1]
      : 'https://raw.githubusercontent.com/paulinofonsecas/biblias/main/inst/usx/traducao/$version.zip';

  header('Playground de versão bíblica: $version');
  stdout.writeln('URL de download: $url\n');

  final tempDir = await Directory.systemTemp.createTemp(
    'bible_playground_${DateTime.now().millisecondsSinceEpoch}',
  );

  final findings = <Finding>[];
  DownloadService? downloadService;

  try {
    // ------------------------------------------------------------------
    // 1. Download
    // ------------------------------------------------------------------
    section('1. Download do arquivo .zip');
    final zipFile = File(p.join(tempDir.path, '$version.zip'));

    final downloadStopwatch = Stopwatch()..start();
    downloadService = DownloadService();
    var lastPercent = -1;
    await for (final progress in downloadService.download(url, zipFile.path)) {
      switch (progress.status) {
        case DownloadStatus.downloading:
          final pct = (progress.percent * 100).round();
          if (pct != lastPercent && pct % 10 == 0) {
            stdout.writeln(
              '   baixando... $pct% '
              '(${formatBytes(progress.downloadedBytes)} / '
              '${formatBytes(progress.totalBytes)})',
            );
            lastPercent = pct;
          }
          break;
        case DownloadStatus.error:
          findings.add(
            Finding(
              Severity.fail,
              'Falha no download: ${progress.message}',
            ),
          );
          break;
        default:
          break;
      }
    }
    downloadStopwatch.stop();

    if (!zipFile.existsSync()) {
      stdout.writeln('   O arquivo .zip não foi criado. Abortando.');
      printReport(version, findings);
      exit(1);
    }
    stdout.writeln(
      '   OK — ${formatBytes(zipFile.lengthSync())} em '
      '${downloadStopwatch.elapsedMilliseconds} ms',
    );

    // ------------------------------------------------------------------
    // 2. Extração
    // ------------------------------------------------------------------
    section('2. Extração do .zip');
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = p.join(tempDir.path, file.name);
      if (file.isFile) {
        final outFile = File(filename);
        Directory(p.dirname(filename)).createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filename).createSync(recursive: true);
      }
    }
    stdout.writeln(
      '   OK — ${archive.length} entradas extraídas em ${tempDir.path}',
    );

    // Localiza o diretório raiz do bundle (metadata.xml pode estar em subpasta).
    var effectivePath = tempDir.path;
    if (!File(p.join(effectivePath, 'metadata.xml')).existsSync()) {
      final subDirs = tempDir
          .listSync()
          .whereType<Directory>()
          .where((d) => p.basename(d.path) != '.')
          .toList();
      if (subDirs.isNotEmpty &&
          File(p.join(subDirs.first.path, 'metadata.xml')).existsSync()) {
        effectivePath = subDirs.first.path;
      }
    }

    // ------------------------------------------------------------------
    // 3. Parse
    // ------------------------------------------------------------------
    section('3. Parse USX');

    // Valida o XML de cada arquivo primeiro, para identificar exatamente
    // qual arquivo está malformado em vez de só receber um stack trace.
    findings.addAll(validateUsxFiles(effectivePath));

    final parseStopwatch = Stopwatch()..start();
    final bible = await UsxParser().parse(
      effectivePath,
      sorter: const CanonicalBookSorter(),
    );
    parseStopwatch.stop();
    stdout.writeln(
      '   OK — ${bible.books.length} livros em '
      '${parseStopwatch.elapsedMilliseconds} ms',
    );

    // ------------------------------------------------------------------
    // 4. Bateria de verificações
    // ------------------------------------------------------------------
    findings.addAll(runChecks(bible, version));
  } catch (e, st) {
    findings.add(
      Finding(Severity.fail, 'Exceção não tratada: $e\n$st'),
    );
  } finally {
    if (downloadService != null) {
      downloadService.dispose();
    }
    if (!keepFiles) {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    } else {
      stdout.writeln('\nArquivos temporários mantidos em: ${tempDir.path}');
    }
  }

  printReport(version, findings);

  final hasFail = findings.any((f) => f.severity == Severity.fail);
  exit(hasFail ? 1 : 0);
}
