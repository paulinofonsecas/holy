part of 'search_bloc.dart';

abstract class EventoBusca extends Equatable {
  const EventoBusca();

  @override
  List<Object?> get props => [];
}

class TermoBuscaAlterado extends EventoBusca {
  final String termo;
  const TermoBuscaAlterado(this.termo);

  @override
  List<Object?> get props => [termo];
}

class AlternarBuscaTodasVersoes extends EventoBusca {
  final bool buscarTodasVersoes;
  const AlternarBuscaTodasVersoes(this.buscarTodasVersoes);

  @override
  List<Object?> get props => [buscarTodasVersoes];
}

class LimparBusca extends EventoBusca {}

class CarregarVersao extends EventoBusca {
  final String idVersao;
  final String? nomeVersao;

  const CarregarVersao({
    required this.idVersao,
    this.nomeVersao,
  });

  @override
  List<Object?> get props => [idVersao, nomeVersao];
}

class AtualizarScrollBusca extends EventoBusca {
  final double offset;
  const AtualizarScrollBusca(this.offset);

  @override
  List<Object?> get props => [offset];
}
