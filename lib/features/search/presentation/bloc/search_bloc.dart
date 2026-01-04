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
  String _termoAtual = '';
  bool _buscarTodasVersoes = false;
  String? _idVersao;
  String? _idVersaoSelecionada;
  double _scrollOffset = 0;

  String get termoAtual => _termoAtual;
  double get scrollOffset => _scrollOffset;

  SearchBloc(this._repositorioBusca, {String? idVersao})
      : _idVersao = idVersao,
        super(BuscaInicial()) {
    on<TermoBuscaAlterado>(
      _onSearchQueryChanged,
      transformer: (events, mapper) =>
          events.debounce(_debounceDuration).switchMap(mapper),
    );
    on<AlternarBuscaTodasVersoes>(_onToggleSearchAllVersions);
    on<FiltrarPorVersao>(_onFilterByVersion);
    on<LimparBusca>(_onClearSearch);
    on<CarregarVersao>(_onLoadVersion);
    on<AtualizarScrollBusca>(_onUpdateScroll);
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
    if (_termoAtual.length >= 3) {
      await _realizarBusca(emit);
    }
  }

  Future<void> _onSearchQueryChanged(
    TermoBuscaAlterado event,
    Emitter<EstadoBusca> emit,
  ) async {
    _registrador.debug('📝 Termo de busca alterado: "${event.termo}"');
    _termoAtual = event.termo;
    if (_termoAtual.length < 3) {
      _registrador.debug(
          '⚠️ Termo muito curto (${_termoAtual.length} caracteres), mínimo 3 necessário');
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
    if (_termoAtual.length >= 3) {
      await _realizarBusca(emit);
    }
  }

  void _onClearSearch(
    LimparBusca event,
    Emitter<EstadoBusca> emit,
  ) {
    _registrador.debug('🧹 Limpando busca');
    _termoAtual = '';
    _scrollOffset = 0;
    emit(BuscaInicial());
  }

  Future<void> _realizarBusca(Emitter<EstadoBusca> emit) async {
    _registrador.info(
      '🔎 Realizando busca - Termo: "$_termoAtual", TodasVersoes: $_buscarTodasVersoes',
    );
    emit(BuscaCarregando());
    try {
      // Busca correspondência de livros em paralelo com a busca de versículos
      final buscaLivrosFuture = _repositorioBusca.corresponderLivros(
        _termoAtual,
        idVersao: _buscarTodasVersoes ? null : _idVersao,
      );

      final resultadosFuture = _buscarTodasVersoes
          ? _repositorioBusca.buscarEmTodasVersoes(_termoAtual)
          : _repositorioBusca.buscar(_termoAtual, idVersao: _idVersao);

      final resultados = await resultadosFuture;
      final correspondenciasLivros = await buscaLivrosFuture;

      // Extrair versões disponíveis dos resultados para o filtro
      final versoesDisponiveis = resultados.results
          .map((r) => r.versionAbbreviation ?? r.versionId)
          .toSet()
          .toList();
      versoesDisponiveis.sort();

      // Aplicar filtro se selecionado
      var resultadosExibidos = resultados;
      if (_idVersaoSelecionada != null) {
        final listaFiltrada = resultados.results
            .where((r) =>
                (r.versionAbbreviation ?? r.versionId) == _idVersaoSelecionada)
            .toList();
        resultadosExibidos = SearchResults(
          query: resultados.query,
          totalResults: listaFiltrada.length,
          results: listaFiltrada,
        );
      }

      _registrador.info(
          '✅ Busca emitindo estado de sucesso com ${resultadosExibidos.results.length} resultados e ${correspondenciasLivros.length} correspondências de livros (Termo: "$_termoAtual", Versão: $_idVersao)');
      emit(BuscaCarregada(
        resultados: resultadosExibidos,
        correspondenciasLivros: correspondenciasLivros,
        termo: _termoAtual,
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

    if (_termoAtual.isNotEmpty) {
      emit(BuscaCarregando());
      await _realizarBusca(emit);
    } else {
      emit(BuscaInicial());
    }
  }
}
