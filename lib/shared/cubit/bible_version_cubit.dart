import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/core/services/version_persistence_service.dart';

part 'bible_version_state.dart';

class BibleVersionCubit extends Cubit<BibleVersionState> {
  /// Quando [persistence] é informado, a versão ativa é restaurada na
  /// inicialização e salva a cada troca.
  BibleVersionCubit({VersionPersistenceService? persistence})
      : _persistence = persistence,
        super(_initialState(persistence));

  final VersionPersistenceService? _persistence;

  static const BibleVersions _fallbackVersion = BibleVersions.jfaa;

  static BibleVersionState _initialState(VersionPersistenceService? persistence) {
    final savedId = persistence?.getActiveVersionId();
    return BibleVersionState(
      version:
          savedId == null ? _fallbackVersion : BibleVersions.fromId(savedId),
    );
  }

  void changeVersion(BibleVersions e) {
    if (state.version == e) return;

    emit(BibleVersionState(version: e));
    // Fire-and-forget: a persistência não deve atrasar a troca na UI.
    _persistence?.saveActiveVersionId(e.id);
  }

  void changeVersionById(String id) {
    try {
      changeVersion(BibleVersions.fromId(id));
    } catch (_) {
      LoggerService().debug('Failed to change Bible version by id: $id');
      changeVersion(_fallbackVersion);
    }
  }
}
