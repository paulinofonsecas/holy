import 'dart:convert';

import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/marked_verses_bloc.dart';
import 'package:eu_sou/features/profile/presentation/pages/profile_page.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScaffold extends StatefulWidget {
  final FeedbackService? feedbackService;

  const MainScaffold({
    super.key,
    this.feedbackService,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TutorialMixin {
  @override
  final GlobalKey keyBibleTab = GlobalKey();
  @override
  final GlobalKey keySearchTab = GlobalKey();
  @override
  final GlobalKey keyProfileTab = GlobalKey();

  @override
  void initState() {
    super.initState();
    notificationHandler.addOnNotificationTapListener(_handleNotificationTap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTutorial();
    });
  }

  Future<void> _checkFirstTimeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool shown = prefs.getBool('tutorial_shown1') ?? false;
    if (!shown) {
      showTutorial();
      await prefs.setBool('tutorial_shown', true);
    }
  }

  @override
  void dispose() {
    notificationHandler.removeOnNotificationTapListener(_handleNotificationTap);
    super.dispose();
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

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
      const TelaBusca(),
      BlocProvider(
        create: (context) => MarkedVersesBloc(
          context.read<IMarkedVersesRepository>(),
        ),
        child: ProfilePage(
          feedbackService: widget.feedbackService,
          onShowTutorial: () {
            context.read<TabControllerCubit>().goToBible();
            showTutorial();
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    return BlocBuilder<TabControllerCubit, int>(
      builder: (context, currentIndex) {
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
                      icon: Icon(Icons.book, key: keyBibleTab),
                      label: Text(l10n.bible),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search, key: keySearchTab),
                      label: Text(l10n.search),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person, key: keyProfileTab),
                      label: Text(l10n.profile),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: _buildPages(context),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _buildPages(context),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<TabControllerCubit>().changeTo(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.book, key: keyBibleTab),
                label: l10n.bible,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, key: keySearchTab),
                label: l10n.search,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, key: keyProfileTab),
                label: l10n.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}
