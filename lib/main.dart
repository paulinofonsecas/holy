import 'dart:async';

import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/app/app.dart';
import 'package:eu_sou/core/data/database_helper.dart';
import 'package:eu_sou/core/data/provider/github_bible_provider.dart';
import 'package:eu_sou/core/data/provider/interfaces/i_bible_provider.dart';
import 'package:eu_sou/core/data/repositories/bible_repository.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/core/services/ai_service.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/data/repositories/reading_settings_repository.dart';
import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/in_memory_vector_store.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';
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
import 'package:eu_sou/firebase_options.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    try {
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    } catch (e) {
      debugPrint('Warning: unable to preserve native splash: $e');
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }


    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Warning: .env file not found or could not be loaded: $e');
    }

    await notificationHandler.initialize();

    late final DeepUnderstandingService deepUnderstandingService;
    final aiService = GeminiAIService();

    deepUnderstandingService = DeepUnderstandingService(
      InMemoryVectorStore(),
      aiService,
      notificationHandler.localNotificationService,
    );

    final deeplinkService = DeeplinkService();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final searchProvider = SqlBibleSearchProvider(db);
    final cacheProvider = BibleCacheProvider(db);

    final sharedPreferences = await SharedPreferences.getInstance();

    final streakService = StreakService(db: db, prefs: sharedPreferences);
    final euSouRepository = EuSouRepository(
      db: db,
      prefs: sharedPreferences,
      searchProvider: searchProvider,
      streakService: streakService,
    );
    final dailyContentService = DailyContentService(prefs: sharedPreferences);

    final verseRepo = VerseOfTheDayRepository(sharedPreferences);
    final verseService = VerseOfTheDayService(
      repository: verseRepo,
      searchProvider: searchProvider,
      notificationService: notificationHandler.localNotificationService,
    );

    final dailyReminderService = DailyReminderService(
      notificationService: notificationHandler.localNotificationService,
      prefs: sharedPreferences,
      searchProvider: searchProvider,
      aiService: aiService,
    );

    final profileRepo = ProfileRepository();
    final themeBloc = ThemeBloc(profileRepo);

    await themeBloc.stream.firstWhere((state) => state.isInitialized);

    runApp(EntryPoint(
      db: db,
      searchProvider: searchProvider,
      cacheProvider: cacheProvider,
      sharedPreferences: sharedPreferences,
      verseRepo: verseRepo,
      verseService: verseService,
      profileRepo: profileRepo,
      themeBloc: themeBloc,
      deeplinkService: deeplinkService,
      deepUnderstandingService: deepUnderstandingService,
      euSouRepository: euSouRepository,
      dailyContentService: dailyContentService,
      streakService: streakService,
      dailyReminderService: dailyReminderService,
    ));

    unawaited(_scheduleNotificationsInBackground(
      verseService: verseService,
      dailyReminderService: dailyReminderService,
    ));
    unawaited(_warmUpDailyReflectionInBackground(
      euSouRepository: euSouRepository,
      dailyContentService: dailyContentService,
    ));
  } catch (e) {
    debugPrint('Erro ao inicializar o aplicativo: $e');
    runApp(const ErrorScreen());
  }
}

Future<void> _scheduleNotificationsInBackground({
  required VerseOfTheDayService verseService,
  required DailyReminderService dailyReminderService,
}) async {
  try {
    debugPrint('Main: Scheduling notifications in background...');
    await verseService.ensureWeeklyNotificationsScheduled();
    await dailyReminderService.rescheduleAll();
  } catch (e) {
    debugPrint('Main: Background scheduling failed: $e');
  }
}

Future<void> _warmUpDailyReflectionInBackground({
  required EuSouRepository euSouRepository,
  required DailyContentService dailyContentService,
}) async {
  try {
    const versionId = 'KJA';
    debugPrint('Main: Warming up daily reflection in background...');

    var reflection = await euSouRepository.getTodayReflection();
    if (reflection != null &&
        !dailyContentService.isFallbackContent(
          essencia: reflection.essencia,
          pratica: reflection.pratica,
          verseReference: reflection.verseReference,
        )) {
      debugPrint('Main: Daily reflection already generated with AI.');
      return;
    }

    final verse = reflection == null
        ? await euSouRepository.getDailyVerse(versionId)
        : (text: reflection.verseText, reference: reflection.verseReference);

    if (verse == null) {
      debugPrint('Main: Could not fetch a verse for daily reflection warm-up.');
      return;
    }

    final content =
        await dailyContentService.getOrGenerate(verse.text, verse.reference);
    final updatedReflection = DailyReflection(
      date:
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      greetingWord: euSouRepository.greetingForToday(),
      verseText: verse.text,
      verseReference: verse.reference,
      essencia: content.essencia,
      pratica: content.pratica,
    );

    await euSouRepository.saveTodayReflection(updatedReflection);
    debugPrint(
        'Main: Daily reflection warm-up finished for ${verse.reference}.');
  } catch (e) {
    debugPrint('Main: Daily reflection warm-up failed: $e');
  }
}

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
        RepositoryProvider<IDeeplinkService>.value(
          value: deeplinkService,
        ),
        RepositoryProvider(
          create: (context) => ScrollPersistenceService(sharedPreferences),
        ),
        RepositoryProvider(
          create: (context) => ReadingSettingsRepository(sharedPreferences),
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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Erro ao inicializar o aplicativo'),
        ),
      ),
    );
  }
}
