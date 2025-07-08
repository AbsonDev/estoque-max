import 'package:equatable/equatable.dart';

class EstoqueItem extends Equatable {
  final int id;
  final int despensaId;
  final int produtoId;
  final String produtoNome;
  final String? produtoMarca;
  final String? produtoCodigoBarras;
  final int quantidade;
  final int quantidadeMinima;
  final DateTime? dataValidade;
  final bool estoqueAbaixoDoMinimo;
  final String despensaNome;

  const EstoqueItem({
    required this.id,
    required this.despensaId,
    required this.produtoId,
    required this.produtoNome,
    this.produtoMarca,
    this.produtoCodigoBarras,
    required this.quantidade,
    required this.quantidadeMinima,
    this.dataValidade,
    required this.estoqueAbaixoDoMinimo,
    required this.despensaNome,
  });

  factory EstoqueItem.fromJson(Map<String, dynamic> json) {
    return EstoqueItem(
      id: (json['id'] as int?) ?? 0,
      despensaId: (json['despensa']?['id'] as int?) ?? 0,
      produtoId: (json['produtoId'] as int?) ?? 0,
      produtoNome: (json['produto'] as String?) ?? '',
      produtoMarca: json['marca'] as String?,
      produtoCodigoBarras: json['codigoBarras'] as String?,
      quantidade: (json['quantidade'] as int?) ?? 0,
      quantidadeMinima: (json['quantidadeMinima'] as int?) ?? 0,
      dataValidade: json['dataValidade'] != null 
          ? DateTime.tryParse(json['dataValidade'] as String)
          : null,
      estoqueAbaixoDoMinimo: (json['estoqueAbaixoDoMinimo'] as bool?) ?? false,
      despensaNome: (json['despensa']?['nome'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'despensaId': despensaId,
      'produtoId': produtoId,
      'produto': produtoNome,
      'marca': produtoMarca,
      'codigoBarras': produtoCodigoBarras,
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      'dataValidade': dataValidade?.toIso8601String(),
      'estoqueAbaixoDoMinimo': estoqueAbaixoDoMinimo,
      'despensa': {
        'id': despensaId,
        'nome': despensaNome,
      },
    };
  }

  bool get estaVencido => dataValidade != null && dataValidade!.isBefore(DateTime.now());
  bool get venceEm7Dias => dataValidade != null && 
      dataValidade!.isBefore(DateTime.now().add(const Duration(days: 7)));
  bool get precisaRepor => estoqueAbaixoDoMinimo;

  EstoqueItem copyWith({
    int? id,
    int? despensaId,
    int? produtoId,
    String? produtoNome,
    String? produtoMarca,
    String? produtoCodigoBarras,
    int? quantidade,
    int? quantidadeMinima,
    DateTime? dataValidade,
    bool? estoqueAbaixoDoMinimo,
    String? despensaNome,
  }) {
    return EstoqueItem(
      id: id ?? this.id,
      despensaId: despensaId ?? this.despensaId,
      produtoId: produtoId ?? this.produtoId,
      produtoNome: produtoNome ?? this.produtoNome,
      produtoMarca: produtoMarca ?? this.produtoMarca,
      produtoCodigoBarras: produtoCodigoBarras ?? this.produtoCodigoBarras,
      quantidade: quantidade ?? this.quantidade,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      dataValidade: dataValidade ?? this.dataValidade,
      estoqueAbaixoDoMinimo: estoqueAbaixoDoMinimo ?? this.estoqueAbaixoDoMinimo,
      despensaNome: despensaNome ?? this.despensaNome,
    );
  }

  @override
  List<Object?> get props => [
    id,
    despensaId,
    produtoId,
    produtoNome,
    produtoMarca,
    produtoCodigoBarras,
    quantidade,
    quantidadeMinima,
    dataValidade,
    estoqueAbaixoDoMinimo,
    despensaNome,
  ];
}

class AdicionarEstoqueDto {
  final int despensaId;
  final int produtoId;
  final int quantidade;
  final int quantidadeMinima;
  final DateTime? dataValidade;

  const AdicionarEstoqueDto({
    required this.despensaId,
    required this.produtoId,
    required this.quantidade,
    this.quantidadeMinima = 1,
    this.dataValidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'despensaId': despensaId,
      'produtoId': produtoId,
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      'dataValidade': dataValidade?.toIso8601String(),
    };
  }
}

class AtualizarEstoqueDto {
  final int quantidade;
  final int quantidadeMinima;
  final DateTime? dataValidade;

  const AtualizarEstoqueDto({
    required this.quantidade,
    this.quantidadeMinima = 1,
    this.dataValidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      'dataValidade': dataValidade?.toIso8601String(),
    };
  }
}

class ConsumirEstoqueDto {
  final int quantidadeConsumida;

  const ConsumirEstoqueDto({
    required this.quantidadeConsumida,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantidadeConsumida': quantidadeConsumida,
    };
  }
} 