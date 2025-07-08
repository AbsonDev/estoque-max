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
  final List<EstoqueItem> itens;
  final List<EstoqueItem> itensFiltrados;
  final List<Produto> produtos;
  final Produto? produtoEncontrado;
  final String? filtroAtual;
  final bool apenasVencidos;
  final bool apenasBaixoEstoque;
  final int? despensaIdAtual;

  const EstoqueLoaded({
    required this.itens,
    required this.itensFiltrados,
    required this.produtos,
    this.produtoEncontrado,
    this.filtroAtual,
    this.apenasVencidos = false,
    this.apenasBaixoEstoque = false,
    this.despensaIdAtual,
  });

  EstoqueLoaded copyWith({
    List<EstoqueItem>? itens,
    List<EstoqueItem>? itensFiltrados,
    List<Produto>? produtos,
    Produto? produtoEncontrado,
    String? filtroAtual,
    bool? apenasVencidos,
    bool? apenasBaixoEstoque,
    int? despensaIdAtual,
    bool clearProdutoEncontrado = false,
  }) {
    return EstoqueLoaded(
      itens: itens ?? this.itens,
      itensFiltrados: itensFiltrados ?? this.itensFiltrados,
      produtos: produtos ?? this.produtos,
      produtoEncontrado: clearProdutoEncontrado ? null : (produtoEncontrado ?? this.produtoEncontrado),
      filtroAtual: filtroAtual ?? this.filtroAtual,
      apenasVencidos: apenasVencidos ?? this.apenasVencidos,
      apenasBaixoEstoque: apenasBaixoEstoque ?? this.apenasBaixoEstoque,
      despensaIdAtual: despensaIdAtual ?? this.despensaIdAtual,
    );
  }

  // Estatísticas úteis
  int get totalItens => itens.length;
  int get itensVencidos => itens.where((item) => item.estaVencido).length;
  int get itensVencendo => itens.where((item) => item.venceEm7Dias && !item.estaVencido).length;
  int get itensBaixoEstoque => itens.where((item) => item.precisaRepor).length;

  @override
  List<Object?> get props => [
    itens,
    itensFiltrados,
    produtos,
    produtoEncontrado,
    filtroAtual,
    apenasVencidos,
    apenasBaixoEstoque,
    despensaIdAtual,
  ];
}

class EstoqueError extends EstoqueState {
  final String message;

  const EstoqueError(this.message);

  @override
  List<Object?> get props => [message];
}

class EstoqueOperationLoading extends EstoqueState {
  final String operation;

  const EstoqueOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class EstoqueOperationSuccess extends EstoqueState {
  final String message;

  const EstoqueOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
} 