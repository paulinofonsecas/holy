import 'package:eu_sou/app/features/study_rooms/bloc/study_room_bloc.dart';
import 'package:eu_sou/app/features/study_rooms/views/community_view.dart';
import 'package:eu_sou/app/models/study_room.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:eu_sou/app/services/study_room_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStudyRoomService extends Mock implements StudyRoomService {}

void main() {
  group('StudyRooms discovery & join flow', () {
    late MockStudyRoomService mockService;
    late StudyRoom sampleRoom;

    setUp(() {
      mockService = MockStudyRoomService();
      sampleRoom = const StudyRoom(
        roomId: 'room_public_1',
        title: 'Sala Pública 1',
        hostId: 'host_123',
        isPublic: true,
        participants: {},
      );

      // Default stubs
      when(() => mockService.events)
          .thenAnswer((_) => const Stream<ShareEvent>.empty());
      when(() => mockService.getRoomDetails(any()))
          .thenAnswer((_) async => sampleRoom);
      when(() => mockService.joinRoom(any(), any(), any()))
          .thenAnswer((_) async {});
    });

    Widget buildTestApp() {
      return RepositoryProvider<StudyRoomService>.value(
        value: mockService,
        child: BlocProvider<StudyRoomBloc>(
          create: (_) => StudyRoomBloc(mockService),
          child: const MaterialApp(
            home: CommunityView(),
          ),
        ),
      );
    }

    testWidgets('shows public rooms from RTDB stream', (tester) async {
      when(() => mockService.getPublicRooms())
          .thenAnswer((_) => Stream<List<StudyRoom>>.value([sampleRoom]));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Sala Pública 1'), findsOneWidget);
      expect(find.textContaining('Host ID: host_123'), findsOneWidget);
    });

    testWidgets('shows empty state when no public rooms', (tester) async {
      when(() => mockService.getPublicRooms())
          .thenAnswer((_) => Stream<List<StudyRoom>>.value([]));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(
          find.text('Nenhuma sala pública ativa no momento.'), findsOneWidget);
    });

    testWidgets('join flow dispatches JoinRoom and renders joined view',
        (tester) async {
      when(() => mockService.getPublicRooms())
          .thenAnswer((_) => Stream<List<StudyRoom>>.value([sampleRoom]));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap the public room tile to open join dialog
      await tester.tap(find.text('Sala Pública 1'));
      await tester.pumpAndSettle();

      // Enter display name
      await tester.enterText(find.byType(TextField), 'Tester');
      await tester.pump();

      // Confirm join
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Wait for bloc to process join
      await tester.pumpAndSettle();

      verify(() => mockService.joinRoom(
            sampleRoom.roomId,
            any(),
            'Tester',
          )).called(1);

      expect(
        find.textContaining('Você está na sala: ${sampleRoom.roomId}'),
        findsOneWidget,
      );
    });
  });
}
