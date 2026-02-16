import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/core/services/share_service.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/rich_verse_action_modal.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
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
        icon: const Icon(Icons.close),
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

class ActionRowWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final highlightBloc = context.read<HighlightBloc>();
    final selectionBloc = context.read<VerseSelectionBloc>();
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    final normalizedVersionId = versionId.toUpperCase();
    final cacheProvider = context.read<BibleCacheProvider>();
    final logger = LoggerService();
    final verseNumbers = verses.map((verse) => verse.number).toList();

    final viewModel = RichModalViewModel(
      verses: verses,
      verseReference: verseReference,
      versionId: versionId,
      bookId: bookId,
      chapterNumber: chapterNumber,
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

    viewModel.onShareText = () {
      ShareService.shareVerses(
        verses: verses,
        bookName: bookId,
        chapterNumber: chapterNumber,
        versionId: versionId,
      );
    };

    viewModel.onCompareVersions = () {
      if (verseNumbers.isEmpty) {
        logger
            .warning('Compare versions requested without any verses selected');
        return;
      }

      final verseNumber = verseNumbers.reduce(
        (value, element) => value < element ? value : element,
      );

      viewModel.clearSelection();
      Navigator.of(context).pop();

      Future<void>(() async {
        final targetVersionIds = await resolveTargetVersionIds();
        final request = ComparisonRequest(
          bookId: bookId,
          chapterNumber: chapterNumber,
          verseNumber: verseNumber,
          sourceVersionId: normalizedVersionId,
          targetVersionIds: targetVersionIds,
        );

        if (!context.mounted) return;
        await CompareVersionsModal.show(
          context: context,
          request: request,
          verseReference: verseReference,
        );
      });
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
            RichVerseActionModal.show(
              context: context,
              verses: verses,
              verseReference: verseReference,
            );
          },
          onCopy: () {
            viewModel.clearSelection();
          },
          onCompare: () {
            viewModel.onCompareVersions?.call();
          },
        ),
      ],
    );
  }
}
