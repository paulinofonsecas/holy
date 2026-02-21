import 'package:bloc/bloc.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'deeplink_event.dart';
import 'deeplink_state.dart';

class DeeplinkBloc extends Bloc<DeeplinkEvent, DeeplinkState> {
  final IDeeplinkService _deeplinkService;

  DeeplinkBloc(this._deeplinkService) : super(DeeplinkInitial()) {
    on<HandleDeeplink>(_onHandleDeeplink);
  }

  void _onHandleDeeplink(HandleDeeplink event, Emitter<DeeplinkState> emit) {
    final data = _deeplinkService.parseLink(event.uri);
    if (data != null) {
      emit(DeeplinkNavigating(data));
    }
  }
}
