import 'package:eu_sou/features/biblia/modals/modalpages/list_bible_books_modalpage.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SwitchBookModal {
  static show(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          listBibleBooksModalPage(modalSheetContext, context),
        ];
      },
      onModalDismissedWithBarrierTap: () {
        debugPrint('Closed modal sheet with barrier tap');
        Navigator.of(context).pop();
      },
    );
  }
}
