import 'dart:async';

import 'package:flutter/foundation.dart';

/// Event telemetry data for tracking latency and success/failure rates.
class EventTelemetry {
  final String eventId;
  final String eventType;
  final DateTime sentAt;
  DateTime? receivedAt;
  DateTime? appliedAt;
  String? errorMessage;
  bool get isSuccess => errorMessage == null && appliedAt != null;
  int get latencyMs =>
      (receivedAt?.millisecondsSinceEpoch ?? 0) - sentAt.millisecondsSinceEpoch;
  int get applicationTimeMs =>
      (appliedAt?.millisecondsSinceEpoch ?? 0) -
      (receivedAt?.millisecondsSinceEpoch ?? 0);
  int get totalLatencyMs =>
      (appliedAt?.millisecondsSinceEpoch ?? 0) - sentAt.millisecondsSinceEpoch;

  EventTelemetry({
    required this.eventId,
    required this.eventType,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventType': eventType,
        'sentAt': sentAt.toIso8601String(),
        'receivedAt': receivedAt?.toIso8601String(),
        'appliedAt': appliedAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'isSuccess': isSuccess,
        'latencyMs': latencyMs,
        'applicationTimeMs': applicationTimeMs,
        'totalLatencyMs': totalLatencyMs,
      };
}

/// Service for tracking sync telemetry and metrics.
class TelemetryService {
  final Map<String, EventTelemetry> _events = {};
  final _metricsController = StreamController<TelemetryMetrics>.broadcast();

  Stream<TelemetryMetrics> get metrics => _metricsController.stream;

  /// Records when an event is sent.
  String recordEventSent(String eventId, String eventType) {
    _events[eventId] = EventTelemetry(
      eventId: eventId,
      eventType: eventType,
      sentAt: DateTime.now(),
    );
    return eventId;
  }

  /// Records when an event is received/heard back.
  void recordEventReceived(String eventId) {
    final telemetry = _events[eventId];
    if (telemetry != null) {
      telemetry.receivedAt = DateTime.now();
      _emitMetricsUpdate();
    }
  }

  /// Records when an event is successfully applied in the UI.
  void recordEventApplied(String eventId) {
    final telemetry = _events[eventId];
    if (telemetry != null) {
      telemetry.appliedAt = DateTime.now();
      _emitMetricsUpdate();
      debugPrint(
          'Event $eventId applied successfully in ${telemetry.totalLatencyMs}ms');
    }
  }

  /// Records when an event fails to apply.
  void recordEventError(String eventId, String error) {
    final telemetry = _events[eventId];
    if (telemetry != null) {
      telemetry.errorMessage = error;
      telemetry.appliedAt = DateTime.now();
      _emitMetricsUpdate();
      debugPrint('Event $eventId failed: $error');
    }
  }

  /// Gets telemetry for a specific event.
  EventTelemetry? getEventTelemetry(String eventId) => _events[eventId];

  /// Gets all recorded telemetry data.
  List<EventTelemetry> getAllTelemetry() => _events.values.toList();

  /// Clears old telemetry data (older than specified duration).
  void clearOldTelemetry({Duration keepDuration = const Duration(hours: 1)}) {
    final cutoffTime = DateTime.now().subtract(keepDuration);
    _events
        .removeWhere((_, telemetry) => telemetry.sentAt.isBefore(cutoffTime));
  }

  /// Computes metrics summary.
  TelemetryMetrics computeMetrics() {
    if (_events.isEmpty) {
      return TelemetryMetrics.empty();
    }

    final completedEvents =
        _events.values.where((t) => t.appliedAt != null).toList();
    final successfulEvents = completedEvents.where((t) => t.isSuccess).toList();
    final failedEvents = completedEvents.where((t) => !t.isSuccess).toList();

    final latencies = successfulEvents.map((t) => t.totalLatencyMs).toList();
    final avgLatency = latencies.isEmpty
        ? 0
        : latencies.reduce((a, b) => a + b) ~/ latencies.length;
    final maxLatency =
        latencies.isEmpty ? 0 : latencies.reduce((a, b) => a > b ? a : b);
    final minLatency =
        latencies.isEmpty ? 0 : latencies.reduce((a, b) => a < b ? a : b);

    return TelemetryMetrics(
      totalEvents: _events.length,
      successCount: successfulEvents.length,
      failureCount: failedEvents.length,
      pendingCount: _events.length - completedEvents.length,
      successRate: completedEvents.isEmpty
          ? 0.0
          : (successfulEvents.length / completedEvents.length),
      averageLatencyMs: avgLatency,
      maxLatencyMs: maxLatency,
      minLatencyMs: minLatency,
      recordedAt: DateTime.now(),
    );
  }

  void _emitMetricsUpdate() {
    _metricsController.add(computeMetrics());
  }

  /// Disposes the service.
  void dispose() {
    _metricsController.close();
  }
}

/// Aggregated telemetry metrics.
class TelemetryMetrics {
  final int totalEvents;
  final int successCount;
  final int failureCount;
  final int pendingCount;
  final double successRate; // 0.0 to 1.0
  final int averageLatencyMs;
  final int maxLatencyMs;
  final int minLatencyMs;
  final DateTime recordedAt;

  TelemetryMetrics({
    required this.totalEvents,
    required this.successCount,
    required this.failureCount,
    required this.pendingCount,
    required this.successRate,
    required this.averageLatencyMs,
    required this.maxLatencyMs,
    required this.minLatencyMs,
    required this.recordedAt,
  });

  factory TelemetryMetrics.empty() => TelemetryMetrics(
        totalEvents: 0,
        successCount: 0,
        failureCount: 0,
        pendingCount: 0,
        successRate: 0.0,
        averageLatencyMs: 0,
        maxLatencyMs: 0,
        minLatencyMs: 0,
        recordedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'totalEvents': totalEvents,
        'successCount': successCount,
        'failureCount': failureCount,
        'pendingCount': pendingCount,
        'successRate': successRate,
        'averageLatencyMs': averageLatencyMs,
        'maxLatencyMs': maxLatencyMs,
        'minLatencyMs': minLatencyMs,
        'recordedAt': recordedAt.toIso8601String(),
      };
}
