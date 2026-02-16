import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/services/logger_service.dart';
import '../../data/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

const _debounceDuration = Duration(milliseconds: 500);

class SearchBloc extends Bloc<EventoBusca, EstadoBusca> {
  final RepositorioBusca _repositorioBusca;
  final LoggerService _registrador = LoggerService();
  List<SearchQueryPart> _consultas = [const SearchQueryPart(term: '')];
  bool _buscarTodasVersoes = false;
  String? _idVersao;
  String? _idVersaoSelecionada;
  double _scrollOffset = 0;

  List<SearchQueryPart> get consultas => _consultas;
  double get scrollOffset => _scrollOffset;

  SearchBloc(this._repositorioBusca, {String? idVersao})
      : _idVersao = idVersao,
        super(BuscaInicial()) {
    on<TermoBuscaAlterado>(
      _onSearchQueryChanged,
      transformer: (events, mapper) =>
          events.debounce(_debounceDuration).switchMap(mapper),
    );
    on<AlterarOperadorJoin>(_onJoinOperatorChanged);
    on<AdicionarConsulta>(_onAddQueryPart);
    on<RemoverConsulta>(_onRemoveQueryPart);
    on<AlternarBuscaTodasVersoes>(_onToggleSearchAllVersions);
    on<FiltrarPorVersao>(_onFilterByVersion);
    on<LimparBusca>(_onClearSearch);
    on<CarregarVersao>(_onLoadVersion);
    on<AtualizarScrollBusca>(_onUpdateScroll);
    on<ReordenarConsultas>(_onReorderQueryParts);
    on<TransformarEmBuscaAvancada>(_onTransformToAdvancedSearch);
    on<PesquisaRandomica>(_onRandomSearch);
  }

  Future<void> _onRandomSearch(
    PesquisaRandomica event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.info('🎲 Realizando pesquisa randômica');
    final termos = [
      'amor',
      'fé',
      'esperança',
      'graça',
      'paz',
      'justiça',
      'misericórdia',
      'sabedoria',
      'força',
      'luz',
      'verdade',
      'vida',
      'salvação',
      'perdão',
      'alegria',
      'oração',
      'espírito',
      'coração',
      'reino',
      'promessa'
    ];
    final termoAleatorio = (List.from(termos)..shuffle()).first;

    _consultas = [SearchQueryPart(term: termoAleatorio)];
    _registrador.debug('🎲 Termo escolhido: $termoAleatorio');
    
    await _realizarBusca(emit);
  }

  Future<void> _onTransformToAdvancedSearch(
    TransformarEmBuscaAvancada event,
    Emitter<EstadoBusca> emit,
  ) async {
    if (_consultas.isEmpty || _consultas[0].term.trim().isEmpty) return;

    final query = _consultas[0].term;
    final words = query.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    if (words.length <= 1 && _consultas.length == 1) {
      // Já está em um formato "simples" ou apenas uma palavra, mas vamos garantir que o trim foi aplicado
      if (words.isNotEmpty) {
        _consultas[0] = _consultas[0].copyWith(term: words.first);
      }
    } else {
      // Pega o operador atual dos outros campos ou usa AND como padrão
      final currentOp =
          _consultas.length > 1 ? _consultas[1].operator : JoinOperator.and;

      final novasConsultas = words.indexed.map((entry) {
        final index = entry.$1;
        final word = entry.$2;
        return SearchQueryPart(
          term: word,
          operator: index == 0 ? JoinOperator.none : currentOp,
        );
      }).toList();

      _consultas = novasConsultas;
    }

    _registrador.info(
      '🔄 Busca transformada para avançada. Novos termos: ${_consultas.map((q) => q.term).join(', ')}',
    );

    if (_consultas.any((q) => q.term.length >= 3)) {
      await _realizarBusca(emit);
    } else {
      emit(BuscaCarregada(
        resultados: state is BuscaCarregada
            ? (state as BuscaCarregada).resultados
            : SearchResults(query: '', totalResults: 0, results: []),
        consultas: List.from(_consultas),
        buscarTodasVersoes: _buscarTodasVersoes,
        idVersaoSelecionada: _idVersaoSelecionada,
        versoesDisponiveis: state is BuscaCarregada
            ? (state as BuscaCarregada).versoesDisponiveis
            : const [],
      ));
    }
  }

