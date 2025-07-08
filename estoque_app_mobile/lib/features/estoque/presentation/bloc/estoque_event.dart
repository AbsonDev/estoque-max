import 'package:equatable/equatable.dart';
import '../../data/services/estoque_service.dart';

abstract class EstoqueEvent extends Equatable {
  const EstoqueEvent();

  @override
  List<Object?> get props => [];
}

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
  final int despensaId;
  final AdicionarItemRequest request;

  const AddItemToEstoque(this.despensaId, this.request);

  @override
  List<Object?> get props => [despensaId, request];
}

class UpdateEstoqueItem extends EstoqueEvent {
  final int itemId;
  final AtualizarItemRequest request;

  const UpdateEstoqueItem(this.itemId, this.request);

  @override
  List<Object?> get props => [itemId, request];
}

class ConsumeEstoqueItem extends EstoqueEvent {
  final int itemId;
  final ConsumirItemRequest request;

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