import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../core/services/share_service.dart';
import '../../../../shared/bible_models.dart';
import '../../../../shared/cubit/bible_version_cubit.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/selection_bloc.dart';
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

    final viewModel = RichModalViewModel(
      verses: verses,
      verseReference: verseReference,
      versionId: versionId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      highlightBloc: highlightBloc,
      selectionBloc: selectionBloc,
    );

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
