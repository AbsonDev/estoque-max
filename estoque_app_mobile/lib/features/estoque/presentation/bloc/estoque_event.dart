import 'package:equatable/equatable.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';

abstract class EstoqueEvent extends Equatable {
  const EstoqueEvent();

  @override
  List<Object?> get props => [];
}

// Eventos de Estoque
class CarregarEstoque extends EstoqueEvent {
  final int? despensaId;

  const CarregarEstoque({this.despensaId});

  @override
  List<Object?> get props => [despensaId];
}

class AdicionarItemEstoque extends EstoqueEvent {
  final AdicionarEstoqueDto dto;

  const AdicionarItemEstoque(this.dto);

  @override
  List<Object?> get props => [dto];
}

class AtualizarItemEstoque extends EstoqueEvent {
  final int id;
  final AtualizarEstoqueDto dto;

  const AtualizarItemEstoque(this.id, this.dto);

  @override
  List<Object?> get props => [id, dto];
}

class ConsumirItemEstoque extends EstoqueEvent {
  final int id;
  final ConsumirEstoqueDto dto;

  const ConsumirItemEstoque(this.id, this.dto);

  @override
  List<Object?> get props => [id, dto];
}

class RemoverItemEstoque extends EstoqueEvent {
  final int id;

  const RemoverItemEstoque(this.id);

  @override
  List<Object?> get props => [id];
}

class FiltrarEstoque extends EstoqueEvent {
  final String? filtro;
  final bool? apenasVencidos;
  final bool? apenasBaixoEstoque;

  const FiltrarEstoque({
    this.filtro,
    this.apenasVencidos,
    this.apenasBaixoEstoque,
  });

  @override
  List<Object?> get props => [filtro, apenasVencidos, apenasBaixoEstoque];
}

// Eventos de Produtos
class CarregarProdutos extends EstoqueEvent {
  final String? busca;

  const CarregarProdutos({this.busca});

  @override
  List<Object?> get props => [busca];
}

class CriarProduto extends EstoqueEvent {
  final CriarProdutoDto dto;

  const CriarProduto(this.dto);

  @override
  List<Object?> get props => [dto];
}

class AtualizarProduto extends EstoqueEvent {
  final int id;
  final AtualizarProdutoDto dto;

  const AtualizarProduto(this.id, this.dto);

  @override
  List<Object?> get props => [id, dto];
}

class DeletarProduto extends EstoqueEvent {
  final int id;

  const DeletarProduto(this.id);

  @override
  List<Object?> get props => [id];
}

class BuscarProdutoPorCodigoBarras extends EstoqueEvent {
  final String codigoBarras;

  const BuscarProdutoPorCodigoBarras(this.codigoBarras);

  @override
  List<Object?> get props => [codigoBarras];
}

class LimparProdutoEncontrado extends EstoqueEvent {}

class LimparErroEstoque extends EstoqueEvent {} 