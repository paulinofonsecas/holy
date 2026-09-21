import 'dart:async';

import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/models/bible_version_info.dart';
import 'package:flutter/foundation.dart';

part 'bible_versions_state.dart';

/// Assinatura do loader de uma versão da Bíblia.
///
/// Por padrão aponta para `loadBibleFromUrl`, mas pode ser injetado em testes.
typedef BibleVersionLoader = Future<Bible> Function(
  String versionId, {
  void Function(DownloadProgress)? onProgress,
  BibleCacheProvider? cacheProvider,
});

/// Orquestra download, remoção e seleção das traduções da Bíblia.
///
/// Vive no nível do app para que o progresso de um download sobreviva ao
/// fechamento do sheet e não haja downloads duplicados.
class BibleVersionsCubit extends Cubit<BibleVersionsState> {
  BibleVersionsCubit({
    required BibleCacheProvider cacheProvider,
    required BibleVersionCubit versionCubit,
    WebCachePersistenceService? webCachePersistence,
    BibleVersionLoader? loader,
  })  : _cacheProvider = cacheProvider,
        _versionCubit = versionCubit,
        _webCachePersistence = webCachePersistence,
        _loader = loader ?? loadBibleFromUrl,
        super(const BibleVersionsState()) {
    _syncActiveVersion(_versionCubit.state.version);
    _versionSubscription = _versionCubit.stream.listen((state) {
      _syncActiveVersion(state.version);
    });
  }

  final BibleCacheProvider _cacheProvider;
  final BibleVersionCubit _versionCubit;
  final WebCachePersistenceService? _webCachePersistence;
  final BibleVersionLoader _loader;

  StreamSubscription<BibleVersionState>? _versionSubscription;

  /// Ids com download em andamento, para evitar chamadas duplicadas.
  final Set<String> _downloading = <String>{};

  /// Carrega o estado de todas as traduções conhecidas.
  Future<void> load() async {
    emit(state.copyWith(status: BibleVersionsStatus.loading, clearError: true));

    try {
      final cachedIds = (await _cacheProvider.getCachedVersionIds())
          .map((id) => id.toUpperCase())
          .toSet();
      final activeId = _versionCubit.state.version.id;

      emit(
        state.copyWith(
          status: BibleVersionsStatus.ready,
          versions: _buildEntries(
            cachedIds: cachedIds,
            activeId: activeId,
          ),
          clearError: true,
        ),
      );
    } catch (e, s) {
      LoggerService().error('Failed to load bible versions', e, s);
      emit(
        state.copyWith(
          status: BibleVersionsStatus.error,
          errorMessage: 'Não foi possível carregar as versões.',
        ),
      );
    }
  }

  /// Baixa a versão [id] e a deixa disponível offline.
  Future<void> download(String id) async {
    final version = BibleVersions.fromId(id);
    if (_downloading.contains(version.id)) return;

    _downloading.add(version.id);
    _updateEntry(
      version.id,
      (entry) => entry.copyWith(
        progress: DownloadProgress.downloading(downloaded: 0, total: 0),
      ),
    );

    try {
      await _loader(
        version.id,
        onProgress: (progress) => _updateEntry(
          version.id,
          (entry) => entry.copyWith(progress: progress),
        ),
        cacheProvider: _cacheProvider,
      );

      // Marca o cache também em SharedPreferences (necessário na web).
      if (kIsWeb) {
        await _webCachePersistence?.markVersionCached(version.id);
      }

      _updateEntry(
        version.id,
        (entry) => entry.copyWith(
          isDownloaded: true,
          clearProgress: true,
        ),
      );
    } catch (e, s) {
      LoggerService().error('Failed to download bible version $id', e, s);
      _updateEntry(
        version.id,
        (entry) => entry.copyWith(
          progress: DownloadProgress.error(e.toString()),
        ),
      );
    } finally {
      _downloading.remove(version.id);
    }
  }

  /// Remove a versão [id] do armazenamento local.
  ///
  /// A versão ativa não pode ser removida; retorna `false` nesse caso.
  Future<bool> delete(String id) async {
    final version = BibleVersions.fromId(id);

    if (version.id == _versionCubit.state.version.id) {
      return false;
    }

    try {
      await _cacheProvider.removeVersion(version.id);

      if (kIsWeb) {
        await _webCachePersistence?.clearVersionCacheMarker(version.id);
      }

      _updateEntry(
        version.id,
        (entry) => entry.copyWith(
          isDownloaded: false,
          clearProgress: true,
        ),
      );
      return true;
    } catch (e, s) {
      LoggerService().error('Failed to delete bible version $id', e, s);
      return false;
    }
  }

  /// Define [id] como versão ativa.
  void select(String id) {
    _versionCubit.changeVersionById(id);
  }

  List<BibleVersionInfo> _buildEntries({
    required Set<String> cachedIds,
    required String activeId,
  }) {
    return BibleVersions.values.map((version) {
      final previous = _entryFor(version.id);
      return BibleVersionInfo(
        version: version,
        isDownloaded: cachedIds.contains(version.id),
        isActive: version.id == activeId,
        progress: previous?.progress,
      );
    }).toList(growable: false);
  }

  BibleVersionInfo? _entryFor(String id) {
    for (final entry in state.versions) {
      if (entry.version.id == id) return entry;
    }
    return null;
  }

  void _updateEntry(
    String id,
    BibleVersionInfo Function(BibleVersionInfo entry) update,
  ) {
    final entries = List<BibleVersionInfo>.from(state.versions);
    final index = entries.indexWhere((entry) => entry.version.id == id);

    if (index == -1) {
      entries.add(update(BibleVersionInfo(version: BibleVersions.fromId(id))));
    } else {
      entries[index] = update(entries[index]);
    }

    emit(
      state.copyWith(
        status: BibleVersionsStatus.ready,
        versions: entries,
      ),
    );
  }

  /// Mantém `isActive` em sincronia quando a versão muda por outro caminho
  /// (ex.: toque em resultado de busca).
  void _syncActiveVersion(BibleVersions active) {
    if (state.versions.isEmpty) return;

    final entries = state.versions
        .map((entry) => entry.copyWith(isActive: entry.version == active))
        .toList(growable: false);

    emit(state.copyWith(versions: entries));
  }

  @override
  Future<void> close() async {
    await _versionSubscription?.cancel();
    _versionSubscription = null;
    return super.close();
  }
}
