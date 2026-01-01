import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/logger_service.dart';
import '../../data/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<EventoBusca, EstadoBusca> {
  final RepositorioBusca _repositorioBusca;
  final LoggerService _registrador = LoggerService();
  String _termoAtual = '';
  bool _buscarTodasVersoes = false;
  String? _idVersao;

  SearchBloc(this._repositorioBusca, {String? idVersao})
      : _idVersao = idVersao,
        super(BuscaInicial()) {
    on<TermoBuscaAlterado>(_onSearchQueryChanged);
    on<AlternarBuscaTodasVersoes>(_onToggleSearchAllVersions);
    on<LimparBusca>(_onClearSearch);
    on<CarregarVersao>(_onLoadVersion);
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

      _registrador.info(
          '✅ Busca emitindo estado de sucesso com ${resultados.results.length} resultados e ${correspondenciasLivros.length} correspondências de livros (Termo: "$_termoAtual", Versão: $_idVersao)');
      emit(BuscaCarregada(
        resultados: resultados,
        correspondenciasLivros: correspondenciasLivros,
        termo: _termoAtual,
        buscarTodasVersoes: _buscarTodasVersoes,
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
    emit(VersaoCarregando(nomeVersao: event.nomeVersao));

    try {
      // Simula o carregamento da versão com um pequeno atraso para permitir que a UI atualize
      await Future.delayed(const Duration(milliseconds: 500));

      _registrador.info('✅ Versão ${event.nomeVersao} carregada com sucesso');
      // Após o carregamento da versão, volta ao estado inicial para preparar para nova busca
      emit(BuscaInicial());
    } catch (e, rastroPilha) {
      _registrador.error(
          '❌ Erro ao carregar versão ${event.nomeVersao}', e, rastroPilha);
      emit(BuscaErro('Falha ao carregar versão: ${event.nomeVersao}'));
    }
  }
}
