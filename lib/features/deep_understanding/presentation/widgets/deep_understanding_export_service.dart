import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DeepUnderstandingExportService {
  static String _formatTitle(String query) {
    return 'Entendimento Aprofundado: $query';
  }

  static String _getTimestamp() {
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  }

  static String _formatVersesMetadata(List<VerseEmbedding> verses) {
    if (verses.isEmpty) return '';

    final refs = verses.map((v) {
      final match = RegExp(r'\[(.*?)\]').firstMatch(v.content);
      return match?.group(1) ?? 'Ref desconhecida';
    }).toList();

    if (refs.length > 10) {
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

    await Share.share(buffer.toString(), subject: title);
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

    await Share.share(buffer.toString(), subject: title);
  }

  static Future<void> exportToPdf(
      String query, String result, List<VerseEmbedding> verses) async {
    await exportToMd(query, result, verses);
  }

  static Future<void> copyToClipboard(
      String query, String result, List<VerseEmbedding> verses) async {
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
      throw Exception('Erro ao copiar: $e');
    }
  }
}
