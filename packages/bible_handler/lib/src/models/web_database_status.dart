enum WebDatabaseStatusType {
  initializing,
  downloading,
  extracting,
  ready,
  error,
}

class WebDatabaseStatus {
  final WebDatabaseStatusType type;
  final double progress;
  final String? errorMessage;

  const WebDatabaseStatus({
    required this.type,
    required this.progress,
    this.errorMessage,
  });

  factory WebDatabaseStatus.initializing() => const WebDatabaseStatus(
    type: WebDatabaseStatusType.initializing,
    progress: 0.0,
  );

  factory WebDatabaseStatus.downloading(double progress) => WebDatabaseStatus(
    type: WebDatabaseStatusType.downloading,
    progress: progress,
  );

  factory WebDatabaseStatus.extracting() => const WebDatabaseStatus(
    type: WebDatabaseStatusType.extracting,
    progress: 1.0,
  );

  factory WebDatabaseStatus.ready() =>
      const WebDatabaseStatus(type: WebDatabaseStatusType.ready, progress: 1.0);

  factory WebDatabaseStatus.error(String message) => WebDatabaseStatus(
    type: WebDatabaseStatusType.error,
    progress: 0.0,
    errorMessage: message,
  );

  @override
  String toString() => 'WebDatabaseStatus(type: $type, progress: $progress)';
}
