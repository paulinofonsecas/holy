import 'package:flutter/material.dart';
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            HighlightRow(
              onColorSelected: (color) {
                viewModel.applyHighlight(color);
                // Optionally close or stay
              },
              onRemoveHighlight: () {
                viewModel.removeHighlight();
              },
            ),
            const Divider(height: 32),
            ActionRow(
              onShare: () {
                if (viewModel.onShareText != null) {
                  viewModel.onShareText!();
                }
                Navigator.of(context).pop();
              },
              onCreateImage: goToImageCreator,
              onCopy: () {
                // TODO: Implement copy logic
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
