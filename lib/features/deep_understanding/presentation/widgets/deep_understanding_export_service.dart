import 'dart:io';
import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

class DeepUnderstandingExportService {
  static String _formatTitle(String query) {
    return 'Entendimento Aprofundado: $query';
  }

  static String _getTimestamp() {
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  }

  static String _formatVersesMetadata(List<VerseEmbedding> verses) {
    if (verses.isEmpty) return '';

    // Extract references from content (format: "[Book Chapter:Verse] content")
    final refs = verses.map((v) {
      final match = RegExp(r'\[(.*?)\]').firstMatch(v.content);
      return match?.group(1) ?? 'Ref desconhecida';
    }).toList();

    if (refs.length > 10) {
      // Simplify: Group by book
      final grouped = <String, List<String>>{};
      for (final ref in refs) {
        final parts = ref.split(' ');
        if (parts.length >= 2) {
          final book = parts.sublist(0, parts.length - 1).join(' ');
          grouped.putIfAbsent(book, () => []).add(ref);
        }
      }

      final buffer = StringBuffer('Base de dados: ');
      buffer.write(grouped.entries
          .map((e) => '${e.key} (${e.value.length} versículos)')
          .join(', '));
      return buffer.toString();
    } else {
      return 'Versículos base: ${refs.join(', ')}';
    }
  }

  static Future<void> exportToTxt(
      String query, String result, List<VerseEmbedding> verses) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);

    buffer.writeln(title);
    buffer.writeln('Gerado em: ${_getTimestamp()}');
    buffer.writeln('=' * title.length);
    buffer.writeln();
    buffer.writeln(result);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(_formatVersesMetadata(verses));

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/entendendimento_holy.txt');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> exportToMd(
      String query, String result, List<VerseEmbedding> verses) async {
    final buffer = StringBuffer();
    final title = _formatTitle(query);

    buffer.writeln('# $title');
    buffer.writeln('_Gerado em: ${_getTimestamp()}_');
    buffer.writeln();
    buffer.writeln(result);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('**Metadados:**');
    buffer.writeln(_formatVersesMetadata(verses));

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/entendimento_holy.md');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> exportToPdf(
      String query, String result, List<VerseEmbedding> verses) async {
    final pdf = pw.Document();
    final title = _formatTitle(query);

    // Load fonts
    final fontData =
        await rootBundle.load("assets/fonts/TASAOrbiter-Regular.ttf");
    final fontBoldData =
        await rootBundle.load("assets/fonts/TASAOrbiter-Bold.ttf");
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
                  pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: ttfBold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Gerado em: ${_getTimestamp()}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            ..._parseMarkdownToPdf(result, ttf, ttfBold),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Text('Metadados',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    font: ttfBold)),
            pw.Text(_formatVersesMetadata(verses),
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/entendimento_holy.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> copyToClipboard(
      String query, String result, List<VerseEmbedding> verses) async {
    final logger = Logger();
    try {
      final buffer = StringBuffer();
      final title = _formatTitle(query);

      buffer.writeln(title);
      buffer.writeln('---');
      buffer.writeln();
      buffer.writeln(result);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln(_formatVersesMetadata(verses));

      await Share.share(buffer.toString());
    } catch (e) {
      logger.e('Erro ao copiar para a área de transferência: $e');
      throw Exception('Erro ao copiar para a área de transferência: $e');
    }
  }

  static List<pw.Widget> _parseMarkdownToPdf(
      String text, pw.Font font, pw.Font fontBold) {
    final lines = text.split('\n');
    final widgets = <pw.Widget>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      // Títulos (ex: **Resumo Central**)
      if (trimmed.startsWith('**') &&
          trimmed.endsWith('**') &&
          !trimmed.substring(2, trimmed.length - 2).contains('**')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(trimmed.replaceAll('**', ''),
              style: pw.TextStyle(font: fontBold, fontSize: 13)),
        ));
        continue;
      }

      // Listas/Bullets
      if (trimmed.startsWith('* ')) {
        widgets.add(pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.5, right: 5),
              child:
                  pw.Text('•', style: pw.TextStyle(font: font, fontSize: 11)),
            ),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children:
                      _parseInlineStyles(trimmed.substring(2), font, fontBold),
                ),
              ),
            ),
          ],
        ));
        widgets.add(pw.SizedBox(height: 4));
        continue;
      }

      // Parágrafos normais com suporte a negrito inline
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.RichText(
          text: pw.TextSpan(
            children: _parseInlineStyles(trimmed, font, fontBold),
          ),
        ),
      ));
    }

    return widgets;
  }

  static List<pw.InlineSpan> _parseInlineStyles(
      String text, pw.Font font, pw.Font fontBold) {
    final spans = <pw.InlineSpan>[];

    // Limpeza de links do Gemini: [[Ref](url)] -> **Ref**
    String processed =
        text.replaceAllMapped(RegExp(r'\[\[(.*?)\]\(.*?\)\]'), (match) {
      return '**${match.group(1)}**';
    });

    // Tratamento de negrito simples: **texto**
    final parts = processed.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Negrito
        spans.add(pw.TextSpan(
            text: parts[i], style: pw.TextStyle(font: fontBold, fontSize: 11)));
      } else {
        // Normal
        if (parts[i].isNotEmpty) {
          spans.add(pw.TextSpan(
              text: parts[i], style: pw.TextStyle(font: font, fontSize: 11)));
        }
      }
    }

    return spans;
  }
}
