import 'package:equatable/equatable.dart';
import 'produto.dart';

class EstoqueItem extends Equatable {
  final int id;
  final int despensaId;
  final int produtoId;
  final Produto produto;
  final double quantidade;
  final double quantidadeMinima;
  final String? observacoes;
  final DateTime? dataValidade;
  final DateTime dataAdicao;
  final DateTime ultimaAtualizacao;
  final bool ativo;
  final bool precisaComprar;
  final int? diasParaVencimento;
  final String status;

  const EstoqueItem({
    required this.id,
    required this.despensaId,
    required this.produtoId,
    required this.produto,
    required this.quantidade,
    required this.quantidadeMinima,
    this.observacoes,
    this.dataValidade,
    required this.dataAdicao,
    required this.ultimaAtualizacao,
    required this.ativo,
    required this.precisaComprar,
    this.diasParaVencimento,
    required this.status,
  });

  factory EstoqueItem.fromJson(Map<String, dynamic> json) {
    return EstoqueItem(
      id: json['id'] as int,
      despensaId: json['despensaId'] as int,
      produtoId: json['produtoId'] as int,
      produto: Produto.fromJson(json['produto'] as Map<String, dynamic>),
      quantidade: (json['quantidade'] as num).toDouble(),
      quantidadeMinima: (json['quantidadeMinima'] as num).toDouble(),
      observacoes: json['observacoes'] as String?,
      dataValidade: json['dataValidade'] != null 
          ? DateTime.parse(json['dataValidade'] as String)
          : null,
      dataAdicao: DateTime.parse(json['dataAdicao'] as String),
      ultimaAtualizacao: DateTime.parse(json['ultimaAtualizacao'] as String),
      ativo: json['ativo'] as bool,
      precisaComprar: json['precisaComprar'] as bool,
      diasParaVencimento: json['diasParaVencimento'] as int?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'despensaId': despensaId,
      'produtoId': produtoId,
      'produto': produto.toJson(),
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      'observacoes': observacoes,
      'dataValidade': dataValidade?.toIso8601String(),
      'dataAdicao': dataAdicao.toIso8601String(),
      'ultimaAtualizacao': ultimaAtualizacao.toIso8601String(),
      'ativo': ativo,
      'precisaComprar': precisaComprar,
      'diasParaVencimento': diasParaVencimento,
      'status': status,
    };
  }

  EstoqueItem copyWith({
    int? id,
    int? despensaId,
    int? produtoId,
    Produto? produto,
    double? quantidade,
    double? quantidadeMinima,
    String? observacoes,
    DateTime? dataValidade,
    DateTime? dataAdicao,
    DateTime? ultimaAtualizacao,
    bool? ativo,
    bool? precisaComprar,
    int? diasParaVencimento,
    String? status,
  }) {
    return EstoqueItem(
      id: id ?? this.id,
      despensaId: despensaId ?? this.despensaId,
      produtoId: produtoId ?? this.produtoId,
      produto: produto ?? this.produto,
      quantidade: quantidade ?? this.quantidade,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      observacoes: observacoes ?? this.observacoes,
      dataValidade: dataValidade ?? this.dataValidade,
      dataAdicao: dataAdicao ?? this.dataAdicao,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
      ativo: ativo ?? this.ativo,
      precisaComprar: precisaComprar ?? this.precisaComprar,
      diasParaVencimento: diasParaVencimento ?? this.diasParaVencimento,
      status: status ?? this.status,
    );
  }

  // Helpers para status
  bool get isVencido => diasParaVencimento != null && diasParaVencimento! < 0;
  bool get isVencendoEm7Dias => diasParaVencimento != null && diasParaVencimento! <= 7 && diasParaVencimento! > 0;
  bool get isQuantidadeBaixa => quantidade <= quantidadeMinima;
  bool get isEmFalta => quantidade == 0;

  // Cor baseada no status
  static const Map<String, int> statusColors = {
    'normal': 0xFF10B981, // Verde
    'baixo': 0xFFF59E0B, // Amarelo
    'vencendo': 0xFFEF4444, // Vermelho
    'vencido': 0xFF7C2D12, // Marrom
    'falta': 0xFF374151, // Cinza escuro
  };

  int get statusColor {
    if (isVencido) return statusColors['vencido']!;
    if (isVencendoEm7Dias) return statusColors['vencendo']!;
    if (isEmFalta) return statusColors['falta']!;
    if (isQuantidadeBaixa) return statusColors['baixo']!;
    return statusColors['normal']!;
  }

  @override
  List<Object?> get props => [
        id,
        despensaId,
        produtoId,
        produto,
        quantidade,
        quantidadeMinima,
        observacoes,
        dataValidade,
        dataAdicao,
        ultimaAtualizacao,
        ativo,
        precisaComprar,
        diasParaVencimento,
        status,
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