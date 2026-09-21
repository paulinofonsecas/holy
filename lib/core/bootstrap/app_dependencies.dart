import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/data/database_helper.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/ai_service.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/hive_vector_store_web.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/in_memory_vector_store.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/profile/data/repositories/profile_repository.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Holds all application dependencies, created once during bootstrap.
class AppDependencies {
  AppDependencies._({
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

  final Database db;
  final SqlBibleSearchProvider searchProvider;
  final BibleCacheProvider cacheProvider;
  final SharedPreferences sharedPreferences;
  final VerseOfTheDayRepository verseRepo;
  final VerseOfTheDayService verseService;
  final ProfileRepository profileRepo;
  final ThemeBloc themeBloc;
  final DeeplinkService deeplinkService;
  final DeepUnderstandingService deepUnderstandingService;
  final EuSouRepository euSouRepository;
  final DailyContentService dailyContentService;
  final StreakService streakService;
  final DailyReminderService dailyReminderService;
  final WebCachePersistenceService webCachePersistenceService;

  /// Creates and initializes all application dependencies.
  static Future<AppDependencies> initialize() async {
    final aiService = GeminiAIService();
    final vectorStore = kIsWeb ? HiveVectorStore() : InMemoryVectorStore();

    final deepUnderstandingService = DeepUnderstandingService(
      vectorStore,
      aiService,
      notificationHandler.localNotificationService,
    );

    final deeplinkService = DeeplinkService();

    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final searchProvider = SqlBibleSearchProvider(db);
    final cacheProvider = BibleCacheProvider(db);

    final sharedPreferences = await SharedPreferences.getInstance();

    final webCachePersistenceService = WebCachePersistenceService(
      db: db,
      prefs: sharedPreferences,
    );

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

    return AppDependencies._(
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
      webCachePersistenceService: webCachePersistenceService,
    );
  }
}
