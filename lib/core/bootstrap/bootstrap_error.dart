import 'dart:async';

import 'package:eu_sou/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Reports a fatal bootstrap error to Sentry and shows the [ErrorScreen].
void reportBootstrapError(Object error, StackTrace stackTrace) {
  debugPrint('Fatal bootstrap error: $error\n$stackTrace');
  unawaited(Sentry.captureException(error, stackTrace: stackTrace));
  runApp(
    SentryWidget(
      child: ErrorScreen(error: '$error\n$stackTrace'),
    ),
  );
}
