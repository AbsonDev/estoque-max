import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/estoque_service.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';
import 'estoque_event.dart';
import 'estoque_state.dart';

class EstoqueBloc extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueService _estoqueService;

  EstoqueBloc(this._estoqueService) : super(EstoqueInitial()) {
    on<LoadEstoque>(_onLoadEstoque);
    on<RefreshEstoque>(_onRefreshEstoque);
    on<SearchProdutos>(_onSearchProdutos);
    on<AddItemToEstoque>(_onAddItemToEstoque);
    on<UpdateEstoqueItem>(_onUpdateEstoqueItem);
    on<ConsumeEstoqueItem>(_onConsumeEstoqueItem);
    on<RemoveEstoqueItem>(_onRemoveEstoqueItem);
    on<EstoqueItemUpdatedRealTime>(_onEstoqueItemUpdatedRealTime);
    on<FilterEstoque>(_onFilterEstoque);
    on<SortEstoque>(_onSortEstoque);
  }

  Future<void> _onLoadEstoque(LoadEstoque event, Emitter<EstoqueState> emit) async {
    emit(EstoqueLoading());

    try {
      final items = await _estoqueService.getEstoqueDespensa(event.despensaId);
      final produtos = await _estoqueService.buscarProdutos();
      
      emit(EstoqueLoaded(
        items: items,
        produtos: produtos,
        currentDespensaId: event.despensaId,
      ));
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onRefreshEstoque(RefreshEstoque event, Emitter<EstoqueState> emit) async {
    if (state is EstoqueLoaded) {
      final currentState = state as EstoqueLoaded;
      
      try {
        final items = await _estoqueService.getEstoqueDespensa(event.despensaId);
        
        emit(currentState.copyWith(
          items: items,
          currentDespensaId: event.despensaId,
        ));
    } catch (e) {
      emit(EstoqueError(e.toString()));
      }
    } else {
      add(LoadEstoque(event.despensaId));
    }
  }

  Future<void> _onSearchProdutos(SearchProdutos event, Emitter<EstoqueState> emit) async {
    emit(ProdutosLoading());

    try {
      final produtos = await _estoqueService.buscarProdutos(query: event.query);
      emit(ProdutosLoaded(produtos, event.query));
    } catch (e) {
      emit(ProdutosError(e.toString()));
    }
  }

  Future<void> _onAddItemToEstoque(AddItemToEstoque event, Emitter<EstoqueState> emit) async {
    emit(const EstoqueOperationInProgress('Adicionando item...'));

    try {
      final newItem = await _estoqueService.adicionarItem(event.despensaId, event.request);
      
      if (state is EstoqueLoaded) {
        final currentState = state as EstoqueLoaded;
        final updatedItems = List<EstoqueItem>.from(currentState.items)..add(newItem);
        
        emit(currentState.copyWith(items: updatedItems));
        emit(const EstoqueOperationSuccess('Item adicionado com sucesso!'));
      } else {
        emit(const EstoqueOperationSuccess('Item adicionado com sucesso!'));
        add(LoadEstoque(event.despensaId));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onUpdateEstoqueItem(UpdateEstoqueItem event, Emitter<EstoqueState> emit) async {
    emit(const EstoqueOperationInProgress('Atualizando item...'));

    try {
      final updatedItem = await _estoqueService.atualizarItem(event.itemId, event.request);
      
      if (state is EstoqueLoaded) {
        final currentState = state as EstoqueLoaded;
        final updatedItems = currentState.items.map((item) {
          return item.id == event.itemId ? updatedItem : item;
        }).toList();
        
        emit(currentState.copyWith(items: updatedItems));
        emit(const EstoqueOperationSuccess('Item atualizado com sucesso!'));
      } else {
        emit(const EstoqueOperationSuccess('Item atualizado com sucesso!'));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onConsumeEstoqueItem(ConsumeEstoqueItem event, Emitter<EstoqueState> emit) async {
    emit(const EstoqueOperationInProgress('Consumindo item...'));

    try {
      final updatedItem = await _estoqueService.consumirItem(event.itemId, event.request);
      
      if (state is EstoqueLoaded) {
        final currentState = state as EstoqueLoaded;
        final updatedItems = currentState.items.map((item) {
          return item.id == event.itemId ? updatedItem : item;
        }).toList();
        
        emit(currentState.copyWith(items: updatedItems));
        emit(const EstoqueOperationSuccess('Item consumido com sucesso!'));
      } else {
        emit(const EstoqueOperationSuccess('Item consumido com sucesso!'));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onRemoveEstoqueItem(RemoveEstoqueItem event, Emitter<EstoqueState> emit) async {
    emit(const EstoqueOperationInProgress('Removendo item...'));

    try {
      await _estoqueService.removerItem(event.itemId);
      
      if (state is EstoqueLoaded) {
        final currentState = state as EstoqueLoaded;
        final updatedItems = currentState.items.where((item) => item.id != event.itemId).toList();
        
        emit(currentState.copyWith(items: updatedItems));
        emit(const EstoqueOperationSuccess('Item removido com sucesso!'));
      } else {
        emit(const EstoqueOperationSuccess('Item removido com sucesso!'));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onEstoqueItemUpdatedRealTime(EstoqueItemUpdatedRealTime event, Emitter<EstoqueState> emit) async {
    if (state is EstoqueLoaded) {
      final currentState = state as EstoqueLoaded;
      
      try {
        // Converte os dados do SignalR para EstoqueItem
        final updatedItem = EstoqueItem.fromJson(event.data);
        
        // Atualiza ou adiciona o item na lista
        final updatedItems = List<EstoqueItem>.from(currentState.items);
        final existingIndex = updatedItems.indexWhere((item) => item.id == updatedItem.id);
        
        if (existingIndex != -1) {
          updatedItems[existingIndex] = updatedItem;
        } else {
          updatedItems.add(updatedItem);
        }
        
        emit(currentState.copyWith(items: updatedItems));
        
        debugPrint('Item atualizado via SignalR: ${updatedItem.produto.nome}');
      } catch (e) {
        debugPrint('Erro ao processar atualização em tempo real: $e');
      }
    }
  }

  Future<void> _onFilterEstoque(FilterEstoque event, Emitter<EstoqueState> emit) async {
    if (state is EstoqueLoaded) {
      final currentState = state as EstoqueLoaded;
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }

  Future<void> _onSortEstoque(SortEstoque event, Emitter<EstoqueState> emit) async {
    if (state is EstoqueLoaded) {
      final currentState = state as EstoqueLoaded;
      emit(currentState.copyWith(
        currentSort: event.sortBy,
        sortAscending: event.ascending,
      ));
    }
  }
} 