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
  final List<SearchQueryPart> consultas;
  final bool buscarTodasVersoes;
  final String? idVersaoSelecionada;
  final List<String> versoesDisponiveis;
  final double initialScrollOffset;
  final SortOrder ordenacao;
  final int? limiteLivros;
  final int? limiteVersiculos;

  const BuscaCarregada({
    required this.resultados,
    this.correspondenciasLivros = const [],
    required this.consultas,
    required this.buscarTodasVersoes,
    this.idVersaoSelecionada,
    this.versoesDisponiveis = const [],
    this.initialScrollOffset = 0.0,
    this.ordenacao = SortOrder.normal,
    this.limiteLivros,
    this.limiteVersiculos,
  });

  BuscaCarregada copyWith({
    SearchResults? resultados,
    List<Book>? correspondenciasLivros,
    List<SearchQueryPart>? consultas,
    bool? buscarTodasVersoes,
    String? idVersaoSelecionada,
    List<String>? versoesDisponiveis,
    double? initialScrollOffset,
    SortOrder? ordenacao,
    int? limiteLivros,
    int? limiteVersiculos,
  }) {
    return BuscaCarregada(
      resultados: resultados ?? this.resultados,
      correspondenciasLivros: correspondenciasLivros ?? this.correspondenciasLivros,
      consultas: consultas ?? this.consultas,
      buscarTodasVersoes: buscarTodasVersoes ?? this.buscarTodasVersoes,
      idVersaoSelecionada: idVersaoSelecionada ?? this.idVersaoSelecionada,
      versoesDisponiveis: versoesDisponiveis ?? this.versoesDisponiveis,
      initialScrollOffset: initialScrollOffset ?? this.initialScrollOffset,
      ordenacao: ordenacao ?? this.ordenacao,
      limiteLivros: limiteLivros ?? this.limiteLivros,
      limiteVersiculos: limiteVersiculos ?? this.limiteVersiculos,
    );
  }

  @override
  List<Object?> get props => [
        resultados,
        correspondenciasLivros,
        consultas,
        buscarTodasVersoes,
        idVersaoSelecionada,
        versoesDisponiveis,
        initialScrollOffset,
        ordenacao,
        limiteLivros,
        limiteVersiculos,
      ];
}

class BuscaErro extends EstadoBusca {
  final String mensagem;
  const BuscaErro(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}
