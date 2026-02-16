import 'dart:io';
import 'package:bible_handler/bible_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class SearchExportService {
  static Future<void> exportToTxt(List<SearchResult> results) async {
    final buffer = StringBuffer();
    buffer.writeln('Resultados da Busca - Eu Sou');
    buffer.writeln('----------------------------');
    buffer.writeln();

    for (final result in results) {
      buffer.writeln('${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln(result.verse.text);
      buffer.writeln();
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/resultados_busca.txt');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Meus resultados de busca da Bíblia');
  }

  static Future<void> exportToMd(List<SearchResult> results) async {
    final buffer = StringBuffer();
    buffer.writeln('# Resultados da Busca - Eu Sou');
    buffer.writeln();

    for (final result in results) {
      buffer.writeln('### ${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln('> ${result.verse.text}');
      buffer.writeln();
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/resultados_busca.md');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Meus resultados de busca da Bíblia');
  }

  static Future<void> exportToPdf(List<SearchResult> results) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Resultados da Busca - Eu Sou', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            ...results.map((result) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(result.verse.text, style: const pw.TextStyle(fontSize: 12)),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                ],
              );
            }),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/resultados_busca.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Meus resultados de busca da Bíblia');
  }

  static Future<void> copyToClipboard(List<SearchResult> results) async {
    final buffer = StringBuffer();
    for (final result in results) {
      buffer.writeln('${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln(result.verse.text);
      buffer.writeln();
    }
    // We can use Share.share for simple text copy if needed, but clipboard is better.
    // However, Share.share also allows copying.
    await Share.share(buffer.toString());
  }
}
