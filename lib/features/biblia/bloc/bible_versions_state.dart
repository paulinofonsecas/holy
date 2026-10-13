part of 'bible_versions_cubit.dart';

enum BibleVersionsStatus { idle, loading, ready, error }

class BibleVersionsState extends Equatable {
  const BibleVersionsState({
    this.status = BibleVersionsStatus.idle,
    this.versions = const <BibleVersionInfo>[],
    this.errorMessage,
    this.activeVersionId,
    this.community = const <BebliaCatalogEntry>[],
    this.communityCachedIds = const <String>{},
    this.communityProgress = const <String, DownloadProgress>{},
    this.communityLoading = false,
    this.communityLoaded = false,
  });

  final BibleVersionsStatus status;
  final List<BibleVersionInfo> versions;
  final String? errorMessage;

  /// Id da versão ativa atual (oficial ou da comunidade).
  final String? activeVersionId;

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

  /// Versões da comunidade prontas para exibição/seleção: as baixadas no
  /// cache local e as com download em andamento (para mostrar progresso).
  List<BibleVersionInfo> get communityEntries {
    return community
        .where(
          (entry) =>
              communityCachedIds.contains(entry.id) ||
              communityProgress.containsKey(entry.id),
        )
        .map(
          (entry) => BibleVersionInfo(
            version: BibleVersionRef.community(
              id: entry.id,
              title: entry.title,
              language: entry.language,
              year: entry.year,
            ),
            isDownloaded: communityCachedIds.contains(entry.id),
            isActive:
                activeVersionId != null && entry.id.trim().toUpperCase() ==
                    activeVersionId!.trim().toUpperCase(),
            progress: communityProgress[entry.id],
          ),
        )
        .toList(growable: false);
  }

  /// Versões baixadas e disponíveis offline (oficiais + comunidade).
  List<BibleVersionInfo> get downloaded => [
        ...versions.where((v) => v.isDownloaded),
        ...communityEntries.where((v) => v.isDownloaded),
      ];

  /// Versões que ainda precisam ser baixadas (oficiais + downloads de
  /// comunidade em andamento, para exibir o progresso na sheet).
  List<BibleVersionInfo> get available => [
        ...versions.where((v) => !v.isDownloaded),
        ...communityEntries.where((v) => !v.isDownloaded),
      ];

  /// Quantidade de versões disponíveis offline (mostrada no header do sheet).
  int get downloadedCount => downloaded.length;

  /// `true` enquanto algum download estiver em andamento.
  bool get hasActiveDownloads =>
      versions.any((v) => v.isDownloading) ||
      communityEntries.any((v) => v.isDownloading);

  BibleVersionsState copyWith({
    BibleVersionsStatus? status,
    List<BibleVersionInfo>? versions,
    String? errorMessage,
    bool clearError = false,
    String? activeVersionId,
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
      activeVersionId: activeVersionId ?? this.activeVersionId,
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
        activeVersionId,
        community,
        communityCachedIds,
        communityProgress,
        communityLoading,
        communityLoaded,
      ];
}
