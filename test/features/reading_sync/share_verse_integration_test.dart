import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/app/core/verse_resolver.dart';
import 'package:eu_sou/app/features/study_rooms/bloc/study_room_bloc.dart';
import 'package:eu_sou/app/models/study_room.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:eu_sou/app/services/study_room_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStudyRoomService extends Mock implements StudyRoomService {}

void main() {
  late MockStudyRoomService service;
  late StreamController<ShareEvent> controller;

  setUpAll(() {
    registerFallbackValue(
      const VerseReference(book: 'Genesis', chapter: 1, verse: 1),
    );
  });

  setUp(() {
    service = MockStudyRoomService();
    controller = StreamController<ShareEvent>.broadcast();

    when(() => service.events).thenAnswer((_) => controller.stream);
    when(() => service.joinRoom(any(), any(), any())).thenAnswer((_) async {});
    when(() => service.leaveRoom(any(), any())).thenAnswer((_) async {});
    when(() => service.getRoomDetails(any())).thenAnswer(
      (_) async => const StudyRoom(
        roomId: 'room-1',
        title: 'Room',
        hostId: 'host-1',
      ),
    );
  });

  tearDown(() async {
    await controller.close();
  });

  blocTest<StudyRoomBloc, StudyRoomState>(
    'delivers ShareVerse stream event to follower state',
    build: () => StudyRoomBloc(service),
    act: (bloc) async {
      bloc.add(const JoinRoom(
          roomId: 'room-1', userId: 'user-2', displayName: 'Guest'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.add(
        const ShareEvent(
          eventId: 'evt-1',
          sessionId: 'session-1',
          type: ShareEventType.shareVerse,
          verseRef: VerseReference(book: 'John', chapter: 3, verse: 16),
          authorId: 'host-1',
          createdAt: 123,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [
      isA<StudyRoomLoading>(),
      isA<StudyRoomJoined>()
          .having((s) => s.status, 'status', SyncStatus.following)
          .having((s) => s.lastEvent, 'lastEvent', isNull),
      isA<StudyRoomJoined>()
          .having((s) => s.lastEvent?.type, 'type', ShareEventType.shareVerse)
          .having(
            (s) => s.lastEvent?.verseRef.book,
            'book',
            'John',
          ),
    ],
  );
}
