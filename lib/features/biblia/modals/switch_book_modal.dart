import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/modals/modalpages/list_bible_books_modalpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SwitchBookModal {
  static void show(BuildContext context) {
    final selectionCubit = context.read<BookSelectionCubit>();
    final initialOffset = selectionCubit.state.scrollOffset;
    final scrollController =
        ScrollController(initialScrollOffset: initialOffset);

    void scrollListener() {
      if (scrollController.hasClients) {
        selectionCubit.updateScrollOffset(scrollController.offset);
      }
    }

    scrollController.addListener(scrollListener);

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          listBibleBooksModalPage(
            modalSheetContext,
            context,
            scrollController: scrollController,
          ),
        ];
      },
      onModalDismissedWithBarrierTap: () {
        debugPrint('Closed modal sheet with barrier tap');
        Navigator.of(context).pop();
      },
    );
  }
}
