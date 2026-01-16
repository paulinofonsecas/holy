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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const EntryPoint());
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _initialized = false;
  late final Database _db;
  late final SqlBibleSearchProvider _searchProvider;
  late final BibleCacheProvider _cacheProvider;
  late final SharedPreferences _sharedPreferences;
  late final VerseOfTheDayRepository _verseRepo;
  late final VerseOfTheDayService _verseService;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await notificationHandler.initialize();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final dbHelper = DatabaseHelper();
    _db = await dbHelper.database;
    _searchProvider = SqlBibleSearchProvider(_db);
    _cacheProvider = BibleCacheProvider(_db);

    _sharedPreferences = await SharedPreferences.getInstance();

    _verseRepo = VerseOfTheDayRepository(_sharedPreferences);
    _verseService = VerseOfTheDayService(
      repository: _verseRepo,
      searchProvider: _searchProvider,
      notificationService: notificationHandler.localNotificationService,
    );

    await _verseService.scheduleNextNotifications();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => Dio(),
        ),
        RepositoryProvider(
          create: (context) => _cacheProvider,
        ),
        RepositoryProvider<IBibleProvider>(
          create: (context) => GithubBibleProvider(
            context.read(),
            _cacheProvider,
          ),
        ),
        RepositoryProvider<VerseOfTheDayRepository>.value(
          value: _verseRepo,
        ),
        RepositoryProvider<LocalNotificationService>(
          create: (context) => notificationHandler.localNotificationService,
        ),
        RepositoryProvider<BibleSearchProvider>(
          create: (context) => _searchProvider,
        ),
        RepositoryProvider<VerseOfTheDayService>.value(
          value: _verseService,
        ),
        RepositoryProvider<IBibleRepository>(
          create: (context) => BibleRepository(context.read()),
        ),
        RepositoryProvider(
          create: (context) => RepositorioBusca(_searchProvider),
        ),
        RepositoryProvider(
          create: (context) => HighlightRepository(_db),
        ),
        RepositoryProvider<VerseInteractionProvider>(
          create: (context) => SqlVerseInteractionProvider(_db),
        ),
        RepositoryProvider<ISearchHistoryRepository>(
          create: (context) => SearchHistoryRepository(_db),
        ),
        RepositoryProvider<IVerseHistoryRepository>(
          create: (context) => VerseHistoryRepository(_db),
        ),
        RepositoryProvider<IMarkedVersesRepository>(
          create: (context) => MarkedVersesRepository(_db),
        ),
        RepositoryProvider<IProfileRepository>(
          create: (context) => ProfileRepository(),
        ),
        RepositoryProvider<ThemeBloc>(
          create: (context) => ThemeBloc(context.read<IProfileRepository>()),
        ),
        BlocProvider(create: (context) => TabControllerCubit()),
      ],
      child: const App(),
    );
  }
}
