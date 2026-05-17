import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/app/app.dart';
import 'package:eu_sou/core/data/provider/github_bible_provider.dart';
import 'package:eu_sou/core/data/provider/interfaces/i_bible_provider.dart';
import 'package:eu_sou/core/data/repositories/bible_repository.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/highlight_changed_notifier.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/biblia/data/repositories/reading_settings_repository.dart';
import 'package:eu_sou/features/biblia/data/repositories/multiversion_session_repository.dart';
import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/eu_sou/presentation/bloc/eu_sou_bloc.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:eu_sou/features/profile/data/repositories/marked_verses_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/profile_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/search_history_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/verse_history_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_search_history_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_verse_history_repository.dart';
import 'package:eu_sou/features/search/data/repositories/search_repository.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/features/verse_interaction/data/repositories/highlight_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class EntryPoint extends StatelessWidget {
  final Database db;
  final SqlBibleSearchProvider searchProvider;
  final BibleCacheProvider cacheProvider;
  final SharedPreferences sharedPreferences;
  final VerseOfTheDayRepository verseRepo;
  final VerseOfTheDayService verseService;
  final ProfileRepository profileRepo;
  final ThemeBloc themeBloc;
  final IDeeplinkService deeplinkService;
  final DeepUnderstandingService deepUnderstandingService;
  final EuSouRepository euSouRepository;
  final DailyContentService dailyContentService;
  final StreakService streakService;
  final DailyReminderService dailyReminderService;
  final WebCachePersistenceService webCachePersistenceService;

  const EntryPoint({
    super.key,
    required this.db,
    required this.searchProvider,
    required this.cacheProvider,
    required this.sharedPreferences,
    required this.verseRepo,
    required this.verseService,
    required this.profileRepo,
    required this.themeBloc,
    required this.deeplinkService,
    required this.deepUnderstandingService,
    required this.euSouRepository,
    required this.dailyContentService,
    required this.streakService,
    required this.dailyReminderService,
    required this.webCachePersistenceService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => Dio(),
        ),
        RepositoryProvider(
          create: (context) => cacheProvider,
        ),
        RepositoryProvider<WebCachePersistenceService>.value(
          value: webCachePersistenceService,
        ),
        RepositoryProvider<IDeeplinkService>.value(
          value: deeplinkService,
        ),
        RepositoryProvider(
          create: (context) => ScrollPersistenceService(sharedPreferences),
        ),
        RepositoryProvider(
          create: (context) => ReadingSettingsRepository(sharedPreferences),
        ),
        RepositoryProvider(
          create: (context) => MultiversionSessionRepository(sharedPreferences),
        ),
        RepositoryProvider<IBibleProvider>(
          create: (context) => GithubBibleProvider(
            context.read(),
            cacheProvider,
          ),
        ),
        RepositoryProvider<VerseOfTheDayRepository>.value(
          value: verseRepo,
        ),
        RepositoryProvider<LocalNotificationService>(
          create: (context) => notificationHandler.localNotificationService,
        ),
        RepositoryProvider<BibleSearchProvider>(
          create: (context) => searchProvider,
        ),
        RepositoryProvider<VerseOfTheDayService>.value(
          value: verseService,
        ),
        RepositoryProvider<IBibleRepository>(
          create: (context) => BibleRepository(context.read()),
        ),
        RepositoryProvider(
          create: (context) => RepositorioBusca(searchProvider),
        ),
        RepositoryProvider(
          create: (context) => HighlightRepository(db),
        ),
        RepositoryProvider<HighlightChangedNotifier>(
          create: (_) => HighlightChangedNotifier(),
          dispose: (notifier) => notifier.dispose(),
        ),
        RepositoryProvider<VerseInteractionProvider>(
          create: (context) => SqlVerseInteractionProvider(db),
        ),
        RepositoryProvider<ISearchHistoryRepository>(
          create: (context) => SearchHistoryRepository(db),
        ),
        RepositoryProvider<IVerseHistoryRepository>(
          create: (context) => VerseHistoryRepository(db),
        ),
        RepositoryProvider<IMarkedVersesRepository>(
          create: (context) => MarkedVersesRepository(db),
        ),
        RepositoryProvider<IProfileRepository>.value(
          value: profileRepo,
        ),
        RepositoryProvider<ThemeBloc>.value(
          value: themeBloc,
        ),
        RepositoryProvider<DeepUnderstandingService>.value(
          value: deepUnderstandingService,
        ),
        RepositoryProvider<EuSouRepository>.value(
          value: euSouRepository,
        ),
        RepositoryProvider<DailyContentService>.value(
          value: dailyContentService,
        ),
        RepositoryProvider<StreakService>.value(
          value: streakService,
        ),
        RepositoryProvider<DailyReminderService>.value(
          value: dailyReminderService,
        ),
        RepositoryProvider<SharedPreferences>.value(
          value: sharedPreferences,
        ),
        BlocProvider(create: (context) => TabControllerCubit()),
        BlocProvider(
          create: (context) => DeepUnderstandingBloc(deepUnderstandingService),
        ),
        BlocProvider(
          create: (context) => ChangeMyNameCubit(),
        ),
        BlocProvider(
          create: (context) => EuSouBloc(
            repository: context.read<EuSouRepository>(),
            contentService: context.read<DailyContentService>(),
            deepUnderstandingBloc: context.read<DeepUnderstandingBloc>(),
          ),
        ),
      ],
      child: const App(),
    );
  }
}
