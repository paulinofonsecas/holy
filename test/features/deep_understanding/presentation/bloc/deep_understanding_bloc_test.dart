import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/domain/usecases/deep_understanding_service.dart';
import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eu_sou/shared/bible_models.dart';

class MockDeepUnderstandingService extends Mock
    implements DeepUnderstandingService {}

class MockAnalysisSession extends Mock implements AnalysisSession {}

void main() {
  late DeepUnderstandingBloc deepUnderstandingBloc;
  late MockDeepUnderstandingService mockDeepUnderstandingService;

  setUp(() {
    mockDeepUnderstandingService = MockDeepUnderstandingService();
    deepUnderstandingBloc = DeepUnderstandingBloc(mockDeepUnderstandingService);
  });

  tearDown(() {
    deepUnderstandingBloc.close();
  });

  group('DeepUnderstandingBloc', () {
    final mockSession = MockAnalysisSession();
    final mockVerses = [BibleVerse(number: 1, text: 'Test verse')];
    const query = 'test query';
    const bookId = 'gen';
    const chapterNumber = 1;
    const versionId = 'nvi';

    blocTest<DeepUnderstandingBloc, DeepUnderstandingState>(
      'emits [DeepUnderstandingInProgress] when StartAnalysisForVersesEvent is added and service returns a session',
      build: () {
        when(() => mockDeepUnderstandingService.startAnalysisForVerses(
                any(), any(), any(), any(), any()))
            .thenAnswer((_) => Stream.fromIterable([mockSession]));
        when(() => mockSession.id).thenReturn(1);
        when(() => mockSession.sessionId).thenReturn('test-session');
        when(() => mockSession.status).thenReturn('embedding');
        when(() => mockSession.totalItems).thenReturn(1);
        when(() => mockSession.processedItems).thenReturn(0);
        return deepUnderstandingBloc;
      },
      act: (bloc) => bloc.add(StartAnalysisForVersesEvent(
          query, mockVerses, bookId, chapterNumber, versionId)),
      expect: () => [isA<DeepUnderstandingInProgress>()],
    );

    blocTest<DeepUnderstandingBloc, DeepUnderstandingState>(
      'emits [DeepUnderstandingSuccess] when analysis is complete',
      build: () {
        when(() => mockDeepUnderstandingService.startAnalysisForVerses(
                any(), any(), any(), any(), any()))
            .thenAnswer((_) => Stream.fromIterable([mockSession]));
        when(() => mockSession.id).thenReturn(1);
        when(() => mockSession.sessionId).thenReturn('test-session');
        when(() => mockSession.status).thenReturn('completed');
        when(() => mockSession.result).thenReturn('result');
        when(() => mockSession.query).thenReturn(query);
        when(() => mockSession.embeddingDurationMillis).thenReturn(100);
        when(() => mockSession.searchDurationMillis).thenReturn(100);
        when(() => mockSession.summaryDurationMillis).thenReturn(100);
        when(() => mockSession.totalDurationMillis).thenReturn(300);
        return deepUnderstandingBloc;
      },
      act: (bloc) => bloc.add(StartAnalysisForVersesEvent(
          query, mockVerses, bookId, chapterNumber, versionId)),
      expect: () => [isA<DeepUnderstandingSuccess>()],
    );
  });
}
