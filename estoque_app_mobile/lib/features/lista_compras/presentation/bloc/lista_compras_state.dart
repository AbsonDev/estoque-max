import 'package:equatable/equatable.dart';
import '../../data/models/lista_compras_response.dart';
import '../../data/models/lista_compras_item.dart';

abstract class ListaComprasState extends Equatable {
  const ListaComprasState();

  @override
  List<Object?> get props => [];
}

class ListaComprasInitial extends ListaComprasState {}

class ListaComprasLoading extends ListaComprasState {}

class ListaComprasLoaded extends ListaComprasState {
  final ListaComprasResponse listaCompras;
  final String currentFilter;
  final String currentSort;
  final bool sortAscending;

  const ListaComprasLoaded({
    required this.listaCompras,
    this.currentFilter = 'todos',
    this.currentSort = 'nome',
    this.sortAscending = true,
  });

  ListaComprasLoaded copyWith({
    ListaComprasResponse? listaCompras,
    String? currentFilter,
    String? currentSort,
    bool? sortAscending,
  }) {
    return ListaComprasLoaded(
      listaCompras: listaCompras ?? this.listaCompras,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  // Getter para itens filtrados
  List<ListaComprasItem> get filteredItems {
    List<ListaComprasItem> filtered = listaCompras.itensParaComprar;

    // Aplica filtro
    switch (currentFilter) {
      case 'comprados':
        filtered = filtered.where((item) => item.comprado).toList();
        break;
      case 'pendentes':
        filtered = filtered.where((item) => !item.comprado).toList();
        break;
      case 'automaticos':
        filtered = filtered.where((item) => item.isAutomatico).toList();
        break;
      case 'manuais':
        filtered = filtered.where((item) => item.isManual).toList();
        break;
      case 'preditivos':
        filtered = filtered.where((item) => item.isPreditivo).toList();
        break;
      case 'prioridade_alta':
        filtered = filtered.where((item) => item.prioridade == 1).toList();
        break;
      default:
        // 'todos' - não filtra
        break;
    }

    // Aplica ordenação
    switch (currentSort) {
      case 'nome':
        filtered.sort((a, b) => sortAscending
            ? a.nomeProduto.compareTo(b.nomeProduto)
            : b.nomeProduto.compareTo(a.nomeProduto));
        break;
      case 'tipo':
        filtered.sort((a, b) => sortAscending
            ? a.tipoItem.compareTo(b.tipoItem)
            : b.tipoItem.compareTo(a.tipoItem));
        break;
      case 'prioridade':
        filtered.sort((a, b) {
          final aPrioridade = a.prioridade ?? 99;
          final bPrioridade = b.prioridade ?? 99;
          return sortAscending
              ? aPrioridade.compareTo(bPrioridade)
              : bPrioridade.compareTo(aPrioridade);
        });
        break;
      case 'quantidade':
        filtered.sort((a, b) => sortAscending
            ? a.quantidade.compareTo(b.quantidade)
            : b.quantidade.compareTo(a.quantidade));
        break;
      case 'categoria':
        filtered.sort((a, b) => sortAscending
            ? (a.categoria ?? '').compareTo(b.categoria ?? '')
            : (b.categoria ?? '').compareTo(a.categoria ?? ''));
        break;
      case 'preco':
        filtered.sort((a, b) {
          final aPreco = a.precoEstimado ?? 0;
          final bPreco = b.precoEstimado ?? 0;
          return sortAscending
              ? aPreco.compareTo(bPreco)
              : bPreco.compareTo(aPreco);
        });
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

  // Getter para sugestões filtradas
  List<SugestaoPreditiva> get filteredSugestoes {
    List<SugestaoPreditiva> filtered = listaCompras.sugestoesPreditivas;

    // Ordena por confiança (maior primeiro)
    filtered.sort((a, b) => b.confianca.compareTo(a.confianca));

    return filtered;
  }

  // Getters para estatísticas
  int get totalItens => listaCompras.resumo.totalItens;
  int get itensComprados => listaCompras.itensParaComprar.where((item) => item.comprado).length;
  int get itensPendentes => listaCompras.itensParaComprar.where((item) => !item.comprado).length;
  int get itensAutomaticos => listaCompras.resumo.itensAutomaticos;
  int get itensManuais => listaCompras.resumo.itensManuais;
  int get itensPreditivos => listaCompras.resumo.itensPreditivos;
  int get sugestoesPendentes => listaCompras.sugestoesPreditivas.length;
  double get valorEstimado => listaCompras.resumo.valorEstimado;
  double get valorComprado => listaCompras.itensParaComprar
      .where((item) => item.comprado && item.precoEstimado != null)
      .fold(0.0, (sum, item) => sum + (item.precoEstimado! * item.quantidade));

  @override
  List<Object?> get props => [
        listaCompras,
        currentFilter,
        currentSort,
        sortAscending,
      ];
}

class ListaComprasError extends ListaComprasState {
  final String message;

  const ListaComprasError(this.message);

  @override
  List<Object?> get props => [message];
}

class ListaComprasOperationInProgress extends ListaComprasState {
  final String operation;

  const ListaComprasOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

class ListaComprasOperationSuccess extends ListaComprasState {
  final String message;

  const ListaComprasOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
} 