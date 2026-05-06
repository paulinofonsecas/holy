import 'dart:async';
import 'dart:convert';

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
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/eu_sou/presentation/pages/eu_sou_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final GlobalKey keyBibleTab = GlobalKey();
  final GlobalKey keySearchTab = GlobalKey();
  final GlobalKey keyProfileTab = GlobalKey();
  final GlobalKey keyStudiesTab = GlobalKey();

  @override
  void initState() {
    super.initState();
    notificationHandler.addOnNotificationTapListener(_handleNotificationTap);

    _setupDeeplinks();
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

  List<Widget> _buildPages(BuildContext context) {
    return [
      const BibliaPage(),
      const EuSouPage(),
      const TelaBusca(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;
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
      child: BlocBuilder<TabControllerCubit, int>(
        builder: (context, currentIndex) {
          if (kIsWeb) {
            return Scaffold(
              body: Column(
                children: [
                  if (isWide) _buildWebTopBar(context, currentIndex),
                  Expanded(
                    child: _AnalysisBannerOverlay(
                      child: IndexedStack(
                        index: currentIndex,
                        children: _buildPages(context),
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
                          icon: Icon(CupertinoIcons.book,
                              key: keyBibleTab, size: 20),
                          title: l10n.bible,
                        ),
                        TabItem(
                          icon: Icon(CupertinoIcons.light_max,
                              key: keyProfileTab, size: 20),
                          title: 'Eu Sou',
                        ),
                        TabItem(
                          icon: Icon(CupertinoIcons.search,
                              key: keySearchTab, size: 20),
                          title: l10n.search,
                        ),
                      ],
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
                        icon: Icon(CupertinoIcons.book, key: keyBibleTab),
                        label: Text(l10n.bible),
                      ),
                      NavigationRailDestination(
                        icon:
                            Icon(CupertinoIcons.light_max, key: keyProfileTab),
                        label: const Text('Eu Sou'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(CupertinoIcons.search, key: keySearchTab),
                        label: Text(l10n.search),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: _AnalysisBannerOverlay(
                      child: IndexedStack(
                        index: currentIndex,
                        children: _buildPages(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: _AnalysisBannerOverlay(
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
                  icon: Icon(CupertinoIcons.book, key: keyBibleTab, size: 20),
                  title: l10n.bible,
                ),
                TabItem(
                  icon: Icon(CupertinoIcons.light_max,
                      key: keyProfileTab, size: 20),
                  title: 'Eu Sou',
                ),
                TabItem(
                  icon:
                      Icon(CupertinoIcons.search, key: keySearchTab, size: 20),
                  title: l10n.search,
                ),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          _buildWebTopBarItem(
            context,
            icon: CupertinoIcons.book,
            label: l10n.bible,
            selected: currentIndex == 0,
            onTap: () => context.read<TabControllerCubit>().changeTo(0),
          ),
          const SizedBox(width: 16),
          _buildWebTopBarItem(
            context,
            icon: CupertinoIcons.light_max,
            label: 'Eu Sou',
            selected: currentIndex == 1,
            onTap: () => context.read<TabControllerCubit>().changeTo(1),
          ),
          const SizedBox(width: 16),
          _buildWebTopBarItem(
            context,
            icon: CupertinoIcons.search,
            label: l10n.search,
            selected: currentIndex == 2,
            onTap: () => context.read<TabControllerCubit>().changeTo(2),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTopBarItem(
    BuildContext context, {
    required IconData icon,
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
            Icon(
              icon,
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

/// Overlay transparente que exibe o banner de progresso de análise
/// enquanto [DeepUnderstandingInProgress] estiver activo.
class _AnalysisBannerOverlay extends StatelessWidget {
  final Widget child;

  const _AnalysisBannerOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Positioned é filho directo do Stack — obrigatório
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
            builder: (context, state) {
              final inProgress = state is DeepUnderstandingInProgress;
              return AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                offset: inProgress ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: inProgress ? 1.0 : 0.0,
                  child: inProgress
                      ? _AnalysisBanner(
                          progress: state.progress,
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Banner premium de progresso — aparece na base do ecrã.
class _AnalysisBanner extends StatelessWidget {
  final double progress;

  const _AnalysisBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF1A1A2E).withOpacity(0.93),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Gerando entendimento: $pct%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.90),
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 3,
          backgroundColor: const Color(0xFF2D2D4E),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C8EFF)),
        ),
      ],
    );
  }
}
