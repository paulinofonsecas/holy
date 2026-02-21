import 'package:equatable/equatable.dart';

abstract class DeeplinkEvent extends Equatable {
  const DeeplinkEvent();

  @override
  List<Object?> get props => [];
}

class HandleDeeplink extends DeeplinkEvent {
  final Uri uri;

  const HandleDeeplink(this.uri);

  @override
  List<Object?> get props => [uri];
}
