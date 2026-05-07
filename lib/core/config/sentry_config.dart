abstract final class SentryConfig {
  // Fill these values later with --dart-define or CI environment variables.
  static const String dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const String environment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'development',
  );

  static double get tracesSampleRate =>
      double.tryParse(
          const String.fromEnvironment('SENTRY_TRACES_SAMPLE_RATE')) ??
      1.0;
}
