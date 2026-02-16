import 'dart:io';
import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class SearchExportService {
  static String _formatTitle(String? query) {
    if (query == null || query.isEmpty) return 'Meus Versículos - Eu Sou';
    return 'Busca: $query - Eu Sou';
  }

  static String _getTimestamp() {
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  }

  static Future<void> exportToTxt(List<SearchResult> results, {String? query}) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);
    
    buffer.writeln(title);
    buffer.writeln('Exportado em: ${_getTimestamp()}');
    buffer.writeln('=' * title.length);
    buffer.writeln();

    for (final result in results) {
      buffer.writeln('${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln(result.verse.text);
      buffer.writeln();
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/resultados_busca.txt');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> exportToMd(List<SearchResult> results, {String? query}) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);

    buffer.writeln('# $title');
    buffer.writeln('_Exportado em: ${_getTimestamp()}_');
    buffer.writeln();

    for (final result in results) {
      buffer.writeln('### ${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln('> ${result.verse.text}');
      buffer.writeln();
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/resultados_busca.md');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> exportToPdf(List<SearchResult> results, {String? query}) async {
    final pdf = pw.Document();
    final title = _formatTitle(query);

    // Carregar fontes para suportar Unicode
    final fontData = await rootBundle.load("assets/fonts/TASAOrbiter-Regular.ttf");
    final fontBoldData = await rootBundle.load("assets/fonts/TASAOrbiter-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontBoldData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttfBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: ttfBold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Exportado em: ${_getTimestamp()}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            ...results.map((result) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, font: ttfBold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(result.verse.text, style: pw.TextStyle(fontSize: 11, font: ttf)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  ),
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

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> copyToClipboard(List<SearchResult> results, {String? query}) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);
    
    buffer.writeln(title);
    buffer.writeln('---');
    buffer.writeln();
    
    for (final result in results) {
      buffer.writeln('${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln(result.verse.text);
      buffer.writeln();
    }
    await Share.share(buffer.toString());
  }
}


  static Future<void> copyToClipboard(List<SearchResult> results, {String? query}) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);
    
    buffer.writeln(title);
    buffer.writeln('---');
    buffer.writeln();
    
    for (final result in results) {
      buffer.writeln('${result.book.name} ${result.chapter.number}:${result.verse.number} (${result.versionId})');
      buffer.writeln(result.verse.text);
      buffer.writeln();
    }
    await Share.share(buffer.toString());
  }
}
