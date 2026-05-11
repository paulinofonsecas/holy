import 'package:flutter/widgets.dart';
import 'package:clarity_flutter/clarity_flutter.dart' as clarity;
import 'package:eu_sou/core/config/clarity_config.dart';
import 'package:flutter/foundation.dart';

Widget wrapWithClarity(Widget app) {
  if (!ClarityConfig.isEnabled) return app;

  final config = clarity.ClarityConfig(
    projectId: ClarityConfig.projectId,
    logLevel: kDebugMode ? clarity.LogLevel.Info : clarity.LogLevel.None,
  );

  return clarity.ClarityWidget(
    app: app,
    clarityConfig: config,
  );
}
