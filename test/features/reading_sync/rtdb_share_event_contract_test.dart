import 'package:eu_sou/app/core/verse_resolver.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:eu_sou/app/services/study_room_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockVerseResolver extends Mock implements VerseResolver {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const VerseReference(book: 'Genesis', chapter: 1, verse: 1),
    );
  });

  test(
      'publishEvent writes ShareVerse with server timestamp to RTDB events path',
      () async {
    final database = MockFirebaseDatabase();
    final eventsRef = MockDatabaseReference();
    final pushRef = MockDatabaseReference();
    final resolver = MockVerseResolver();

    when(() => database.ref('studyRooms/room-1/events')).thenReturn(eventsRef);
    when(() => eventsRef.push()).thenReturn(pushRef);
    when(() => pushRef.key).thenReturn('evt123');
    Map<dynamic, dynamic>? captured;
    when(() => pushRef.set(any<dynamic>())).thenAnswer((invocation) async {
      captured = invocation.positionalArguments.first as Map<dynamic, dynamic>;
    });
    when(() => resolver.isValid(any<VerseReference>())).thenAnswer(
      (_) async => true,
    );

    final service = StudyRoomService(database, resolver);
    await service.publishEvent(
      'room-1',
      const ShareEvent(
        eventId: '',
        sessionId: 'session-1',
        type: ShareEventType.shareVerse,
        verseRef: VerseReference(book: 'John', chapter: 3, verse: 16),
        authorId: 'host-1',
        createdAt: 0,
      ),
    );

    verify(() => database.ref('studyRooms/room-1/events')).called(1);
    verify(() => eventsRef.push()).called(1);
    verify(() => pushRef.set(any<dynamic>())).called(1);

    expect(captured?['eventId'], 'evt123');
    expect(captured?['created_at'], ServerValue.timestamp);
    expect(captured?['type'], 'ShareVerse');
    expect(
      captured?['verseRef'],
      isA<VerseReference>()
          .having((v) => v.book, 'book', 'John')
          .having((v) => v.chapter, 'chapter', 3)
          .having((v) => v.verse, 'verse', 16),
    );
  });
}
