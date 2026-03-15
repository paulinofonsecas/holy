import 'package:equatable/equatable.dart';

abstract class EuSouEvent extends Equatable {
  const EuSouEvent();
  @override
  List<Object?> get props => [];
}

class LoadEuSou extends EuSouEvent {
  final String versionId;
  const LoadEuSou({required this.versionId});
  @override
  List<Object?> get props => [versionId];
}

class RefreshEuSou extends EuSouEvent {
  final String versionId;
  const RefreshEuSou({required this.versionId});
  @override
  List<Object?> get props => [versionId];
}
