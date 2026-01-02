part of 'search_bloc.dart';

abstract class EstadoBusca extends Equatable {
  const EstadoBusca();

  @override
  List<Object?> get props => [];
}

class BuscaInicial extends EstadoBusca {}

class BuscaCarregando extends EstadoBusca {}

class BuscaTermoCurto extends EstadoBusca {}

class VersaoCarregando extends EstadoBusca {
  final String nomeVersao;

  const VersaoCarregando({required this.nomeVersao});

  @override
  List<Object?> get props => [nomeVersao];
}

class BuscaCarregada extends EstadoBusca {
  final SearchResults resultados;
  final List<Book> correspondenciasLivros;
  final String termo;
  final bool buscarTodasVersoes;
  final String? idVersaoSelecionada;
  final List<String> versoesDisponiveis;

  const BuscaCarregada({
    required this.resultados,
    this.correspondenciasLivros = const [],
    required this.termo,
    required this.buscarTodasVersoes,
    this.idVersaoSelecionada,
    this.versoesDisponiveis = const [],
  });

  @override
  List<Object?> get props => [
        resultados,
        correspondenciasLivros,
        termo,
        buscarTodasVersoes,
        idVersaoSelecionada,
        versoesDisponiveis,
      ];
}

class BuscaErro extends EstadoBusca {
  final String mensagem;
  const BuscaErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
