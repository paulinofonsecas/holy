import 'package:equatable/equatable.dart';

abstract class DeeplinkState extends Equatable {
  const DeeplinkState();
  
  @override
  List<Object?> get props => [];
}

class DeeplinkInitial extends DeeplinkState {}

class DeeplinkNavigating extends DeeplinkState {
  final Map<String, String> data;
  final DateTime timestamp;

  DeeplinkNavigating(this.data) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [data, timestamp];
}
