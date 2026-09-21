part of 'bible_versions_cubit.dart';

enum BibleVersionsStatus { idle, loading, ready, error }

class BibleVersionsState extends Equatable {
  const BibleVersionsState({
    this.status = BibleVersionsStatus.idle,
    this.versions = const <BibleVersionInfo>[],
    this.errorMessage,
  });

  final BibleVersionsStatus status;
  final List<BibleVersionInfo> versions;
  final String? errorMessage;

  /// Versões baixadas e disponíveis offline.
  List<BibleVersionInfo> get downloaded =>
      versions.where((v) => v.isDownloaded).toList(growable: false);

  /// Versões que ainda precisam ser baixadas.
  List<BibleVersionInfo> get available =>
      versions.where((v) => !v.isDownloaded).toList(growable: false);

  /// Quantidade de versões disponíveis offline (mostrada no header do sheet).
  int get downloadedCount => downloaded.length;

  /// `true` enquanto algum download estiver em andamento.
  bool get hasActiveDownloads => versions.any((v) => v.isDownloading);

  BibleVersionsState copyWith({
    BibleVersionsStatus? status,
    List<BibleVersionInfo>? versions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BibleVersionsState(
      status: status ?? this.status,
      versions: versions ?? this.versions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, versions, errorMessage];
}
