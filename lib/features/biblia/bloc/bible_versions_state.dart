part of 'bible_versions_cubit.dart';

enum BibleVersionsStatus { idle, loading, ready, error }

class BibleVersionsState extends Equatable {
  const BibleVersionsState({
    this.status = BibleVersionsStatus.idle,
    this.versions = const <BibleVersionInfo>[],
    this.errorMessage,
    this.community = const <BebliaCatalogEntry>[],
    this.communityCachedIds = const <String>{},
    this.communityProgress = const <String, DownloadProgress>{},
    this.communityLoading = false,
    this.communityLoaded = false,
  });

  final BibleVersionsStatus status;
  final List<BibleVersionInfo> versions;
  final String? errorMessage;

  /// Entradas do catálogo Beblia carregadas em runtime (best-effort).
  final List<BebliaCatalogEntry> community;

  /// Ids Beblia já baixados no cache local.
  final Set<String> communityCachedIds;

  /// Progresso de download por id Beblia.
  final Map<String, DownloadProgress> communityProgress;

  /// `true` enquanto o catálogo Beblia está sendo buscado.
  final bool communityLoading;

  /// `true` após a primeira tentativa de carregar o catálogo Beblia.
  final bool communityLoaded;

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
    List<BebliaCatalogEntry>? community,
    Set<String>? communityCachedIds,
    Map<String, DownloadProgress>? communityProgress,
    bool? communityLoading,
    bool? communityLoaded,
  }) {
    return BibleVersionsState(
      status: status ?? this.status,
      versions: versions ?? this.versions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      community: community ?? this.community,
      communityCachedIds: communityCachedIds ?? this.communityCachedIds,
      communityProgress: communityProgress ?? this.communityProgress,
      communityLoading: communityLoading ?? this.communityLoading,
      communityLoaded: communityLoaded ?? this.communityLoaded,
    );
  }

  @override
  List<Object?> get props => [
        status,
        versions,
        errorMessage,
        community,
        communityCachedIds,
        communityProgress,
        communityLoading,
        communityLoaded,
      ];
}
