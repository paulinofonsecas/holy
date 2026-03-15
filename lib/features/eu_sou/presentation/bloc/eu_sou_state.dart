import 'package:equatable/equatable.dart';

import '../../data/models/analysis_session_preview.dart';
import '../../domain/models/daily_reflection.dart';
import '../../domain/models/user_stats.dart';

abstract class EuSouState extends Equatable {
  const EuSouState();
  @override
  List<Object?> get props => [];
}

class EuSouInitial extends EuSouState {
  const EuSouInitial();
}

class EuSouLoading extends EuSouState {
  const EuSouLoading();
}

class EuSouLoaded extends EuSouState {
  final DailyReflection? reflection;
  final UserStats? stats;
  final List<AnalysisSessionPreview>? recentStudies;

  const EuSouLoaded({
    this.reflection,
    this.stats,
    this.recentStudies,
  });

  @override
  List<Object?> get props => [reflection, stats, recentStudies];
}

class EuSouError extends EuSouState {
  final String message;
  const EuSouError(this.message);
  @override
  List<Object?> get props => [message];
}
