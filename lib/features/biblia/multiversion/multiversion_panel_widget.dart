import 'dart:async';

import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/design_system/theme/theme_colors.dart';
import 'package:eu_sou/core/design_system/theme/theme_data.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_cubit.dart';
import 'package:eu_sou/features/biblia/data/repositories/reading_settings_repository.dart';
import 'package:eu_sou/features/biblia/modals/reading_settings_modal.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_cubit.dart';
import 'package:eu_sou/features/biblia/presentation/pages/book_selection_page.dart';
import 'package:eu_sou/features/biblia/widgets/screen_reader_page.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

// ─── Highlight colour presets (same palette as ColorPickerModal) ─────────────

const _kHighlightSwatches = [
  _HighlightSwatch(Color(0xFFFFF176), 'FFFFF176'),
  _HighlightSwatch(Color(0xFFAED581), 'FFAED581'),
  _HighlightSwatch(Color(0xFF81D4FA), 'FF81D4FA'),
  _HighlightSwatch(Color(0xFFF48FB1), 'FFF48FB1'),
  _HighlightSwatch(Color(0xFFCE93D8), 'FFCE93D8'),
];

class _HighlightSwatch {
  const _HighlightSwatch(this.color, this.hex);
  final Color color;
  final String hex;
}

// ─── Public widget ────────────────────────────────────────────────────────────

/// A self-contained Bible reader panel with fully isolated BLoC instances and
/// its own accent colour theme.
class MultiversionPanelWidget extends StatefulWidget {
  const MultiversionPanelWidget({
    super.key,
    required this.panelId,
    this.panelColor,
    this.onClose,
    this.canClose = true,
    this.initialVersionId,
    this.initialBookId,
    this.initialChapter,
  });

  final String panelId;

  /// The panel's accent colour. Drives its [Theme]. Defaults to
  /// [AppThemeColors.defaultPrimaryColor] when null.
  final Color? panelColor;

  final VoidCallback? onClose;
  final bool canClose;
  final String? initialVersionId;
  final String? initialBookId;
  final int? initialChapter;

  @override
  State<MultiversionPanelWidget> createState() =>
      _MultiversionPanelWidgetState();
}

class _MultiversionPanelWidgetState extends State<MultiversionPanelWidget> {
  late final BibliaBloc _bibliaBloc;
  late final BibleVersionCubit _versionCubit;
  late final BookSelectionCubit _bookCubit;
  late final VerseSelectionBloc _selectionBloc;
  late final ReadingSettingsCubit _readingSettingsCubit;

  @override
  void initState() {
    super.initState();
    _versionCubit = BibleVersionCubit();
    _bookCubit = BookSelectionCubit();
    _selectionBloc = VerseSelectionBloc();
    _readingSettingsCubit =
        ReadingSettingsCubit(context.read<ReadingSettingsRepository>());
    _bibliaBloc = BibliaBloc(
      context.read<IBibleRepository>(),
      context.read<ScrollPersistenceService>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final versionId = widget.initialVersionId ??
          context.read<BibleVersionCubit>().state.version.id;
      final bookId = widget.initialBookId ?? BibleBooks.genesis.bookId;
      final chapter = widget.initialChapter ?? 1;

      if (widget.initialVersionId != null) {
        _versionCubit.changeVersionById(versionId);
      }
      _bibliaBloc.add(GetChapter(versionId, bookId, chapter.toString()));
    });
  }

  @override
  void dispose() {
    _bibliaBloc.close();
    _versionCubit.close();
    _bookCubit.close();
    _selectionBloc.close();
    _readingSettingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.panelColor ?? AppThemeColors.defaultPrimaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelThemeData = isDark
        ? AppThemeData.dark(effectiveColor)
        : AppThemeData.light(effectiveColor);

    return Theme(
      data: panelThemeData,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _bibliaBloc),
          BlocProvider.value(value: _versionCubit),
          BlocProvider.value(value: _bookCubit),
          BlocProvider.value(value: _selectionBloc),
          BlocProvider.value(value: _readingSettingsCubit),
        ],
        child: _PanelContent(
          panelId: widget.panelId,
          panelColor: effectiveColor,
          onClose: widget.onClose,
          canClose: widget.canClose,
        ),
      ),
    );
  }
}

class _PanelContent extends StatefulWidget {
  const _PanelContent({
    required this.panelId,
    required this.panelColor,
    this.onClose,
    this.canClose = true,
  });

  final String panelId;
  final Color panelColor;
  final VoidCallback? onClose;
  final bool canClose;

