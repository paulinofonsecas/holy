import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/core/services/share_service.dart';
import 'package:eu_sou/core/services/toast_service.dart';
import 'package:eu_sou/features/search/presentation/widgets/deep_understanding_dialog.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/rich_verse_action_modal.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../rich_modal_viewmodel.dart';
import 'action_row.dart';
import 'highlight_row.dart';

class VerseActionsPage {
  static WoltModalSheetPage build({
    required BuildContext context,
    required RichModalViewModel viewModel,
    required VoidCallback goToImageCreator,
  }) {
    final theme = Theme.of(context);

    return WoltModalSheetPage(
      topBarTitle: Text(
        viewModel.verseReference,
        style: theme.textTheme.titleMedium,
      ),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01),
        onPressed: () {
          viewModel.clearSelection();
          Navigator.of(context).pop();
        },
      ),
      child: const Placeholder(),
      // child: SingleChildScrollView(
      //   scrollDirection: Axis.horizontal,
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      //     child: ActionRowWidget(
      //       viewModel: viewModel,
      //       goToImageCreator: goToImageCreator,
      //     ),
      //   ),
      // ),
    );
  }
}

class ActionRowWidget extends StatefulWidget {
  const ActionRowWidget({
    super.key,
    required this.verses,
    required this.verseReference,
    required this.bookId,
    required this.chapterNumber,
  });

  final List<BibleVerse> verses;
  final String verseReference;
  final String bookId;
  final int chapterNumber;

  @override
  State<ActionRowWidget> createState() => _ActionRowWidgetState();
}

class _ActionRowWidgetState extends State<ActionRowWidget> {
  @override
  Widget build(BuildContext context) {
    final highlightBloc = context.read<HighlightBloc>();
    final selectionBloc = context.read<VerseSelectionBloc>();
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    final normalizedVersionId = versionId.toUpperCase();
    final cacheProvider = context.read<BibleCacheProvider>();
    final logger = LoggerService();
    final verseNumbers = widget.verses.map((verse) => verse.number).toList();

    final viewModel = RichModalViewModel(
      verses: widget.verses,
      verseReference: widget.verseReference,
      versionId: versionId,
      bookId: widget.bookId,
      chapterNumber: widget.chapterNumber,
      highlightBloc: highlightBloc,
      selectionBloc: selectionBloc,
    );

    Future<List<String>> resolveTargetVersionIds() async {
      try {
        final rows = await cacheProvider.db.query('versions', columns: ['id']);
        final cached = rows
            .map((row) => row['id'] as String?)
            .whereType<String>()
            .map((id) => id.toUpperCase())
            .where((id) => id != normalizedVersionId)
            .toSet()
            .toList();

        if (cached.isNotEmpty) {
          return cached;
        }
      } catch (error, stackTrace) {
        logger.warning(
          'Failed to load cached versions for comparison',
          error,
          stackTrace,
        );
      }

      final fallback = <String>[];
      for (final version in BibleVersions.values) {
        final id = version.id.toUpperCase();
        if (id == normalizedVersionId) {
          continue;
        }
        try {
          if (await cacheProvider.isVersionCached(id)) {
            fallback.add(id);
          }
        } catch (error, stackTrace) {
          logger.warning(
            'Failed to verify cached status for version $id',
            error,
            stackTrace,
          );
        }
      }
      return fallback;
    }

    viewModel.onShareText = () async {
      final deeplinkService = context.read<IDeeplinkService>();
      String? deeplink;

      try {
        final verseRef =
            "${widget.bookId}_${widget.chapterNumber}_${widget.verses.first.number}";
        deeplink = await deeplinkService.createShortLink(
          verseRef: verseRef,
          source: 'share',
        );
      } catch (e) {
        logger.warning('Failed to generate deep link for sharing: $e');
      }

      ShareService.shareVerses(
        verses: widget.verses,
        bookName: widget.bookId,
        chapterNumber: widget.chapterNumber,
        versionId: versionId,
        deeplink: deeplink,
      );
    };

    viewModel.onCompareVersions = () async {
      if (verseNumbers.isEmpty) {
        logger
            .warning('Compare versions requested without any verses selected');
        return;
      }

      final navigator = Navigator.of(context);
      final bibleRepository = context.read<IBibleRepository>();
      final currentBookId = widget.bookId;
      final currentChapter = widget.chapterNumber;
      final currentReference = widget.verseReference;

      final verseNumber = verseNumbers.reduce(
        (value, element) => value < element ? value : element,
      );

      final targetVersionIds = await resolveTargetVersionIds();

      viewModel.clearSelection();

      if (!navigator.context.mounted) return;

      await CompareVersionsModal.show(
        // ignore: use_build_context_synchronously
        context: navigator.context,
        bibleRepository: bibleRepository,
        request: ComparisonRequest(
          bookId: currentBookId,
          chapterNumber: currentChapter,
          verseNumber: verseNumber,
          sourceVersionId: normalizedVersionId,
          targetVersionIds: targetVersionIds,
        ),
        verseReference: currentReference,
      );
    };

    return Row(
      children: [
        HighlightRow(
          onColorSelected: (color) {
            viewModel.applyHighlight(color);
            viewModel.clearSelection();
          },
          onRemoveHighlight: () {
            viewModel.removeHighlight();
            viewModel.clearSelection();
          },
        ),
        ActionRow(
          onShare: () {
            if (viewModel.onShareText != null) {
              viewModel.onShareText!();
            }
            viewModel.clearSelection();
          },
          onCreateImage: () {
            // Build proper verse reference from available fields
            final sortedVerses = [...widget.verses]
              ..sort((a, b) => a.number.compareTo(b.number));
            final ref = sortedVerses.length == 1
                ? '${widget.bookId} ${widget.chapterNumber}:${sortedVerses.first.number}'
                : '${widget.bookId} ${widget.chapterNumber}:${sortedVerses.first.number}-${sortedVerses.last.number}';
            RichVerseActionModal.show(
              context: context,
              verses: widget.verses,
              verseReference: ref,
              versionId: versionId,
            );
          },
          onCopy: () {
            viewModel.copyToClipboard();
            toastService.showSuccess('Copiado para a área de transferência');
            viewModel.clearSelection();
          },
          onCompare: () {
            viewModel.onCompareVersions?.call();
          },
          onClose: () {
            viewModel.clearSelection();
          },
          onDeepUnderstanding: () async {
            final query = await DeepUnderstandingDialog.show(context);
            if (query != null && context.mounted) {
              context.read<DeepUnderstandingBloc>().add(
                    StartAnalysisForVersesEvent(
                      query,
                      widget.verses,
                      widget.bookId,
                      widget.chapterNumber,
                      versionId,
                    ),
                  );
              viewModel.clearSelection();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DeepUnderstandingPage()),
              );
            }
          },
        ),
      ],
    );
  }
}