  Future<void> _onReorderQueryParts(
    ReordenarConsultas event,
    Emitter<EstadoBusca> emit,
  ) async {
    int newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }

    final item = _consultas.removeAt(event.oldIndex);
    _consultas.insert(newIndex, item);

    // Garante que o primeiro sempre tenha operator none
    for (int i = 0; i < _consultas.length; i++) {
      if (i == 0) {
        if (_consultas[i].operator != JoinOperator.none) {
          _consultas[i] = _consultas[i].copyWith(operator: JoinOperator.none);
        }
      } else {
        // Se mudou para uma posição > 0 e era none, precisa de um operador real
        if (_consultas[i].operator == JoinOperator.none) {
          // Tenta pegar o operador dos outros campos ou usa AND
          final currentOp = _consultas.length > 1 && i != 1
              ? _consultas[1].operator
              : JoinOperator.and;
          _consultas[i] = _consultas[i].copyWith(operator: currentOp);
        }
      }
    }

    if (_consultas.any((q) => q.term.length >= 3)) {
      await _realizarBusca(emit);
    } else {
      emit(BuscaCarregada(
        resultados: state is BuscaCarregada
            ? (state as BuscaCarregada).resultados
            : SearchResults(query: '', totalResults: 0, results: []),
        consultas: List.from(_consultas),
        buscarTodasVersoes: _buscarTodasVersoes,
        idVersaoSelecionada: _idVersaoSelecionada,
      ));
    }
  }

  Future<void> _onJoinOperatorChanged(
    AlterarOperadorJoin event,
    Emitter<EstadoBusca> emit,
  ) async {
    // Para a Opção A (Global toggle), aplicamos a todos os joins (índice 1 em diante)
    for (int i = 1; i < _consultas.length; i++) {
      _consultas[i] = _consultas[i].copyWith(operator: event.operador);
    }

    if (_consultas.any((q) => q.term.length >= 3)) {
      await _realizarBusca(emit);
    } else {
      emit(BuscaCarregada(
        resultados: state is BuscaCarregada
            ? (state as BuscaCarregada).resultados
            : SearchResults(query: '', totalResults: 0, results: []),
        consultas: List.from(_consultas),
        buscarTodasVersoes: _buscarTodasVersoes,
        idVersaoSelecionada: _idVersaoSelecionada,
      ));
    }
  }

  void _onAddQueryPart(AdicionarConsulta event, Emitter<EstadoBusca> emit) {
    if (_consultas.length < 5) {
      // Usa o operador atual (ou AND por padrão) para a nova parte
      final currentOp =
          _consultas.length > 1 ? _consultas[1].operator : JoinOperator.and;
      _consultas.add(SearchQueryPart(term: '', operator: currentOp));
      emit(BuscaCarregada(
        resultados: state is BuscaCarregada
            ? (state as BuscaCarregada).resultados
            : SearchResults(query: '', totalResults: 0, results: []),
        consultas: List.from(_consultas),
        buscarTodasVersoes: _buscarTodasVersoes,
        idVersaoSelecionada: _idVersaoSelecionada,
      ));
    }
  }

  Future<void> _onRemoveQueryPart(
    RemoverConsulta event,
    Emitter<EstadoBusca> emit,
  ) async {
    if (_consultas.length > 1) {
      _consultas.removeAt(event.index);
      // If we removed the first one, ensure the new first one has JoinOperator.none
      if (event.index == 0 && _consultas.isNotEmpty) {
        _consultas[0] = _consultas[0].copyWith(operator: JoinOperator.none);
      }

      if (_consultas.any((q) => q.term.length >= 3)) {
        await _realizarBusca(emit);
      } else {
        emit(BuscaInicial());
      }
    }
  }

  void _onUpdateScroll(AtualizarScrollBusca event, Emitter<EstadoBusca> emit) {
    _scrollOffset = event.offset;
  }

  Future<void> _onFilterByVersion(
    FiltrarPorVersao event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.info('🎯 Filtrar por versão: ${event.idVersao}');
    _idVersaoSelecionada = event.idVersao;
    if (_consultas.any((q) => q.term.length >= 3)) {
      await _realizarBusca(emit);
    }
  }

  Future<void> _onSearchQueryChanged(
    TermoBuscaAlterado event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.debug(
        '📝 Termo de busca alterado no index ${event.index}: "${event.termo}"');
    if (event.index < _consultas.length) {
      _consultas[event.index] =
          _consultas[event.index].copyWith(term: event.termo);
    }

    if (_consultas.every((q) => q.term.length < 3)) {
      _registrador.debug('⚠️ Nenhum termo com comprimento suficiente (min 3)');
      emit(BuscaInicial());
      return;
    }

    await _realizarBusca(emit);
  }

  Future<void> _onToggleSearchAllVersions(
    AlternarBuscaTodasVersoes event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.info(
        '🔄 Alternar busca em todas as versões: ${event.buscarTodasVersoes}');
    _buscarTodasVersoes = event.buscarTodasVersoes;
    if (_consultas.any((q) => q.term.length >= 3)) {
      await _realizarBusca(emit);
    }
  }

  void _onClearSearch(
    LimparBusca event,
    Emitter<EstadoBusca> emit,
  ) {
    _registrador.debug('🧹 Limpando busca');
    _consultas = [const SearchQueryPart(term: '')];
    _scrollOffset = 0;
    emit(BuscaInicial());
  }

  Future<void> _realizarBusca(Emitter<EstadoBusca> emit) async {
    _registrador.info(
      '🔎 Realizando busca - Consultas: ${_consultas.length}, TodasVersoes: $_buscarTodasVersoes',
    );
    emit(BuscaCarregando());
    try {
      // For book matching, we use the first valid term
      final firstValidTerm = _consultas
          .firstWhere((q) => q.term.length >= 3,
              orElse: () => const SearchQueryPart(term: ''))
          .term;

      final correspondenciasLivrosFuture = _repositorioBusca.corresponderLivros(
        firstValidTerm,
        idVersao:
            _buscarTodasVersoes ? null : (_idVersaoSelecionada ?? _idVersao),
      );

      final resultados = await _repositorioBusca.buscaAvancada(
        _consultas,
        idVersao:
            _buscarTodasVersoes ? null : (_idVersaoSelecionada ?? _idVersao),
      );

      final correspondenciasLivros = await correspondenciasLivrosFuture;

      // Extrair versões disponíveis dos resultados para o filtro
      final versoesDisponiveis = resultados.results
          .map((r) => r.versionAbbreviation ?? r.versionId)
          .toSet()
          .toList();
      versoesDisponiveis.sort();

      emit(BuscaCarregada(
        resultados: resultados,
        correspondenciasLivros: correspondenciasLivros,
        consultas: List.from(_consultas),
        buscarTodasVersoes: _buscarTodasVersoes,
        idVersaoSelecionada: _idVersaoSelecionada,
        versoesDisponiveis: versoesDisponiveis,
      ));
    } catch (e, rastroPilha) {
      _registrador.error('❌ Erro na busca no bloc', e, rastroPilha);
      emit(BuscaErro(e.toString()));
    }
  }

  Future<void> _onLoadVersion(
    CarregarVersao event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.info(
        '📦 Carregando versão: ${event.nomeVersao} (ID: ${event.idVersao})');
    _idVersao = event.idVersao;

    if (_consultas.any((q) => q.term.isNotEmpty)) {
      emit(BuscaCarregando());
      await _realizarBusca(emit);
    } else {
      emit(BuscaInicial());
    }
  }
}
