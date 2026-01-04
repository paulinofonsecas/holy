import 'dart:convert';

import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/views/biblia_view.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/marked_verses_bloc.dart';
import 'package:eu_sou/features/profile/presentation/pages/profile_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScaffold extends StatefulWidget {
  final FeedbackService? feedbackService;

  const MainScaffold({
    super.key,
    this.feedbackService,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    notificationHandler.addOnNotificationTapListener(_handleNotificationTap);
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
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    return [
      const BibliaPage(),
      BlocProvider(
        create: (context) => context.read<SearchBloc>()
          ..add(CarregarVersao(
            idVersao: versionId,
          )),
        child: const TelaBusca(),
      ),
      BlocProvider(
        create: (context) => MarkedVersesBloc(
          context.read<IMarkedVersesRepository>(),
        ),
        child: ProfilePage(feedbackService: widget.feedbackService),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TabControllerCubit, int>(
      builder: (context, currentIndex) {
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
                icon: const Icon(Icons.book),
                label: l10n.bible,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: l10n.search,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: l10n.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}
