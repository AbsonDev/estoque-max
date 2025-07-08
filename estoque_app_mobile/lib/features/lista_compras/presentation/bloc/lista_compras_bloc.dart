import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/lista_compras_models.dart';
import '../../data/services/lista_compras_service.dart';

// Events
abstract class ListaComprasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListaCompras extends ListaComprasEvent {}

class AcceptAISuggestion extends ListaComprasEvent {
  final int estoqueItemId;

  AcceptAISuggestion({required this.estoqueItemId});

  @override
  List<Object?> get props => [estoqueItemId];
}

class AddManualItem extends ListaComprasEvent {
  final String nome;
  final String categoria;
  final int quantidade;
  final double valor;
  final String? observacoes;

  AddManualItem({
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.valor,
    this.observacoes,
  });

  @override
  List<Object?> get props => [nome, categoria, quantidade, valor, observacoes];
}

class ToggleItemComprado extends ListaComprasEvent {
  final int itemId;

  ToggleItemComprado({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class RemoveItem extends ListaComprasEvent {
  final int itemId;

  RemoveItem({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class UpdateItem extends ListaComprasEvent {
  final int itemId;
  final String? nome;
  final String? categoria;
  final int? quantidade;
  final double? valor;
  final String? observacoes;

  UpdateItem({
    required this.itemId,
    this.nome,
    this.categoria,
    this.quantidade,
    this.valor,
    this.observacoes,
  });

  @override
  List<Object?> get props => [itemId, nome, categoria, quantidade, valor, observacoes];
}

class LoadHistorico extends ListaComprasEvent {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final int? limit;

  LoadHistorico({
    this.dataInicio,
    this.dataFim,
    this.limit,
  });

  @override
  List<Object?> get props => [dataInicio, dataFim, limit];
}

class RefreshListaCompras extends ListaComprasEvent {}

// States
abstract class ListaComprasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListaComprasInitial extends ListaComprasState {}

class ListaComprasLoading extends ListaComprasState {}

class ListaComprasLoaded extends ListaComprasState {
  final ListaComprasResponse lista;

  ListaComprasLoaded(this.lista);

  @override
  List<Object?> get props => [lista];
}

class ListaComprasError extends ListaComprasState {
  final String message;

  ListaComprasError(this.message);

  @override
  List<Object?> get props => [message];
}

class ListaComprasUpdating extends ListaComprasState {
  final ListaComprasResponse currentLista;

  ListaComprasUpdating(this.currentLista);

  @override
  List<Object?> get props => [currentLista];
}

class HistoricoLoaded extends ListaComprasState {
  final List<HistoricoCompra> historico;

  HistoricoLoaded(this.historico);

  @override
  List<Object?> get props => [historico];
}

class ItemAdded extends ListaComprasState {
  final ListaComprasItem item;

  ItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

// BLoC
class ListaComprasBloc extends Bloc<ListaComprasEvent, ListaComprasState> {
  final ListaComprasService _listaComprasService;
  
  ListaComprasBloc(this._listaComprasService) : super(ListaComprasInitial()) {
    on<LoadListaCompras>(_onLoadListaCompras);
    on<AcceptAISuggestion>(_onAcceptAISuggestion);
    on<AddManualItem>(_onAddManualItem);
    on<ToggleItemComprado>(_onToggleItemComprado);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateItem>(_onUpdateItem);
    on<LoadHistorico>(_onLoadHistorico);
    on<RefreshListaCompras>(_onRefreshListaCompras);
  }

  Future<void> _onLoadListaCompras(
    LoadListaCompras event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      if (state is! ListaComprasLoaded) {
        emit(ListaComprasLoading());
      }
      
      final lista = await _listaComprasService.getListaCompras();
      emit(ListaComprasLoaded(lista));
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onAcceptAISuggestion(
    AcceptAISuggestion event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ListaComprasLoaded) {
        emit(ListaComprasUpdating(currentState.lista));
        
        await _listaComprasService.aceitarSugestao(event.estoqueItemId);
        
        // Reload the list to get updated data
        final lista = await _listaComprasService.getListaCompras();
        emit(ListaComprasLoaded(lista));
      }
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onAddManualItem(
    AddManualItem event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ListaComprasLoaded) {
        emit(ListaComprasUpdating(currentState.lista));
        
        final request = AddManualItemRequest(
          nome: event.nome,
          categoria: event.categoria,
          quantidade: event.quantidade,
          valor: event.valor,
          observacoes: event.observacoes,
        );
        
        final newItem = await _listaComprasService.adicionarItemManual(request);
        
        // Reload the list to get updated data
        final lista = await _listaComprasService.getListaCompras();
        emit(ListaComprasLoaded(lista));
      }
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onToggleItemComprado(
    ToggleItemComprado event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ListaComprasLoaded) {
        emit(ListaComprasUpdating(currentState.lista));
        
        await _listaComprasService.marcarComoComprado(event.itemId);
        
        // Reload the list to get updated data
        final lista = await _listaComprasService.getListaCompras();
        emit(ListaComprasLoaded(lista));
      }
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onRemoveItem(
    RemoveItem event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ListaComprasLoaded) {
        emit(ListaComprasUpdating(currentState.lista));
        
        await _listaComprasService.removerItem(event.itemId);
        
        // Reload the list to get updated data
        final lista = await _listaComprasService.getListaCompras();
        emit(ListaComprasLoaded(lista));
      }
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ListaComprasLoaded) {
        emit(ListaComprasUpdating(currentState.lista));
        
        await _listaComprasService.atualizarItem(
          event.itemId,
          nome: event.nome,
          categoria: event.categoria,
          quantidade: event.quantidade,
          valor: event.valor,
          observacoes: event.observacoes,
        );
        
        // Reload the list to get updated data
        final lista = await _listaComprasService.getListaCompras();
        emit(ListaComprasLoaded(lista));
      }
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onLoadHistorico(
    LoadHistorico event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final historico = await _listaComprasService.getHistorico(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        limit: event.limit,
      );
      emit(HistoricoLoaded(historico));
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }

  Future<void> _onRefreshListaCompras(
    RefreshListaCompras event,
    Emitter<ListaComprasState> emit,
  ) async {
    try {
      final lista = await _listaComprasService.getListaCompras();
      emit(ListaComprasLoaded(lista));
    } catch (e) {
      emit(ListaComprasError(e.toString()));
    }
  }
} 