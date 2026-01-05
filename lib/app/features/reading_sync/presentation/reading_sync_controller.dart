import 'dart:async';

import '../data/study_room_service.dart';
import '../domain/apply_share_event_usecase.dart';
import '../domain/models/models.dart';
import '../telemetry/reading_sync_telemetry.dart';

/// Presentation/controller glue to translate RTDB events into UI consumable state.
class ReadingSyncController {
  ReadingSyncController({
    required ReadingSyncStudyRoomService service,
    required ApplyShareEventUseCase applyShareEvent,
    ReadingSyncTelemetry? telemetry,
  })  : _service = service,
        _applyShareEvent = applyShareEvent,
        _telemetry = telemetry ?? ReadingSyncTelemetry();

  final ReadingSyncStudyRoomService _service;
  final ApplyShareEventUseCase _applyShareEvent;
  final ReadingSyncTelemetry _telemetry;

  final _appliedShareEvents =
      StreamController<ApplyShareEventResult>.broadcast();
  StreamSubscription<ShareEvent>? _subscription;

  Stream<ApplyShareEventResult> get appliedShareEvents =>
      _appliedShareEvents.stream;

  Future<void> startListening(String roomId) async {
    await _service.subscribeToShareEvents(roomId);
    _subscription?.cancel();
    _subscription = _service.events.listen((event) async {
      final started = DateTime.now();
      final result = await _applyShareEvent(event);
      if (result != null) {
        _appliedShareEvents.add(result);
        final latencyMs = DateTime.now().difference(started).inMilliseconds;
        _telemetry.recordShareVerseLatency(latencyMs);
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _appliedShareEvents.close();
  }
}
