import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../shared/bible_models.dart';
import '../../../../shared/cubit/bible_version_cubit.dart';
import '../../domain/models/comparison_request.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/selection_bloc.dart';
import '../compare_versions/compare_versions_modal.dart';
import '../rich_modal/rich_modal_viewmodel.dart';
import '../rich_modal/widgets/image_creator_page.dart';
import '../rich_modal/widgets/verse_actions_page.dart';

class RichVerseActionModal {
  static void show({
    required BuildContext context,
    required List<BibleVerse> verses,
    required String verseReference,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) {
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

    final pageIndexNotifier = ValueNotifier(0);

    WoltModalSheet.show<void>(
      context: context,
      pageIndexNotifier: pageIndexNotifier,
      pageListBuilder: (modalSheetContext) {
        return [
          VerseActionsPage.build(
            context: modalSheetContext,
            viewModel: viewModel,
            goToImageCreator: () {
              pageIndexNotifier.value = 1;
            },
          ),
          ImageCreatorPage.build(
            context: modalSheetContext,
            verses: verses,
            verseReference: verseReference,
          ),
        ];
      },
    );

    // Override the onShareText method to actually share
    viewModel.onShareText = () {
      ShareService.shareVerses(
        verses: verses,
        bookName: bookName,
        chapterNumber: chapterNumber,
        versionId: versionId,
      );
    };
  }
}
