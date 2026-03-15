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
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/data/repositories/reading_settings_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/marked_verses_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/profile_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/search_history_repository.dart';
import 'package:eu_sou/features/profile/data/repositories/verse_history_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_search_history_repository.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_verse_history_repository.dart';
import 'package:eu_sou/core/services/ai_service.dart';
import 'package:eu_sou/core/services/objectbox_service.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/objectbox_vector_store.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/eu_sou/presentation/bloc/eu_sou_bloc.dart';
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
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    await notificationHandler.initialize();

    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Warning: .env file not found or could not be loaded: $e');
    }

    final objectBoxService = await ObjectBoxService.create();
    final aiService = GeminiAIService();
    final vectorStore = ObjectBoxVectorStore(objectBoxService.store);
    final deepUnderstandingService = DeepUnderstandingService(
      vectorStore,
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

    debugPrint('Main: Initializing verse notifications...');
    await verseService.scheduleNextNotifications();

    final profileRepo = ProfileRepository();
    final themeBloc = ThemeBloc(profileRepo);

    // Wait for theme to be initialized from preferences
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
    ));
  } catch (e) {
    debugPrint('Erro ao inicializar o aplicativo: $e');
    runApp(const ErrorScreen());
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
        BlocProvider(create: (context) => TabControllerCubit()),
        BlocProvider(
          create: (context) => DeepUnderstandingBloc(deepUnderstandingService),
        ),
        BlocProvider(
          create: (context) => EuSouBloc(
            repository: context.read<EuSouRepository>(),
            contentService: context.read<DailyContentService>(), deepUnderstandingBloc: context.read<DeepUnderstandingBloc>(),
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
