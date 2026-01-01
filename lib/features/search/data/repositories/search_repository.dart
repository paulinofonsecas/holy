import 'package:bible_handler/bible_handler.dart';

import '../../../../core/services/logger_service.dart';

class RepositorioBusca {
  final SqlBibleSearchProvider _provedorBusca;
  final LoggerService _registrador = LoggerService();

  RepositorioBusca(this._provedorBusca);

  Future<SearchResults> buscar(
    String termo, {
    String? idVersao,
  }) async {
    _registrador
        .info('🔍 Iniciando busca - Termo: "$termo", IdVersao: $idVersao');
    try {
      final tempoInicio = DateTime.now();
      final resultados = await _provedorBusca.search(
        query: termo,
        versionId: idVersao,
      );
      final duracao = DateTime.now().difference(tempoInicio);
      _registrador.info(
        '✅ Busca concluída - Encontrados ${resultados.results.length} resultados em ${duracao.inMilliseconds}ms',
      );
      return resultados;
    } catch (erro, rastroPilha) {
      _registrador.error('❌ Falha na busca', erro, rastroPilha);
      rethrow;
    }
  }

  Future<SearchResults> buscarEmTodasVersoes(String termo) async {
    _registrador
        .info('🔍 Iniciando busca em todas as versões - Termo: "$termo"');
    try {
      final tempoInicio = DateTime.now();
      final resultados = await _provedorBusca.search(query: termo);
      final duracao = DateTime.now().difference(tempoInicio);
      _registrador.info(
        '✅ Busca em todas as versões concluída - Encontrados ${resultados.results.length} resultados em ${duracao.inMilliseconds}ms',
      );
      return resultados;
    } catch (erro, rastroPilha) {
      _registrador.error(
          '❌ Falha na busca em todas as versões', erro, rastroPilha);
      rethrow;
    }
  }

  Future<List<Book>> corresponderLivros(String termo,
      {String? idVersao}) async {
    _registrador.info(
        '🔍 Correspondendo livros - Termo: "$termo", IdVersao: $idVersao');
    try {
      final tempoInicio = DateTime.now();
      final resultados =
          await _provedorBusca.matchBooks(query: termo, versionId: idVersao);
      final duracao = DateTime.now().difference(tempoInicio);
      _registrador.info(
        '✅ Correspondência de livros concluída - Encontradas ${resultados.length} correspondências em ${duracao.inMilliseconds}ms',
      );
      return resultados;
    } catch (erro, rastroPilha) {
      _registrador.error(
          '❌ Falha na correspondência de livros', erro, rastroPilha);
      rethrow;
    }
  }
}
