import 'dart:async';

import 'package:eu_sou/core/bootstrap/app_dependencies.dart';
import 'package:eu_sou/core/bootstrap/background_tasks.dart';
import 'package:eu_sou/core/bootstrap/bootstrap_error.dart';
import 'package:eu_sou/core/clarity/clarity_wrapper.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/entry_point.dart';
import 'package:eu_sou/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Main application bootstrap entry point.
///
/// Orchestrates platform bindings, splash screen, Firebase, notifications,
/// dependency creation, and finally runs the app.
Future<void> bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // On web, use the hash URL strategy (/#/...) so that refreshing the page
  // always loads the root document and never hits a 404 on the server.
  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }

  try {
    _preserveSplash(widgetsBinding);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _initializeNotifications();

    final deps = await AppDependencies.initialize();

    final entryPoint = EntryPoint(
      db: deps.db,
      searchProvider: deps.searchProvider,
      cacheProvider: deps.cacheProvider,
      sharedPreferences: deps.sharedPreferences,
      verseRepo: deps.verseRepo,
      verseService: deps.verseService,
      profileRepo: deps.profileRepo,
      themeBloc: deps.themeBloc,
      deeplinkService: deps.deeplinkService,
      deepUnderstandingService: deps.deepUnderstandingService,
      euSouRepository: deps.euSouRepository,
      dailyContentService: deps.dailyContentService,
      streakService: deps.streakService,
      dailyReminderService: deps.dailyReminderService,
      webCachePersistenceService: deps.webCachePersistenceService,
    );

    runApp(
      SentryWidget(
        child: wrapWithClarity(entryPoint),
      ),
    );

    _launchBackgroundTasks(deps);
  } catch (e, stackTrace) {
    reportBootstrapError(e, stackTrace);
  }
}

/// Preserves the native splash screen on non-web platforms.
void _preserveSplash(WidgetsBinding widgetsBinding) {
  if (kIsWeb) return;
  try {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  } catch (e) {
    debugPrint('Warning: unable to preserve native splash: $e');
  }
}

/// Initializes push / local notifications; non-fatal on unsupported platforms.
Future<void> _initializeNotifications() async {
  try {
    await notificationHandler.initialize();
  } catch (e) {
    debugPrint('Warning: notification initialization skipped: $e');
  }
}

/// Fires-and-forgets long-running background tasks after the app is running.
void _launchBackgroundTasks(AppDependencies deps) {
  unawaited(scheduleNotificationsInBackground(
    verseService: deps.verseService,
    dailyReminderService: deps.dailyReminderService,
  ));
  unawaited(warmUpDailyReflectionInBackground(
    euSouRepository: deps.euSouRepository,
    dailyContentService: deps.dailyContentService,
  ));
}
