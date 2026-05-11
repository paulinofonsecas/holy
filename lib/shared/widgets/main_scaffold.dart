import 'dart:async';
import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_bloc.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_event.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_state.dart';
import 'package:eu_sou/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:eu_sou/core/services/highlight_changed_notifier.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/download/presentation/widgets/download_progress_bar.dart';
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

    return Row(
      children: [
        Expanded(
          child: AnalysisBannerOverlay(
            child: IndexedStack(
              index: currentIndex,
              children: _buildPages(context, hideMarkedVersesFromMenu: true),
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        SizedBox(
          width: 400,
          child: BlocProvider.value(
            value: _sidebarMarkedVersesBloc!,
            child: const MarkedVersesListPage(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? colorScheme.surface : const Color(0xFFFCFBF8);

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
                        if (isWide) _buildWebTopBar(context, currentIndex),
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
                        : ConvexAppBar(
                            style: TabStyle.react,
                            backgroundColor: bgColor,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.6),
                            activeColor: context.colorScheme.primary,
                            initialActiveIndex: currentIndex,
                            onTap: (index) {
                              if (index == 0) {
                                if (currentIndex == 0) {
                                  SwitchBookModal.show(context);
                                  return;
                                }
                              }
                              context
                                  .read<TabControllerCubit>()
                                  .changeTo(index);
                            },
                            items: [
                              TabItem(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedBook01,
                                    key: keyBibleTab,
                                    size: 20),
                                title: l10n.bible,
                              ),
                              TabItem(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedSun01,
                                    key: keyProfileTab,
                                    size: 20),
                                title: 'Eu Sou',
                              ),
                              TabItem(
                                icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedSearch01,
                                    key: keySearchTab,
                                    size: 20),
                                title: l10n.search,
                              ),
                            ],
                          ),
                  ),
                );
              }

              if (isWide) {
                return Scaffold(
                  body: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: currentIndex,
                        onDestinationSelected: (index) {
                          context.read<TabControllerCubit>().changeTo(index);
                        },
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          NavigationRailDestination(
                            icon: AppHugeIcon(
                                icon: HugeIcons.strokeRoundedBook01,
                                key: keyBibleTab),
                            label: Text(l10n.bible),
                          ),
                          NavigationRailDestination(
                            icon: AppHugeIcon(
                                icon: HugeIcons.strokeRoundedSun01,
                                key: keyProfileTab),
                            label: const Text('Eu Sou'),
                          ),
                          NavigationRailDestination(
                            icon: AppHugeIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                key: keySearchTab),
                            label: Text(l10n.search),
                          ),
                        ],
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
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
                );
              }

              return Scaffold(
                body: AnalysisBannerOverlay(
                  child: IndexedStack(
                    index: currentIndex,
                    children: _buildPages(context),
                  ),
                ),
                bottomNavigationBar: ConvexAppBar(
                  style: TabStyle.react,
                  backgroundColor: bgColor,
                  color: context.colorScheme.onSurface.withOpacity(0.6),
                  activeColor: context.colorScheme.primary,
                  initialActiveIndex: currentIndex,
                  onTap: (index) {
                    if (index == 0) {
                      if (currentIndex == 0) {
                        SwitchBookModal.show(context);
                        return;
                      }
                    }
                    context.read<TabControllerCubit>().changeTo(index);
                  },
                  items: [
                    TabItem(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedBook01,
                          key: keyBibleTab,
                          size: 20),
                      title: l10n.bible,
                    ),
                    TabItem(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSun01,
                          key: keyProfileTab,
                          size: 20),
                      title: 'Eu Sou',
                    ),
                    TabItem(
                      icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          key: keySearchTab,
                          size: 20),
                      title: l10n.search,
                    ),
                  ],
                ),
              );
            },
          ),
          // Download overlay
          if (_isDownloading)
            Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppHugeIcon(
                          icon: HugeIcons.strokeRoundedBook01,
                          size: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Baixando a versão JFAA da biblioteca bíblica...',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_downloadProgress != null)
                          DownloadProgressBar(
                            progress: _downloadProgress!,
                            onRetry:
                                _downloadError ? _checkAndDownloadBible : null,
                          ),
                      ],
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