  @override
  State<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends State<_PanelContent> {
  Timer? _hideTimer;
  bool _showNavButtons = true;
  final FocusNode _panelFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _panelFocusNode.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showNavButtons) {
        setState(() => _showNavButtons = false);
      }
    });
  }

  void _navigateToPreviousChapter() {
    _startHideTimer();
    final state = context.read<BibliaBloc>().state;
    if (state is! BibleChapterLoaded) return;

    final chapter = state.chapter;
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    if (chapter.number > 1) {
      context.read<BibliaBloc>().add(GetChapter(
            versionId,
            chapter.bookId,
            (chapter.number - 1).toString(),
          ));
    } else {
      final idx =
          BibleBooks.values.indexWhere((b) => b.bookId == chapter.bookId);
      if (idx > 0) {
        final prevBook = BibleBooks.values[idx - 1];
        context.read<BibliaBloc>().add(GetChapter(
              versionId,
              prevBook.bookId,
              prevBook.chapterCount.toString(),
            ));
      }
    }
  }

  void _navigateToNextChapter() {
    _startHideTimer();
    final state = context.read<BibliaBloc>().state;
    if (state is! BibleChapterLoaded) return;

    final chapter = state.chapter;
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    if (chapter.number < chapter.totalChapters) {
      context.read<BibliaBloc>().add(GetChapter(
            versionId,
            chapter.bookId,
            (chapter.number + 1).toString(),
          ));
    } else {
      final idx =
          BibleBooks.values.indexWhere((b) => b.bookId == chapter.bookId);
      if (idx < BibleBooks.values.length - 1) {
        final nextBook = BibleBooks.values[idx + 1];
        context.read<BibliaBloc>().add(
              GetChapter(versionId, nextBook.bookId, '1'),
            );
      }
    }
  }

  void _openVersionPicker() {
    final bibleVersion = context.read<BibleVersionCubit>().state.version;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    // Capture the blocs so they are accessible in the sheet
    final versionCubit = context.read<BibleVersionCubit>();
    final bibliaBloc = context.read<BibliaBloc>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: bgColor,
      useSafeArea: true,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: versionCubit),
            BlocProvider.value(value: bibliaBloc),
          ],
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Escolha uma versão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    ...BibleVersions.values.map((e) {
                      final isSelected = bibleVersion.id == e.id;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          onTap: () {
                            versionCubit.changeVersion(e);
                            // Reload current chapter in the new version
                            final current = bibliaBloc.state;
                            if (current is BibleChapterLoaded) {
                              bibliaBloc.add(GetChapter(
                                e.id,
                                current.chapter.bookId,
                                current.chapter.number.toString(),
                              ));
                            } else {
                              bibliaBloc.add(GetChapter(
                                e.id,
                                BibleBooks.genesis.bookId,
                                '1',
                              ));
                            }
                            Navigator.pop(sheetContext);
                          },
                          title: Text('${e.id} - ${e.name}'),
                          trailing: isSelected
                              ? AppHugeIcon(
                                  icon:
                                      HugeIcons.strokeRoundedCheckmarkCircle01,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : FutureBuilder<bool>(
                                  future: context
                                      .read<BibleCacheProvider>()
                                      .isVersionCached(e.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == true) {
                                      return const AppHugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedCheckmarkCircle01,
                                        size: 20,
                                      );
                                    }
                                    return const AppHugeIcon(
                                        icon: HugeIcons.strokeRoundedDownload01,
                                        size: 20);
                                  },
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openBookSelection() {
    final selectionCubit = context.read<BookSelectionCubit>();
    final currentBookId = selectionCubit.state.bookId;
    if (currentBookId.isNotEmpty) {
      selectionCubit.setBookExpanded(currentBookId, true);
    }

    // Calculate scroll offset toward the current book
    double targetOffset = 0.0;
    if (currentBookId.isNotEmpty) {
      final index =
          BibleBooks.values.indexWhere((b) => b.bookId == currentBookId);
      if (index != -1) {
        const itemHeight = 58.0;
        const headerHeight = 56.0;
        targetOffset = index * itemHeight + headerHeight;
        if (index >= 39) targetOffset += headerHeight;
        targetOffset = (targetOffset - 150.0).clamp(0.0, double.infinity);
      }
    }

    final scrollController =
        ScrollController(initialScrollOffset: targetOffset);
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        selectionCubit.updateScrollOffset(scrollController.offset);
      }
    });

    // Capture blocs before navigating
    final bibliaBloc = context.read<BibliaBloc>();
    final versionCubit = context.read<BibleVersionCubit>();
    final bookCubit = context.read<BookSelectionCubit>();
    final highlightBloc = context.read<HighlightBloc>();
    final selectionBloc = context.read<VerseSelectionBloc>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 768;

    if (isWideScreen) {
      final size = MediaQuery.of(context).size;
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bibliaBloc),
              BlocProvider.value(value: versionCubit),
              BlocProvider.value(value: bookCubit),
              BlocProvider.value(value: highlightBloc),
              BlocProvider.value(value: selectionBloc),
            ],
            child: Dialog(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: size.width * 0.30,
                height: size.height * 0.80,
                child: BookSelectionPage(scrollController: scrollController),
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (routeContext, animation, secondaryAnimation) =>
              MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bibliaBloc),
              BlocProvider.value(value: versionCubit),
              BlocProvider.value(value: bookCubit),
              BlocProvider.value(value: highlightBloc),
              BlocProvider.value(value: selectionBloc),
            ],
            child: BookSelectionPage(scrollController: scrollController),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          fullscreenDialog: true,
        ),
      );
    }
  }

  // ── Panel colour picker ─────────────────────────────────────────────────────

  void _openColorPicker() {
    final multiversionCubit = context.read<MultiversionCubit>();
    final currentColor = widget.panelColor;
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cor do painel',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cada painel tem seu próprio tema visual.',
                  style: textTheme.bodySmall?.copyWith(
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppThemeColors.predefinedColors.map((color) {
                    final isSelected = color == currentColor;
                    return GestureDetector(
                      onTap: () {
                        multiversionCubit.changePanelColor(
                            widget.panelId, color);
                        Navigator.pop(sheetContext);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(
                                  alpha: isSelected ? 0.55 : 0.2),
                              blurRadius: isSelected ? 10 : 4,
                              spreadRadius: isSelected ? 1 : 0,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Reading settings (font, background, etc.) ──────────────────────────────

  void _openReadingSettings() {
    ReadingSettingsModal.show(context);
  }

  // ── Scroll notification helper ──────────────────────────────────────────────

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _hideTimer?.cancel();
      if (_showNavButtons) setState(() => _showNavButtons = false);
    } else if (notification is ScrollEndNotification) {
      if (!_showNavButtons) setState(() => _showNavButtons = true);
      _startHideTimer();
    }
    return false;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _PanelHeader(
                panelColor: widget.panelColor,
                onVersionTap: _openVersionPicker,
                onBookTap: _openBookSelection,
                onColorTap: _openColorPicker,
                onSettingsTap: _openReadingSettings,
                onClose: widget.canClose ? widget.onClose : null,
              ),
              const Divider(height: 1),

              // ── Verse reader + resizable right panel + floating menu ────────
              Expanded(
                child: BlocBuilder<VerseSelectionBloc, VerseSelectionState>(
                  builder: (context, selState) {
                    return Stack(
                      children: [
                        // Row: verse reader + optional resizable right panel
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Main verse reader
                              Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: _onScrollNotification,
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            _panelFocusNode.requestFocus(),
                                        onHorizontalDragEnd: (details) {
                                          if (details.primaryVelocity! > 0) {
                                            _navigateToPreviousChapter();
                                          } else if (details.primaryVelocity! <
                                              0) {
                                            _navigateToNextChapter();
                                          }
                                        },
                                        child: MouseRegion(
                                          onEnter: (_) =>
                                              _panelFocusNode.requestFocus(),
                                          child: ScreenReaderPage(
                                            focusNode: _panelFocusNode,
                                          ),
                                        ),
                                      ),
                                      // ← prev-chapter button
                                      Positioned(
                                        left: 4,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            opacity:
                                                _showNavButtons ? 1.0 : 0.0,
                                            child: IgnorePointer(
                                              ignoring: !_showNavButtons,
                                              child: _ChapterNavButton(
                                                isNext: false,
                                                onTap:
                                                    _navigateToPreviousChapter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // → next-chapter button
                                      Positioned(
                                        right: 4,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            opacity:
                                                _showNavButtons ? 1.0 : 0.0,
                                            child: IgnorePointer(
                                              ignoring: !_showNavButtons,
                                              child: _ChapterNavButton(
                                                isNext: true,
                                                onTap: _navigateToNextChapter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floating highlight menu — 20 px above the bottom edge,
                        // centered, inset 16 px on each side, scrollable if needed.
                        if (selState.isInSelectionMode)
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: _FloatingHighlightMenu(
                              selectedVerses:
                                  selState.selectedVerses.values.toList(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Panel header ─────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.onVersionTap,
    required this.onBookTap,
    required this.onColorTap,
    required this.onSettingsTap,
    this.panelColor,
    this.onClose,
  });

  final VoidCallback onVersionTap;
  final VoidCallback onBookTap;

  /// Opens the panel colour picker.
  final VoidCallback onColorTap;

  /// Opens the reading settings modal (font, background, etc.).
  final VoidCallback onSettingsTap;

  /// Current accent colour shown as a small indicator dot.
  final Color? panelColor;

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Tema (colour dot) ────────────────────────────────────────────
          _HeaderChip(
            label: 'Tema',
            onTap: onColorTap,
            tooltip: 'Mudar cor do painel',
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: panelColor ?? colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (panelColor ?? colorScheme.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          const Gap(6),

          // ── Fonte / Fundo ────────────────────────────────────────────────
          _HeaderChip(
            label: 'Fonte',
            onTap: onSettingsTap,
            tooltip: 'Configurações de leitura',
            child: AppHugeIcon(
              icon: HugeIcons.strokeRoundedTextFont,
              size: 14,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const Gap(6),

          // ── Versão ───────────────────────────────────────────────────────
          BlocBuilder<BibleVersionCubit, BibleVersionState>(
            builder: (context, versionState) {
              return _HeaderChip(
                label: 'Versão',
                onTap: onVersionTap,
                child: Text(
                  versionState.version.id,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
          const Gap(6),

          // ── Livro / Capítulo ─────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<BibliaBloc, BibliaState>(
              builder: (context, state) {
                String bookLabel = '...';
                if (state is BibleChapterLoaded) {
                  final bookName = BibleBooks.values
                      .firstWhere(
                        (b) => b.bookId == state.chapter.bookId,
                        orElse: () => BibleBooks.genesis,
                      )
                      .book;
                  bookLabel = '$bookName ${state.chapter.number}';
                }
                return _HeaderChip(
                  label: 'Livro / Capítulo',
                  onTap: onBookTap,
                  expand: true,
                  child: Text(
                    bookLabel,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Close ────────────────────────────────────────────────────────
          if (onClose != null) ...[
            const Gap(4),
            IconButton(
              icon: AppHugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onClose,
              tooltip: 'Fechar painel',
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Header chip ─────────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.child,
    required this.onTap,
    this.tooltip,
    this.expand = false,
  });

  final String label;
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outline.withValues(alpha: 0.35);
    final labelStyle = TextStyle(
      fontSize: 9,
      color: colorScheme.onSurface.withValues(alpha: 0.5),
    );

    Widget chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              const Gap(2),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      chip = Tooltip(message: tooltip!, child: chip);
    }

    if (expand) {
      return chip;
    }
    return chip;
  }
}

// ─── Floating highlight menu ──────────────────────────────────────────────────

/// A pill-shaped floating bar anchored 20 px above the bottom of the panel.
/// It is inset 16 px on each side and scrolls horizontally when its content
/// would otherwise overflow.
class _FloatingHighlightMenu extends StatelessWidget {
  const _FloatingHighlightMenu({required this.selectedVerses});

  final List<BibleVerse> selectedVerses;

  void _applyHighlight(BuildContext context, String colorHex) {
    final bibliaState = context.read<BibliaBloc>().state;
    if (bibliaState is! BibleChapterLoaded) return;
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    for (final verse in selectedVerses) {
      context.read<HighlightBloc>().add(AddHighlight(
            verseRef:
                '$versionId:${bibliaState.chapter.bookId}:${bibliaState.chapter.number}:${verse.number}',
            colorHex: colorHex,
          ));
    }
    context.read<VerseSelectionBloc>().add(ClearSelection());
  }

  void _removeHighlight(BuildContext context) {
    final bibliaState = context.read<BibliaBloc>().state;
    if (bibliaState is! BibleChapterLoaded) return;
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    for (final verse in selectedVerses) {
      context.read<HighlightBloc>().add(RemoveHighlight(
            verseRef:
                '$versionId:${bibliaState.chapter.bookId}:${bibliaState.chapter.number}:${verse.number}',
          ));
    }
    context.read<VerseSelectionBloc>().add(ClearSelection());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final sortedNumbers = selectedVerses.map((v) => v.number).toList()..sort();
    final label = sortedNumbers.length == 1
        ? 'v.\u00a0${sortedNumbers.first}'
        : 'v.\u00a0${sortedNumbers.first}–${sortedNumbers.last}';

    return Center(
      child: Material(
        elevation: 6,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        shape: const StadiumBorder(),
        color: colorScheme.surfaceContainerHigh,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Verse reference label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(width: 10),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 10),

                // Highlight colour swatches
                for (final swatch in _kHighlightSwatches)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _applyHighlight(context, swatch.hex),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: swatch.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: swatch.color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),

                // Remove highlight
                Tooltip(
                  message: 'Remover destaque',
                  child: InkWell(
                    onTap: () => _removeHighlight(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AppHugeIcon(
                        icon: HugeIcons.strokeRoundedMinusSignCircle,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Clear selection
                Tooltip(
                  message: 'Limpar seleção',
                  child: InkWell(
                    onTap: () => context
                        .read<VerseSelectionBloc>()
                        .add(ClearSelection()),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AppHugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chapter navigation button ────────────────────────────────────────────────

class _ChapterNavButton extends StatelessWidget {
  const _ChapterNavButton({
    required this.isNext,
    required this.onTap,
  });

  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isNext ? Icons.chevron_right : Icons.chevron_left,
          color: colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
    );
  }
}
