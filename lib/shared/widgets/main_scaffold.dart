import 'dart:async';
import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_bloc.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_event.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_state.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:eu_sou/core/services/highlight_changed_notifier.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/download/utils/formatters.dart';
import 'package:eu_sou/features/eu_sou/presentation/pages/eu_sou_page.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/marked_verses_bloc.dart';
import 'package:eu_sou/features/profile/presentation/pages/marked_verses_list_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis_banner_overlay.dart';

class MainScaffold extends StatefulWidget {
  final FeedbackService? feedbackService;
  final bool showTutorialOnStart;
  final Uri? initialDeepLink;

  const MainScaffold({
    super.key,
    this.feedbackService,
    this.showTutorialOnStart = false,
    this.initialDeepLink,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TutorialMixin {
  StreamSubscription<Uri?>? _deeplinkSubscription;
  bool _tutorialStarted = false;
  bool _isDownloading = false;
  DownloadProgress? _downloadProgress;
  bool _downloadError = false;

  // Bloc para a sidebar de versículos marcados (criado uma vez)
  MarkedVersesBloc? _sidebarMarkedVersesBloc;
  bool _sidebarCollapsed = false;

  final GlobalKey keyBibleTab = GlobalKey();
  final GlobalKey keySearchTab = GlobalKey();
  final GlobalKey keyProfileTab = GlobalKey();
  final GlobalKey keyStudiesTab = GlobalKey();

  @override
  void initState() {
    super.initState();
    notificationHandler.addOnNotificationTapListener(_handleNotificationTap);

    _setupDeeplinks();
    _checkAndDownloadBible();
  }

  Future<void> _checkAndDownloadBible() async {
    const versionId = 'JFAA';
    final cacheProvider = context.read<BibleCacheProvider>();
    final webCachePersistence = context.read<WebCachePersistenceService>();

    try {
      // Check if Bible is cached
      bool isCached = false;

      if (kIsWeb) {
        isCached = await webCachePersistence.isVersionCachedAndValid(versionId);
      } else {
        isCached = await cacheProvider.isVersionCached(versionId);
      }

      if (!isCached && mounted) {
        // Start download
        setState(() {
          _isDownloading = true;
        });

        await loadBibleFromUrl(
          versionId,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _downloadProgress = progress;
              });
            }
          },
          cacheProvider: cacheProvider,
        );

        // Mark as cached
        if (kIsWeb) {
          await webCachePersistence.markVersionCached(versionId);
        }

        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadProgress = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error downloading Bible: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadError = true;
          _downloadProgress = DownloadProgress.error(e.toString());
        });
      }
    }
  }

  void _setupDeeplinks() {
    final deeplinkService = context.read<IDeeplinkService>();
    final deeplinkBloc = context.read<DeeplinkBloc>();

    // Handle initial link if provided
    if (widget.initialDeepLink != null) {
      deeplinkBloc.add(HandleDeeplink(widget.initialDeepLink!));
    }

    // Listen for foreground links
    _deeplinkSubscription = deeplinkService.onLink.listen((Uri? uri) {
      if (uri != null) {
        deeplinkBloc.add(HandleDeeplink(uri));
      }
    });
  }

  void _handleDeepLinkData(Map<String, String> data) {
    final bookId = data['bookId'];
    final chapter = data['chapter'];
    final verse = data['verse'];

    if (bookId != null && chapter != null) {
      if (mounted) {
        // Reset navigation stack to ensure we're at the root of the app
        Navigator.popUntil(context, (route) => route.isFirst);

        // Switch to Bible tab
        context.read<TabControllerCubit>().changeTo(0);

        // Get the current version ID or a default
        final versionId = context.read<BibleVersionCubit>().state.version.id;

        // Load the verse
        context.read<BibliaBloc>().add(GetChapter(
              versionId,
              bookId,
              chapter,
              verse: verse != null ? int.tryParse(verse) : null,
            ));
      }
    }
  }

  Future<void> _startTutorial() async {
    showTutorial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tutorialShownKey, true);
  }

  @override
  void dispose() {
    _deeplinkSubscription?.cancel();
    _sidebarMarkedVersesBloc?.close();
    notificationHandler.removeOnNotificationTapListener(_handleNotificationTap);
    super.dispose();
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    if (payload.startsWith('deep_understanding:')) {
      return;
    }

    try {
      final data = jsonDecode(payload);
      if (data['type'] == 'verse_of_the_day') {
        final versionId = data['versionId'] as String;
        final bookId = data['bookId'] as String;
        final chapter = data['chapter'].toString();
        final verse = data['verse'].toString();

        // Switch to Bible tab
        if (mounted) {
          // Reset navigation stack to ensure we're at the root of the app
          Navigator.popUntil(context, (route) => route.isFirst);

          context.read<TabControllerCubit>().changeTo(0);

          // Load the verse
          context.read<BibliaBloc>().add(GetChapter(
                versionId,
                bookId,
                chapter,
                verse: int.parse(verse),
              ));
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  List<Widget> _buildPages(BuildContext context,
      {bool hideMarkedVersesFromMenu = false}) {
    return [
      const BibliaPage(),
      EuSouPage(hideMarkedVersesFromMenu: hideMarkedVersesFromMenu),
      const TelaBusca(),
    ];
  }

  Widget _buildThreeColumnLayout(BuildContext context, int currentIndex) {
    // Criar o bloc uma vez e reutilizar
    _sidebarMarkedVersesBloc ??= MarkedVersesBloc(
      context.read<IMarkedVersesRepository>(),
      highlightChangedNotifier: context.read<HighlightChangedNotifier>(),
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: AnalysisBannerOverlay(
            child: IndexedStack(
              index: currentIndex,
              children: _buildPages(context,
                  hideMarkedVersesFromMenu: !_sidebarCollapsed),
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        if (_sidebarCollapsed)
          _buildCollapsedSidebarTab(context, colorScheme)
        else
          SizedBox(
            width: 400,
            child: BlocProvider.value(
              value: _sidebarMarkedVersesBloc!,
              child: MarkedVersesListPage(
                onCollapse: () => setState(() => _sidebarCollapsed = true),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedSidebarTab(
      BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _sidebarCollapsed = false),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppHugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark02,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                AppHugeIcon(
                  icon: HugeIcons.strokeRoundedSidebarLeft,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final isExtraWide = screenWidth > 1345;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return MultiBlocListener(
      listeners: [
        BlocListener<BibliaBloc, BibliaState>(
          listener: (context, state) {
            if (state is BibleChapterLoaded &&
                widget.showTutorialOnStart &&
                !_tutorialStarted) {
              _tutorialStarted = true;
              _startTutorial();
            }
          },
        ),
        BlocListener<TabControllerCubit, int>(
          listener: (context, currentIndex) {
            if (currentIndex == 0) {
              context.read<BibliaBloc>().add(ForceScrollRestoration());
            } else if (currentIndex == 1) {
              context.read<SearchBloc>().add(ForcarRestauracaoScrollBusca());
            }
          },
        ),
        BlocListener<DeeplinkBloc, DeeplinkState>(
          listener: (context, state) {
            if (state is DeeplinkNavigating) {
              _handleDeepLinkData(state.data);
            }
          },
        ),
      ],
      child: Stack(
        children: [
          BlocBuilder<TabControllerCubit, int>(
            builder: (context, currentIndex) {
              if (kIsWeb) {
                return SafeArea(
                  child: Scaffold(
                    body: Column(
                      children: [
                        // Always keep this slot so Expanded stays at index 1,
                        // preventing Flutter from deactivating/recreating the
                        // IndexedStack element when the top bar appears/disappears.
                        if (isWide)
                          _buildWebTopBar(context, currentIndex)
                        else
                          const SizedBox.shrink(),
                        Expanded(
                          child: isExtraWide
                              ? _buildThreeColumnLayout(context, currentIndex)
                              : AnalysisBannerOverlay(
                                  child: IndexedStack(
                                    index: currentIndex,
                                    children: _buildPages(context,
                                        hideMarkedVersesFromMenu: isExtraWide),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    bottomNavigationBar: isWide
                        ? null
                        : NavigationBar(
                            selectedIndex: currentIndex,
                            backgroundColor: bgColor,
                            onDestinationSelected: (index) {
                              if (index == 0 && currentIndex == 0) {
                                SwitchBookModal.show(context);
                                return;
                              }
                              context
                                  .read<TabControllerCubit>()
                                  .changeTo(index);
                            },
                            destinations: [
                              NavigationDestination(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedBook01,
                                    key: keyBibleTab,
                                    size: 20),
                                label: l10n.bible,
                              ),
                              NavigationDestination(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedSun01,
                                    key: keyProfileTab,
                                    size: 20),
                                label: 'Eu Sou',
                              ),
                              NavigationDestination(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedSearch01,
                                    key: keySearchTab,
                                    size: 20),
                                label: l10n.search,
                              ),
                            ],
                          ),
                  ),
                );
              }

              if (isWide) {
                return SafeArea(
                  child: Scaffold(
                    body: Column(
                      children: [
                        _buildWebTopBar(context, currentIndex),
                        Expanded(
                          child: isExtraWide
                              ? _buildThreeColumnLayout(context, currentIndex)
                              : AnalysisBannerOverlay(
                                  child: IndexedStack(
                                    index: currentIndex,
                                    children: _buildPages(context,
                                        hideMarkedVersesFromMenu: isExtraWide),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Scaffold(
                body: AnalysisBannerOverlay(
                  child: IndexedStack(
                    index: currentIndex,
                    children: _buildPages(context),
                  ),
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: currentIndex,
                  backgroundColor: bgColor,
                  onDestinationSelected: (index) {
                    if (index == 0 && currentIndex == 0) {
                      SwitchBookModal.show(context);
                      return;
                    }
                    context.read<TabControllerCubit>().changeTo(index);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedBook01,
                          key: keyBibleTab,
                          size: 20),
                      label: l10n.bible,
                    ),
                    NavigationDestination(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSun01,
                          key: keyProfileTab,
                          size: 20),
                      label: 'Eu Sou',
                    ),
                    NavigationDestination(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          key: keySearchTab,
                          size: 20),
                      label: l10n.search,
                    ),
                  ],
                ),
              );
            },
          ),
          // Download floating card (non-blocking)
          if (_isDownloading)
            Positioned(
              left: 16,
              bottom: 16,
              child: SafeArea(
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    width: 200,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppHugeIcon(
                                  icon: HugeIcons.strokeRoundedBook01,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Baixando JFAA...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_downloadProgress != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: _downloadProgress!.percent > 0
                                            ? _downloadProgress!.percent
                                            : null,
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '${(_downloadProgress!.percent * 100).toStringAsFixed(0)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const Spacer(),
                                        Flexible(
                                          child: Text(
                                            DownloadFormatters
                                                .formatProgressText(
                                              _downloadProgress!
                                                  .downloadedBytes,
                                              _downloadProgress!.totalBytes,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_downloadError)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _checkAndDownloadBible,
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(40, 24),
                                          ),
                                          child: const Text('Tentar'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebTopBar(BuildContext context, int currentIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.read<TabControllerCubit>().changeTo(1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildWebTopBarItem(
                context,
                icon: HugeIcons.strokeRoundedBook01,
                label: l10n.bible,
                selected: currentIndex == 0,
                onTap: () => context.read<TabControllerCubit>().changeTo(0),
              ),
              const SizedBox(width: 16),
              _buildWebTopBarItem(
                context,
                icon: HugeIcons.strokeRoundedSun01,
                label: 'Eu Sou',
                selected: currentIndex == 1,
                onTap: () => context.read<TabControllerCubit>().changeTo(1),
              ),
              const SizedBox(width: 16),
              _buildWebTopBarItem(
                context,
                icon: HugeIcons.strokeRoundedSearch01,
                label: l10n.search,
                selected: currentIndex == 2,
                onTap: () => context.read<TabControllerCubit>().changeTo(2),
              ),
            ],
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildWebTopBarItem(
    BuildContext context, {
    required AppIconAsset icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withOpacity(0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AppHugeIcon(
              icon: icon,
              size: 18,
              color: selected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
