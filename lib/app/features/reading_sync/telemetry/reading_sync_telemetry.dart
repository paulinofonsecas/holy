import 'dart:developer' as developer;

/// Minimal telemetry shim for reading sync events.
class ReadingSyncTelemetry {
  void recordShareVerseLatency(int latencyMs) {
    developer.log(
      'reading_sync_share_latency_ms',
      name: 'reading_sync.telemetry',
      level: 0,
      error: latencyMs,
    );
  }
}
