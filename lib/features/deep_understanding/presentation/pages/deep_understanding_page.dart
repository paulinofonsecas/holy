import 'package:eu_sou/core/design_system/theme/theme_extension.dart';
import 'package:eu_sou/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/presentation/widgets/deep_understanding_export_service.dart';
import 'package:gap/gap.dart';
import '../bloc/deep_understanding_bloc.dart';

class DeepUnderstandingPage extends StatelessWidget {
  const DeepUnderstandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Quando voltamos de uma visualização, recarregamos o histórico
          // para garantir que o estado do Bloc volte para 'HistoryLoaded' se necessário
          context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : const Color(0xFFF9F6F0),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : const Color(0xFF2D1B13),
            ),
            onPressed: () {
              final state = context.read<DeepUnderstandingBloc>().state;
              if (state is DeepUnderstandingInProgress) {
                _showCancelDialog(context, state.session.sessionId);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            children: [
              Text(
                'JORNADA DA ALMA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : const Color(0xFF2D1B13),
                ),
              ),
              Text(
                'Entendimento Aprofundado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : const Color(0xFF2D1B13),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
              builder: (context, state) {
                if (state is DeepUnderstandingSuccess) {
                  return IconButton(
                    icon: Icon(
                      Icons.ios_share,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : const Color(0xFF2D1B13),
                    ),
                    onPressed: () => _showExportOptions(context, state),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<DeepUnderstandingBloc, DeepUnderstandingState>(
          listener: (context, state) {
            if (state is DeepUnderstandingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
            if (state is DeepUnderstandingCancelled) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is DeepUnderstandingInitial) {
              context
                  .read<DeepUnderstandingBloc>()
                  .add(const LoadHistoryEvent());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DeepUnderstandingInProgress) {
              return _buildProgressView(context, state);
            }

            if (state is DeepUnderstandingSuccess) {
              return _buildSuccessView(context, state);
            }

            if (state is DeepUnderstandingFailure) {
              return _buildErrorView(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProgressView(
      BuildContext context, DeepUnderstandingInProgress state) {
    final isEmbedding = state.session.status == 'embedding';
    final statusText = isEmbedding
        ? 'Vetorizando e analisando trechos...'
        : 'Gerando entendimento teológico...';

    return Container(
      color: const Color(0xFFF9F6F0),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF3B5E53).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 40, color: Color(0xFF3B5E53)),
            ),
            const SizedBox(height: 32),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B13),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE6E0D4),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF3B5E53)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.session.processedItems} / ${state.session.totalItems} trechos processados',
              style: const TextStyle(fontSize: 13, color: Color(0xFF8B7765)),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B5E53)),
                foregroundColor: const Color(0xFF3B5E53),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar em Segundo Plano'),
            ),
            TextButton(
              onPressed: () =>
                  _showCancelDialog(context, state.session.sessionId),
              child: const Text('Cancelar Análise',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(
      BuildContext context, DeepUnderstandingSuccess state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF5A4034);
    final accentTextColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFB05B3B);
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final ruleColor = isDark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE6E0D4);
    final blockquoteBg = isDark
        ? Theme.of(context).colorScheme.surfaceContainer
        : const Color(0xFFFDF5EB);

    // Extract a short first-paragraph teaser from the result
    String teaser = state.result;
    teaser = teaser.replaceAll(RegExp(r'\*\*|\*|#|`|\[.*?\]\(.*?\)'), '');
    teaser = teaser.trim();
    if (teaser.length > 120) teaser = '${teaser.substring(0, 120)}...';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner ──────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.surfaceContainer
                          ]
                        : [const Color(0xFF4A2B1D), const Color(0xFF3B5E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.12,
                  child: GridView.count(
                    crossAxisCount: 20,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      200,
                      (i) => const Text('✦',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'ESTUDO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: isDark
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFFD4A96A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.query.isEmpty
                            ? 'Entendimento Aprofundado'
                            : state.query,
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Georgia',
                          color: isDark
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Teaser / Lead paragraph ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              '"$teaser"',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                color: secondaryTextColor,
                height: 1.5,
              ),
            ),
          ),

          // ── Main Markdown body ────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: MarkdownBody(
              data: state.result,
              selectable: true,
              onTapLink: (text, href, title) {
                if (href != null && href.startsWith('bible://')) {
                  _handleBibleLink(context, href);
                }
              },
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: primaryTextColor,
                ),
                h1: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  height: 2.0,
                ),
                h2: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  height: 2.0,
                  decoration: TextDecoration.none,
                ),
                h3: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: secondaryTextColor,
                ),
                a: TextStyle(
                  color: accentTextColor,
                  decoration: TextDecoration.underline,
                ),
                blockquote: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: accentTextColor,
                  height: 1.6,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: blockquoteBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    left: BorderSide(color: accentTextColor, width: 4),
                  ),
                ),
                blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                h2Padding: const EdgeInsets.only(top: 8),
                h1Padding: const EdgeInsets.only(top: 8),
                horizontalRuleDecoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: ruleColor, width: 1)),
                ),
              ),
            ),
          ),

          // ── Benchmarks ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: _buildBenchmarks(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarks(DeepUnderstandingSuccess state) {
    if (state.totalDurationMillis == null) return const SizedBox.shrink();

    String formatTime(int? ms) {
      if (ms == null) return 'N/A';
      if (ms < 1000) return '${ms}ms';
      return '${(ms / 1000).toStringAsFixed(2)}s';
    }

    return ExpansionTile(
      leading: const Icon(Icons.timer_outlined, size: 20),
      title: const Text(
        'Benchmarks de Performance',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Tempo total: ${formatTime(state.totalDurationMillis)}',
        style: const TextStyle(fontSize: 12),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildBenchmarkRow('Vetorização (Embeddings):',
            formatTime(state.embeddingDurationMillis)),
        _buildBenchmarkRow(
            'Busca Vetorial:', formatTime(state.searchDurationMillis)),
        _buildBenchmarkRow(
            'Geração de Resumo:', formatTime(state.summaryDurationMillis)),
        const Divider(),
        _buildBenchmarkRow('Tempo Total de Processamento:',
            formatTime(state.totalDurationMillis),
            isBold: true),
      ],
    );
  }

  Widget _buildBenchmarkRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, DeepUnderstandingFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Ops! Algo deu errado.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry logic could be added here
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBibleLink(BuildContext context, String href) {
    debugPrint('DeepUnderstandingPage: Handling bible link: $href');
    try {
      if (!href.startsWith('bible://')) return;

      // Extract the path after bible://
      // Handle optional third slash e.g., bible:///BookName
      var pathPart = href.substring('bible://'.length);
      if (pathPart.startsWith('/')) {
        pathPart = pathPart.substring(1);
      }

      final parts = pathPart.split('/').where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return;

      // Decode in case it's percent-encoded, and sanitize
      final bookName =
          Uri.decodeComponent(parts[0]).replaceAll("'", "").replaceAll('"', '');
      final chapterStr =
          parts.length > 1 ? Uri.decodeComponent(parts[1]) : null;
      final verseStr = parts.length > 2 ? Uri.decodeComponent(parts[2]) : null;

      debugPrint(
          'DeepUnderstandingPage: Parsed - Book: $bookName, Chapter: $chapterStr, Verse: $verseStr');

      if (chapterStr == null) return;

      final book = BibleBooks.byName(bookName);
      if (book == null) {
        debugPrint(
            'DeepUnderstandingPage: Book not found in index: "$bookName"');
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

      // Navigate
      final versionId = context.read<BibleVersionCubit>().state.version.id;

      // Load Chapter before navigating
      context.read<BibliaBloc>().add(GetChapter(
            versionId,
            book.bookId,
            chapter.toString(),
            verse: verses?.isNotEmpty == true ? verses!.first : null,
            targetVerses: verses,
          ));

      // Push BibliaPage on top to allow returning
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BibliaPage()),
      );
    } catch (e) {
      debugPrint('Error handling bible link: $e');
    }
  }

  void _showExportOptions(
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

  void _showCancelDialog(BuildContext context, String sessionId) {
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
              Navigator.pop(dialogContext);
              context
                  .read<DeepUnderstandingBloc>()
                  .add(CancelAnalysisEvent(sessionId));
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
