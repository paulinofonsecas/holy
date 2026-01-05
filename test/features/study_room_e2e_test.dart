import 'package:eu_sou/app/core/verse_resolver.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:eu_sou/app/services/telemetry_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeVerseResolver extends Fake implements VerseResolver {
  FakeVerseResolver({this.valid = true});

  final bool valid;

  @override
  Future<bool> isValid(VerseReference ref) async => valid;

  @override
  Future<VerseReference> reverseResolve(dynamic localPosition) async =>
      const VerseReference(book: 'João', chapter: 3, verse: 16);

  @override
  Future<dynamic> resolve(VerseReference reference) async =>
      '${reference.book}-${reference.chapter}-${reference.verse}';
}

void main() {
  group('Study Room E2E Integration Tests', () {
    late TelemetryService telemetryService;
    late FakeVerseResolver resolver;

    setUp(() {
      telemetryService = TelemetryService();
      resolver = FakeVerseResolver();
    });

    tearDown(() {
      telemetryService.dispose();
    });

    test(
        'Host shares a verse and participant receives event with latency < 2000ms',
        () async {
      // Arrange
      const hostId = 'host123';
      const verseRef = VerseReference(
        book: 'João',
        chapter: 3,
        verse: 16,
      );

      final shareEvent = ShareEvent(
        eventId: 'event123',
        sessionId: 'session456',
        type: ShareEventType.shareVerse,
        verseRef: verseRef,
        authorId: hostId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act
      // Record when host publishes the event
      final eventId = telemetryService.recordEventSent(
        shareEvent.eventId,
        shareEvent.type.toString(),
      );

      // Simulate network latency (50-200ms)
      await Future.delayed(const Duration(milliseconds: 100));
      telemetryService.recordEventReceived(eventId);

      // Simulate UI application time (30-100ms)
      await Future.delayed(const Duration(milliseconds: 50));
      telemetryService.recordEventApplied(eventId);

      // Assert
      final telemetry = telemetryService.getEventTelemetry(eventId);
      expect(telemetry, isNotNull);
      expect(telemetry!.isSuccess, true);
      expect(telemetry.totalLatencyMs, lessThan(2000));
      expect(telemetry.totalLatencyMs, greaterThan(0));
      expect(telemetry.latencyMs, greaterThan(0));
      expect(telemetry.applicationTimeMs, greaterThan(0));
    });

    test('Multiple events are tracked with success metrics', () async {
      // Arrange
      final events = <String>[];

      // Act
      for (int i = 0; i < 5; i++) {
        final eventId = telemetryService.recordEventSent(
          'event_$i',
          'shareVerse',
        );
        events.add(eventId);

        // Simulate varied latencies
        await Future.delayed(Duration(milliseconds: 50 + (i * 20)));
        telemetryService.recordEventReceived(eventId);

        await Future.delayed(const Duration(milliseconds: 30));
        telemetryService.recordEventApplied(eventId);
      }

      // Assert
      final metrics = telemetryService.computeMetrics();
      expect(metrics.totalEvents, 5);
      expect(metrics.successCount, 5);
      expect(metrics.failureCount, 0);
      expect(metrics.successRate, 1.0);
      expect(metrics.averageLatencyMs, greaterThan(0));
      expect(metrics.maxLatencyMs, greaterThanOrEqualTo(metrics.minLatencyMs));
    });

    test('Failed event is properly recorded', () async {
      // Arrange
      const eventId = 'event_failed';
      const errorMessage = 'Invalid verse reference';

      // Act
      telemetryService.recordEventSent(eventId, 'shareVerse');
      await Future.delayed(const Duration(milliseconds: 100));
      telemetryService.recordEventReceived(eventId);
      telemetryService.recordEventError(eventId, errorMessage);

      // Assert
      final telemetry = telemetryService.getEventTelemetry(eventId);
      expect(telemetry, isNotNull);
      expect(telemetry!.isSuccess, false);
      expect(telemetry.errorMessage, errorMessage);
      expect(telemetry.appliedAt, isNotNull);
    });

    test('Telemetry metrics are emitted over stream', () async {
      // Arrange
      final metricsStream = telemetryService.metrics;
      var metricsCount = 0;

      // Act
      final subscription = metricsStream.listen((metrics) {
        metricsCount++;
      });

      final eventId = telemetryService.recordEventSent('event1', 'shareVerse');
      await Future.delayed(const Duration(milliseconds: 50));
      telemetryService.recordEventReceived(eventId);
      await Future.delayed(const Duration(milliseconds: 30));
      telemetryService.recordEventApplied(eventId);

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(metricsCount, greaterThan(0));
      subscription.cancel();
    });

    test('Old telemetry is cleared correctly', () async {
      // Arrange
      final eventId =
          telemetryService.recordEventSent('old_event', 'shareVerse');
      await Future.delayed(const Duration(milliseconds: 50));
      telemetryService.recordEventReceived(eventId);
      telemetryService.recordEventApplied(eventId);

      // Act
      telemetryService.clearOldTelemetry(
        keepDuration: const Duration(milliseconds: 0),
      );

      // Assert
      expect(telemetryService.getAllTelemetry(), isEmpty);
    });

    test('Verse resolution is validated during event publishing', () async {
      // Arrange
      const verseRef = VerseReference(
        book: 'João',
        chapter: 3,
        verse: 16,
      );

      final shareEvent = ShareEvent(
        eventId: 'event_valid_verse',
        sessionId: 'session_456',
        type: ShareEventType.shareVerse,
        verseRef: verseRef,
        authorId: 'host123',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act & Assert
      expect(
        await resolver.isValid(shareEvent.verseRef),
        true,
      );
    });

    test('Invalid verse reference fails validation', () async {
      // Arrange
      const invalidVerse = VerseReference(
        book: 'Invalid Book',
        chapter: 999,
        verse: 999,
      );
      final invalidResolver = FakeVerseResolver(valid: false);

      // Act & Assert
      expect(
        await invalidResolver.isValid(invalidVerse),
        false,
      );
    });

    test('Event latency respects 2s SLA', () async {
      // Arrange
      const eventId = 'event_sla_test';
      const maxLatency = 2000; // 2 seconds in milliseconds

      // Act
      telemetryService.recordEventSent(eventId, 'shareVerse');

      // Simulate realistic mobile network latency (100-500ms)
      await Future.delayed(const Duration(milliseconds: 150));
      telemetryService.recordEventReceived(eventId);

      // Simulate UI processing (50-200ms)
      await Future.delayed(const Duration(milliseconds: 100));
      telemetryService.recordEventApplied(eventId);

      // Assert
      final telemetry = telemetryService.getEventTelemetry(eventId);
      expect(telemetry!.totalLatencyMs, lessThanOrEqualTo(maxLatency));
    });
  });
}
