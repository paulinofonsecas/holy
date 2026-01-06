import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/app/app.dart';
import 'package:eu_sou/core/core.dart';
import 'package:eu_sou/features/features.dart';
import 'package:eu_sou/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show Database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await notificationHandler.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final searchProvider = SqlBibleSearchProvider(db);
  final cacheProvider = BibleCacheProvider(db);

  final sharedPreferences = await SharedPreferences.getInstance();

  final verseRepo = VerseOfTheDayRepository(sharedPreferences);
  final verseService = VerseOfTheDayService(
    repository: verseRepo,
    searchProvider: searchProvider,
    notificationService: notificationHandler.localNotificationService,
  );

  await verseService.scheduleNextNotifications();

  runApp(
    MultiRepositoryProvider(
      providers: _buildProviders(
        db,
        cacheProvider,
        searchProvider,
        verseRepo,
        verseService,
      ),
      child: const App(),
    ),
  );
}

List<RepositoryProvider> _buildProviders(
  Database db,
  BibleCacheProvider cacheProvider,
  SqlBibleSearchProvider searchProvider,
  VerseOfTheDayRepository verseRepo,
  VerseOfTheDayService verseService,
) {
  return [
    RepositoryProvider(create: (_) => Dio()),
    RepositoryProvider(create: (_) => cacheProvider),
    RepositoryProvider<IBibleProvider>(
        create: (c) => GithubBibleProvider(c.read(), cacheProvider)),
    RepositoryProvider<VerseOfTheDayRepository>.value(value: verseRepo),
    RepositoryProvider<LocalNotificationService>(
        create: (_) => notificationHandler.localNotificationService),
    RepositoryProvider<BibleSearchProvider>(create: (_) => searchProvider),
    RepositoryProvider<VerseOfTheDayService>.value(value: verseService),
    RepositoryProvider<IBibleRepository>(
        create: (c) => BibleRepository(c.read())),
    RepositoryProvider(create: (_) => RepositorioBusca(searchProvider)),
    RepositoryProvider(create: (_) => HighlightRepository(db)),
    RepositoryProvider<VerseInteractionProvider>(
        create: (_) => SqlVerseInteractionProvider(db)),
    RepositoryProvider<ISearchHistoryRepository>(
        create: (_) => SearchHistoryRepository(db)),
    RepositoryProvider<IVerseHistoryRepository>(
        create: (_) => VerseHistoryRepository(db)),
    RepositoryProvider<IMarkedVersesRepository>(
        create: (_) => MarkedVersesRepository(db)),
    RepositoryProvider<IProfileRepository>(create: (_) => ProfileRepository()),
    RepositoryProvider<ThemeBloc>(
        create: (c) => ThemeBloc(c.read<IProfileRepository>())),
  ];
}
