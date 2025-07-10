import 'package:equatable/equatable.dart';
import '../../data/models/estoque_item.dart';

abstract class EstoqueEvent extends Equatable {
  const EstoqueEvent();

  @override
  List<Object?> get props => [];
}

// Carrega todos os itens de estoque (de todas as despensas)
class LoadTodosEstoqueItens extends EstoqueEvent {
  const LoadTodosEstoqueItens();
}

// Atualiza todos os itens de estoque
class RefreshTodosEstoqueItens extends EstoqueEvent {
  const RefreshTodosEstoqueItens();
}

// Carrega itens de uma despensa específica
class LoadEstoque extends EstoqueEvent {
  final int despensaId;

  const LoadEstoque(this.despensaId);

  @override
  List<Object?> get props => [despensaId];
}

class RefreshEstoque extends EstoqueEvent {
  final int despensaId;

  const RefreshEstoque(this.despensaId);

  @override
  List<Object?> get props => [despensaId];
}

class SearchProdutos extends EstoqueEvent {
  final String query;

  const SearchProdutos(this.query);

  @override
  List<Object?> get props => [query];
}

class AddItemToEstoque extends EstoqueEvent {
  final AdicionarEstoqueDto request;

  const AddItemToEstoque(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateEstoqueItem extends EstoqueEvent {
  final int itemId;
  final AtualizarEstoqueDto request;

  const UpdateEstoqueItem(this.itemId, this.request);

  @override
  List<Object?> get props => [itemId, request];
}

class ConsumeEstoqueItem extends EstoqueEvent {
  final int itemId;
  final ConsumirEstoqueDto request;

  const ConsumeEstoqueItem(this.itemId, this.request);

  @override
  List<Object?> get props => [itemId, request];
}

class RemoveEstoqueItem extends EstoqueEvent {
  final int itemId;

  const RemoveEstoqueItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class EstoqueItemUpdatedRealTime extends EstoqueEvent {
  final Map<String, dynamic> data;

  const EstoqueItemUpdatedRealTime(this.data);

  @override
  List<Object?> get props => [data];
}

class FilterEstoque extends EstoqueEvent {
  final String filter;

  const FilterEstoque(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SortEstoque extends EstoqueEvent {
  final String sortBy;
  final bool ascending;

  const SortEstoque(this.sortBy, this.ascending);

  @override
  List<Object?> get props => [sortBy, ascending];
}

class LoadDespensas extends EstoqueEvent {
  const LoadDespensas();
} 