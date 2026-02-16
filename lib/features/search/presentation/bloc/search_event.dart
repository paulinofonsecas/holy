part of 'search_bloc.dart';

abstract class EventoBusca extends Equatable {
  const EventoBusca();

  @override
  List<Object?> get props => [];
}

class TermoBuscaAlterado extends EventoBusca {
  final String termo;
  final int index;

  const TermoBuscaAlterado(this.termo, {this.index = 0});

  @override
  List<Object?> get props => [termo, index];
}

class AlterarOperadorJoin extends EventoBusca {
  final int index;
  final JoinOperator operador;

  const AlterarOperadorJoin(this.index, this.operador);

  @override
  List<Object?> get props => [index, operador];
}

class AdicionarConsulta extends EventoBusca {}

class RemoverConsulta extends EventoBusca {
  final int index;
  const RemoverConsulta(this.index);

  @override
  List<Object?> get props => [index];
}

class AlternarBuscaTodasVersoes extends EventoBusca {
  final bool buscarTodasVersoes;
  const AlternarBuscaTodasVersoes(this.buscarTodasVersoes);

  @override
  List<Object?> get props => [buscarTodasVersoes];
}

class LimparBusca extends EventoBusca {}

class FiltrarPorVersao extends EventoBusca {
  final String? idVersao;
  const FiltrarPorVersao(this.idVersao);

  @override
  List<Object?> get props => [idVersao];
}

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

class ReordenarConsultas extends EventoBusca {
  final int oldIndex;
  final int newIndex;

  const ReordenarConsultas(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class TransformarEmBuscaAvancada extends EventoBusca {}

class PesquisaRandomica extends EventoBusca {}

class ForcarRestauracaoScrollBusca extends EventoBusca {}
