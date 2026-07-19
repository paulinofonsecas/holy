import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/modals/reading_settings_modal.dart';
import 'package:eu_sou/features/biblia/widgets/versao_widget.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

/// A single labeled action for [BibleAppBar].
class BibleAppBarAction {
  const BibleAppBarAction({
    required this.child,
    required this.label,
    this.onTap,
  });
  final Widget child;
  final String label;
  final VoidCallback? onTap;
}

class BibleAppBar extends StatelessWidget {
  const BibleAppBar({
    super.key,
    this.onBookTap,
    this.actions,
  });

  final VoidCallback? onBookTap;
  final List<BibleAppBarAction>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFirst = ModalRoute.of(context)?.isFirst ?? true;
    final screenWidth = MediaQuery.of(context).size.width;
    final isUltraWide = screenWidth >= 1440;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isUltraWide ? 8 : 16,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          // ── Left: version / back ──────────────────────────────────────
          if (!isFirst)
            IconButton(
              icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
              onPressed: () => Navigator.pop(context),
            )
          else
            BlocBuilder<BibleVersionCubit, BibleVersionState>(
              builder: (context, versionState) {
                return _AppBarChip(
                  label: 'Versão',
                  onTap: () => VersaoWidget.showPicker(context),
                  child: Row(
                    key: keyBibleVersionTab,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        versionState.version.id,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Gap(2),
                      AppHugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        size: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                );
              },
            ),

          // ── Center: book / chapter ────────────────────────────────────
          Expanded(
            child: InkWell(
              onTap: onBookTap,
              borderRadius: BorderRadius.circular(8),
              child: _AppBarChip(
                label: 'Livro / Capítulo',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: BookSelectorWidget(onBookTap: onBookTap),
                  ),
                ),
              ),
            ),
          ),

          // ── Right: font settings ──────────────────────────────────────
          _AppBarChip(
            label: 'Fonte',
            onTap: () => ReadingSettingsModal.show(context),
            child: AppHugeIcon(
              icon: HugeIcons.strokeRoundedTextFont,
              size: 18,
              color: colorScheme.onSurface,
            ),
          ),

          // ── Individual labeled action chips ───────────────────────────
          if (actions != null)
            for (final action in actions!) ...[
              _AppBarChip(
                label: action.label,
                onTap: action.onTap,
                child: action.child,
              ),
            ],
        ],
      ),
    );
  }
}

// ── _AppBarChip ──────────────────────────────────────────────────────────────
/// Bordered chip with a label below, used for action buttons in the app bar.
class _AppBarChip extends StatelessWidget {
  const _AppBarChip({
    required this.label,
    required this.child,
    this.onTap,
  });
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outline.withValues(alpha: 0.35);
    final labelStyle = TextStyle(
      fontSize: 9,
      color: colorScheme.onSurface.withValues(alpha: 0.5),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: screenHeight * .06,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              if (label.isNotEmpty && screenWidth > 360) ...[
                const Gap(2),
                Text(label, style: labelStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BookSelectorWidget extends StatelessWidget {
  const BookSelectorWidget({
    super.key,
    required this.onBookTap,
  });

  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibliaBloc, BibliaState>(
      builder: (context, state) {
        if (state is BibleChapterLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    "${state.chapter.bookName}",
                    key: (ModalRoute.of(context)?.isFirst ?? true)
                        ? keyBibleContentTab
                        : null,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  " ${state.chapter.number}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  size: 16,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
