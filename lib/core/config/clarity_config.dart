abstract final class ClarityConfig {
  // Microsoft Clarity Project ID
  // Can be configured with --dart-define=CLARITY_PROJECT_ID=your_project_id
  static const String projectId = String.fromEnvironment(
    'CLARITY_PROJECT_ID',
    defaultValue: '',
  );

  static bool get isEnabled => projectId.isNotEmpty;
}
