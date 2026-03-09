import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/widgets/deep_understanding_export_service.dart';
import 'package:gap/gap.dart';

class DeepUnderstandingActions {
  static void handleBibleLink(BuildContext context, String href) {
    debugPrint('DeepUnderstandingActions: Handling bible link: $href');
    try {
      if (!href.startsWith('bible://')) return;

      var pathPart = href.substring('bible://'.length);
      if (pathPart.startsWith('/')) {
        pathPart = pathPart.substring(1);
      }

      final parts = pathPart.split('/').where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return;

      final bookName =
          Uri.decodeComponent(parts[0]).replaceAll("'", "").replaceAll('"', '');
      final chapterStr =
          parts.length > 1 ? Uri.decodeComponent(parts[1]) : null;
      final verseStr = parts.length > 2 ? Uri.decodeComponent(parts[2]) : null;

      debugPrint(
          'DeepUnderstandingActions: Parsed - Book: $bookName, Chapter: $chapterStr, Verse: $verseStr');

      if (chapterStr == null) return;

      final book = BibleBooks.byName(bookName);
      if (book == null) {
        debugPrint(
            'DeepUnderstandingActions: Book not found in index: "$bookName"');
        return;
      }

      final chapter = int.tryParse(chapterStr);
      if (chapter == null) return;

      List<int>? verses;
      if (verseStr != null) {
        if (verseStr.contains('-')) {
          final parts = verseStr.split('-');
          final start = int.tryParse(parts[0].trim());
          final end = int.tryParse(parts[1].trim());
          if (start != null && end != null && start <= end) {
            verses = List.generate(end - start + 1, (i) => start + i);
          }
        } else if (verseStr.contains(',')) {
          verses = verseStr
              .split(',')
              .map((v) => int.tryParse(v.trim()))
              .whereType<int>()
              .toList();
        } else {
          final v = int.tryParse(verseStr.trim());
          if (v != null) verses = [v];
        }
      }

      final versionId = context.read<BibleVersionCubit>().state.version.id;

      context.read<BibliaBloc>().add(GetChapter(
            versionId,
            book.bookId,
            chapter.toString(),
            verse: verses?.isNotEmpty == true ? verses!.first : null,
            targetVerses: verses,
          ));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BibliaPage()),
      );
    } catch (e) {
      debugPrint('Error handling bible link: $e');
    }
  }

  static void showExportOptions(
      BuildContext context, DeepUnderstandingSuccess state) async {
    final service = context.read<DeepUnderstandingService>();
    final verses = await service.getVersesBySession(state.sessionId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Exportar Entendimento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copiar Texto'),
                onTap: () {
                  Navigator.pop(context);
                  DeepUnderstandingExportService.copyToClipboard(
                      state.query, state.result, verses);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text('Exportar como .TXT'),
                onTap: () {
                  Navigator.pop(context);
                  DeepUnderstandingExportService.exportToTxt(
                      state.query, state.result, verses);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Exportar como .MD (Markdown)'),
                onTap: () {
                  Navigator.pop(context);
                  DeepUnderstandingExportService.exportToMd(
                      state.query, state.result, verses);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar como .PDF'),
                onTap: () {
                  Navigator.pop(context);
                  DeepUnderstandingExportService.exportToPdf(
                      state.query, state.result, verses);
                },
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  static void showCancelDialog(BuildContext context, String sessionId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF9F6F0);
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final bodyTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF6B5A51);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancelar Análise?',
            style: TextStyle(color: primaryTextColor)),
        content: Text(
            'Deseja realmente interromper o processo de entendimento?',
            style: TextStyle(color: bodyTextColor)),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DeepUnderstandingBloc>().add(
                  CancelAnalysisEvent(sessionId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
