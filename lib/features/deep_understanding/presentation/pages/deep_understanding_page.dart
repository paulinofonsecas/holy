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
        appBar: AppBar(
          title: const Text('Entendimento Aprofundado'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              final state = context.read<DeepUnderstandingBloc>().state;
              if (state is DeepUnderstandingInProgress) {
                _showCancelDialog(context, state.session.sessionId);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
              builder: (context, state) {
                if (state is DeepUnderstandingSuccess) {
                  return IconButton(
                    icon: const Icon(Icons.ios_share),
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
    final statusText = state.session.status == 'embedding'
        ? 'Vetorizando e analisando trechos...'
        : 'Gerando entendimento teológico...';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            statusText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: state.progress),
          const SizedBox(height: 8),
          Text(
              '${state.session.processedItems} / ${state.session.totalItems} concluídos'),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement "Process in jBackground" in User Story 2
              Navigator.pop(context);
            },
            child: const Text('Processar em Segundo Plano'),
          ),
          TextButton(
            onPressed: () =>
                _showCancelDialog(context, state.session.sessionId),
            child: const Text('Cancelar Análise',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
      BuildContext context, DeepUnderstandingSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entendimento sobre: ${state.query}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),
          MarkdownBody(
            data: state.result,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href != null && href.startsWith('bible://')) {
                _handleBibleLink(context, href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, height: 1.5),
              h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          _buildBenchmarks(state),
          const SizedBox(height: 32),
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
      // Format can be bible://BookName/Chapter/Verse
      // Or bible:///BookName/Chapter/Verse
      final uri = Uri.parse(href);
      if (uri.scheme != 'bible') return;

      String? bookName;
      String? chapterStr;
      String? verseStr;

      if (uri.host.isNotEmpty) {
        // Case: bible://BookName/Chapter/Verse
        bookName = Uri.decodeComponent(uri.host);
        if (uri.pathSegments.isNotEmpty) {
          chapterStr = Uri.decodeComponent(uri.pathSegments[0]);
          if (uri.pathSegments.length > 1) {
            verseStr = Uri.decodeComponent(uri.pathSegments[1]);
          }
        }
      } else if (uri.pathSegments.length >= 2) {
        // Case: bible:///BookName/Chapter/Verse
        bookName = Uri.decodeComponent(uri.pathSegments[0]);
        chapterStr = Uri.decodeComponent(uri.pathSegments[1]);
        if (uri.pathSegments.length > 2) {
          verseStr = Uri.decodeComponent(uri.pathSegments[2]);
        }
      }

      debugPrint(
          'DeepUnderstandingPage: Parsed - Book: $bookName, Chapter: $chapterStr, Verse: $verseStr');

      if (bookName == null || chapterStr == null) return;

      // Unquote bookName if necessary (LLMs sometimes add quotes inside links)
      bookName = bookName.replaceAll("'", "").replaceAll('"', '');

      final book = BibleBooks.byName(bookName);
      if (book == null) {
        debugPrint(
            'DeepUnderstandingPage: Book not found in index: "$bookName"');
        return;
      }

      final chapter = int.tryParse(chapterStr);
      if (chapter == null) return;

      final verse = verseStr != null ? int.tryParse(verseStr) : null;

      // Navigate
      final versionId = context.read<BibleVersionCubit>().state.version.id;

      // Load Chapter before navigating
      context.read<BibliaBloc>().add(GetChapter(
            versionId,
            book.bookId,
            chapter.toString(),
            verse: verse,
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Análise?'),
        content: const Text(
            'Deseja realmente interromper o processo de entendimento?'),
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
