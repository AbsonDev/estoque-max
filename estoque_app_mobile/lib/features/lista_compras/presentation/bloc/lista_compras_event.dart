import 'package:equatable/equatable.dart';
import '../../data/services/lista_compras_service.dart';

abstract class ListaComprasEvent extends Equatable {
  const ListaComprasEvent();

  @override
  List<Object?> get props => [];
}

class LoadListaCompras extends ListaComprasEvent {}

class RefreshListaCompras extends ListaComprasEvent {}

class AddItemManual extends ListaComprasEvent {
  final AdicionarItemManualRequest request;

  const AddItemManual(this.request);

  @override
  List<Object?> get props => [request];
}

class MarcarItemComprado extends ListaComprasEvent {
  final int itemId;

  const MarcarItemComprado(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class AceitarSugestao extends ListaComprasEvent {
  final int estoqueItemId;

  const AceitarSugestao(this.estoqueItemId);

  @override
  List<Object?> get props => [estoqueItemId];
}

class RejeitarSugestao extends ListaComprasEvent {
  final int estoqueItemId;

  const RejeitarSugestao(this.estoqueItemId);

  @override
  List<Object?> get props => [estoqueItemId];
}

class RemoverItem extends ListaComprasEvent {
  final int itemId;

  const RemoverItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class AtualizarQuantidadeItem extends ListaComprasEvent {
  final int itemId;
  final double quantidade;

  const AtualizarQuantidadeItem(this.itemId, this.quantidade);

  @override
  List<Object?> get props => [itemId, quantidade];
}

class LimparItensComprados extends ListaComprasEvent {}

class FilterItens extends ListaComprasEvent {
  final String filter;

  const FilterItens(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SortItens extends ListaComprasEvent {
  final String sortBy;
  final bool ascending;

  const SortItens(this.sortBy, this.ascending);

  @override
  List<Object?> get props => [sortBy, ascending];
}

class ListaComprasUpdatedRealTime extends ListaComprasEvent {
  final Map<String, dynamic> data;

  const ListaComprasUpdatedRealTime(this.data);

  @override
  List<Object?> get props => [data];
} 