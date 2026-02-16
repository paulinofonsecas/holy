import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/bible_models.dart';
import '../rich_modal/widgets/image_creator_page.dart';

class RichVerseActionModal {
  static void show({
    required BuildContext context,
    required List<BibleVerse> verses,
    required String verseReference,
  }) {
    WoltModalSheet.show<void>(
      context: context,
      barrierDismissible: false,
      pageListBuilder: (modalSheetContext) {
        return [
          ImageCreatorPage.build(
            context: modalSheetContext,
            verses: verses,
            verseReference: verseReference,
          ),
        ];
      },
    );
  }
}
