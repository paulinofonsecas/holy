import 'package:eu_sou/core/deeplinks/bloc/deeplink_bloc.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_event.dart';
import 'package:eu_sou/core/deeplinks/bloc/deeplink_state.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockDeeplinkService extends Mock implements IDeeplinkService {}

void main() {
  late MockDeeplinkService mockDeeplinkService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://links.holy.app'));
  });

  setUp(() {
    mockDeeplinkService = MockDeeplinkService();
  });

  group('DeeplinkBloc', () {
    blocTest<DeeplinkBloc, DeeplinkState>(
      'emits [DeeplinkNavigating] when HandleDeeplink is added with valid uri',
      build: () {
        when(() => mockDeeplinkService.parseLink(any())).thenReturn({
          'bookId': '43',
          'chapter': '3',
          'verse': '16',
        });
        return DeeplinkBloc(mockDeeplinkService);
      },
      act: (bloc) => bloc.add(HandleDeeplink(Uri.parse('https://links.holy.app/share?v=43_3_16'))),
      expect: () => [
        isA<DeeplinkNavigating>().having((s) => s.data['bookId'], 'bookId', '43'),
      ],
    );

    blocTest<DeeplinkBloc, DeeplinkState>(
      'emits nothing when HandleDeeplink is added with invalid uri',
      build: () {
        when(() => mockDeeplinkService.parseLink(any())).thenReturn(null);
        return DeeplinkBloc(mockDeeplinkService);
      },
      act: (bloc) => bloc.add(HandleDeeplink(Uri.parse('https://links.holy.app/invalid'))),
      expect: () => [],
    );
  });
}
