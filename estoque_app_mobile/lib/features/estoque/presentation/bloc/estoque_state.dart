import 'package:equatable/equatable.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';

abstract class EstoqueState extends Equatable {
  const EstoqueState();

  @override
  List<Object?> get props => [];
}

class EstoqueInitial extends EstoqueState {}

class EstoqueLoading extends EstoqueState {}

class EstoqueLoaded extends EstoqueState {
  final List<EstoqueItem> items;
  final List<Produto> produtos;
  final String currentFilter;
  final String currentSort;
  final bool sortAscending;
  final int? currentDespensaId;

  const EstoqueLoaded({
    required this.items,
    required this.produtos,
    this.currentFilter = 'todos',
    this.currentSort = 'nome',
    this.sortAscending = true,
    this.currentDespensaId,
  });

  EstoqueLoaded copyWith({
    List<EstoqueItem>? items,
    List<Produto>? produtos,
    String? currentFilter,
    String? currentSort,
    bool? sortAscending,
    int? currentDespensaId,
  }) {
    return EstoqueLoaded(
      items: items ?? this.items,
      produtos: produtos ?? this.produtos,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      sortAscending: sortAscending ?? this.sortAscending,
      currentDespensaId: currentDespensaId ?? this.currentDespensaId,
    );
  }

  // Getter para itens filtrados
  List<EstoqueItem> get filteredItems {
    List<EstoqueItem> filtered = items;

    // Aplica filtro
    switch (currentFilter) {
      case 'vencidos':
        filtered = filtered.where((item) => item.isVencido).toList();
        break;
      case 'vencendo':
        filtered = filtered.where((item) => item.isVencendoEm7Dias).toList();
        break;
      case 'baixo_estoque':
        filtered = filtered.where((item) => item.isQuantidadeBaixa).toList();
        break;
      case 'em_falta':
        filtered = filtered.where((item) => item.isEmFalta).toList();
        break;
      case 'precisa_comprar':
        filtered = filtered.where((item) => item.precisaComprar).toList();
        break;
      default:
        // 'todos' - não filtra
        break;
    }

    // Aplica ordenação
    switch (currentSort) {
      case 'nome':
        filtered.sort((a, b) => sortAscending 
            ? a.produto.nome.compareTo(b.produto.nome)
            : b.produto.nome.compareTo(a.produto.nome));
        break;
      case 'quantidade':
        filtered.sort((a, b) => sortAscending 
            ? a.quantidade.compareTo(b.quantidade)
            : b.quantidade.compareTo(a.quantidade));
        break;
      case 'validade':
        filtered.sort((a, b) {
          if (a.dataValidade == null && b.dataValidade == null) return 0;
          if (a.dataValidade == null) return 1;
          if (b.dataValidade == null) return -1;
          return sortAscending 
              ? a.dataValidade!.compareTo(b.dataValidade!)
              : b.dataValidade!.compareTo(a.dataValidade!);
        });
        break;
      case 'categoria':
        filtered.sort((a, b) => sortAscending 
            ? (a.produto.categoria ?? '').compareTo(b.produto.categoria ?? '')
            : (b.produto.categoria ?? '').compareTo(a.produto.categoria ?? ''));
        break;
      case 'status':
        filtered.sort((a, b) => sortAscending 
            ? a.status.compareTo(b.status)
            : b.status.compareTo(a.status));
        break;
      default:
        // 'data_adicao' - ordenação padrão
        filtered.sort((a, b) => sortAscending 
            ? a.dataAdicao.compareTo(b.dataAdicao)
            : b.dataAdicao.compareTo(a.dataAdicao));
        break;
    }

    return filtered;
  }

  // Getters para estatísticas
  int get totalItems => items.length;
  int get itensVencidos => items.where((item) => item.isVencido).length;
  int get itensVencendo => items.where((item) => item.isVencendoEm7Dias).length;
  int get itensBaixoEstoque => items.where((item) => item.isQuantidadeBaixa).length;
  int get itensEmFalta => items.where((item) => item.isEmFalta).length;
  int get itensPrecisaComprar => items.where((item) => item.precisaComprar).length;

  @override
  List<Object?> get props => [
        items,
    produtos,
        currentFilter,
        currentSort,
        sortAscending,
        currentDespensaId,
  ];
}

class EstoqueError extends EstoqueState {
  final String message;

  const EstoqueError(this.message);

  @override
  List<Object?> get props => [message];
}

class EstoqueOperationInProgress extends EstoqueState {
  final String operation;

  const EstoqueOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

class EstoqueOperationSuccess extends EstoqueState {
  final String message;

  const EstoqueOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProdutosLoading extends EstoqueState {}

class ProdutosLoaded extends EstoqueState {
  final List<Produto> produtos;
  final String query;

  const ProdutosLoaded(this.produtos, this.query);

  @override
  List<Object?> get props => [produtos, query];
}

class ProdutosError extends EstoqueState {
  final String message;

  const ProdutosError(this.message);

  @override
  List<Object?> get props => [message];
} 