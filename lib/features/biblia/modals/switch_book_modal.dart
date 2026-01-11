import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/modals/modalpages/list_bible_books_modalpage.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SwitchBookModal {
  static void show(BuildContext context) {
    final selectionCubit = context.read<BookSelectionCubit>();

    // Auto-expand current book when opening modal
    final currentBookId = selectionCubit.state.bookId;
    if (currentBookId.isNotEmpty) {
      selectionCubit.setBookExpanded(currentBookId, true);
    }

    // Calculate offset for current book to show it "de primeira"
    double targetOffset = 0.0;
    if (currentBookId.isNotEmpty) {
      final index =
          BibleBooks.values.indexWhere((b) => b.bookId == currentBookId);
      if (index != -1) {
        // Precise calculation:
        // Item height is roughly 58px.
        // Headers are Gap(32) + Text(~24) = 56px.
        const itemHeight = 58.0;
        const headerHeight = 56.0;

        targetOffset = index * itemHeight;

        // "Antigo Testamento" header is always above index 0
        targetOffset += headerHeight;

        // "Novo Testamento" header is above index 39 (Matthew)
        if (index >= 39) {
          targetOffset += headerHeight;
        }

        // Center the book a bit in the viewport for better visibility
        targetOffset = (targetOffset - 150.0).clamp(0.0, double.infinity);
      }
    } else {
      targetOffset = selectionCubit.state.scrollOffset;
    }

    final scrollController =
        ScrollController(initialScrollOffset: targetOffset);

    void scrollListener() {
      if (scrollController.hasClients) {
        selectionCubit.updateScrollOffset(scrollController.offset);
      }
    }

    scrollController.addListener(scrollListener);

    // Ensure we scroll to the current book after the modal is built
    // Using a delay to allow the modal animation and sliver tree to stabilize
    if (currentBookId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }

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
