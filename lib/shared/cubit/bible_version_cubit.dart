import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/services/version_persistence_service.dart';
import 'package:eu_sou/shared/models/bible_version_ref.dart';

part 'bible_version_state.dart';

class BibleVersionCubit extends Cubit<BibleVersionState> {
  /// Quando [persistence] é informado, a versão ativa é restaurada na
  /// inicialização e salva a cada troca.
  BibleVersionCubit({VersionPersistenceService? persistence})
      : _persistence = persistence,
        super(_initialState(persistence));

  final VersionPersistenceService? _persistence;

  static const BibleVersions _fallbackVersion = BibleVersions.jfaa;

  /// Prefixo que marca ids de versões da comunidade persistidos (ex.:
  /// `community:PortugueseNAA`), para distingui-los de siglas oficiais —
  /// ids desconhecidos sem o prefixo caem no fallback JFAA.
  static const String _communityPrefix = 'community:';

  /// Metadados das versões da comunidade conhecidas nesta sessão (catálogo
  /// Beblia), usados para exibir nome/idioma corretos na UI.
  final Map<String, BibleVersionRef> _communityVersions =
      <String, BibleVersionRef>{};

  static BibleVersionState _initialState(
      VersionPersistenceService? persistence) {
    final savedId = persistence?.getActiveVersionId();
    return BibleVersionState(version: _resolveSavedId(savedId));
  }

  /// Restaura a versão salva: oficiais voltam pelo enum; ids com o prefixo
  /// `community:` viram versões da comunidade (metadados enriquecidos quando
  /// o catálogo carregar); o resto cai no fallback JFAA.
  static BibleVersionRef _resolveSavedId(String? savedId) {
    final fallback = BibleVersionRef.fromOfficial(_fallbackVersion);
    if (savedId == null || savedId.trim().isEmpty) return fallback;

    if (savedId.startsWith(_communityPrefix)) {
      final id = savedId.substring(_communityPrefix.length).trim();
      if (id.isEmpty) return fallback;
      // Nome temporário = id cru; é enriquecido quando o catálogo carregar.
      return BibleVersionRef.community(id: id, title: id);
    }
    return BibleVersionRef.tryFromOfficialId(savedId) ?? fallback;
  }

  /// Define [version] como versão ativa (oficial ou da comunidade).
  void changeVersion(BibleVersionRef version) {
    if (state.version == version) return;
    _emitVersion(version, persist: true);
  }

  /// Define a versão ativa pelo [id].
  ///
  /// Ids oficiais resolvem pelo enum; os demais são tratados como versões
  /// da comunidade (com metadados do catálogo, quando já conhecidos).
  void changeVersionById(String id) {
    final official = BibleVersionRef.tryFromOfficialId(id);
    if (official != null) {
      changeVersion(official);
      return;
    }

    final normalized = id.trim();
    final community = _communityVersions[normalized.toUpperCase()] ??
        BibleVersionRef.community(id: normalized, title: normalized);
    changeVersion(community);
  }

  /// Registra metadados das versões da comunidade (catálogo Beblia).
  ///
  /// Enriquece a versão ativa quando ela é da comunidade e os metadados
  /// carregados são melhores que o fallback (id cru usado como nome).
  void registerCommunityVersions(List<BibleVersionRef> versions) {
    for (final ref in versions) {
      _communityVersions[ref.id.trim().toUpperCase()] = ref;
    }
    if (versions.isEmpty || !state.version.isCommunity) return;

    final known = _communityVersions[state.version.id.trim().toUpperCase()];
    if (known == null) return;
    if (known.name == state.version.name &&
        known.language == state.version.language &&
        known.year == state.version.year) {
      return;
    }
    // Apenas enriquece a exibição; o id não muda, então não re-persiste.
    _emitVersion(known, persist: false);
  }

  void _emitVersion(BibleVersionRef version, {required bool persist}) {
    emit(BibleVersionState(version: version));

    if (persist) {
      final savedId = version.isCommunity
          ? '$_communityPrefix${version.id}'
          : version.id;
      // Fire-and-forget: a persistência não deve atrasar a troca na UI.
      _persistence?.saveActiveVersionId(savedId);
    }
  }
}
