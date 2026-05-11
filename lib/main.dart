import 'dart:async';

import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/clarity/clarity_wrapper.dart';
import 'package:eu_sou/core/data/database_helper.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/ai_service.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/in_memory_vector_store.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';
import 'package:eu_sou/features/profile/data/repositories/profile_repository.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';
import 'package:eu_sou/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/sentry_config.dart';
import 'entry_point.dart';
import 'error_screen.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn.isEmpty ? null : SentryConfig.dsn;
      options.environment = SentryConfig.environment;
      options.tracesSampleRate = SentryConfig.tracesSampleRate;
    },
    appRunner: _bootstrapApp,
  );
}

Future<void> _bootstrapApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb) {
      try {
        FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      } catch (e) {
        debugPrint('Warning: unable to preserve native splash: $e');
      }
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // try {
    //   await dotenv.load(fileName: ".env");
    // } catch (e) {
    //   debugPrint('Warning: .env file not found or could not be loaded: $e');
    // }

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

    // Initialize web cache persistence service
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

    final entryPoint = EntryPoint(
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
    final appWithClarity = wrapWithClarity(entryPoint);

    runApp(
      SentryWidget(
        child: appWithClarity,
      ),
    );

    unawaited(_scheduleNotificationsInBackground(
      verseService: verseService,
      dailyReminderService: dailyReminderService,
    ));
    unawaited(_warmUpDailyReflectionInBackground(
      euSouRepository: euSouRepository,
      dailyContentService: dailyContentService,
      versionId: 'JFAA',
    ));
  } catch (e, stackTrace) {
    debugPrint(
        'Erro ao inicializar o aplicativo: $e, stack trace: $stackTrace');
    await Sentry.captureException(e, stackTrace: stackTrace);
    runApp(
      SentryWidget(
        child: ErrorScreen(
          error: '$e\n$stackTrace',
        ),
      ),
    );
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
  required String versionId,
}) async {
  try {
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
