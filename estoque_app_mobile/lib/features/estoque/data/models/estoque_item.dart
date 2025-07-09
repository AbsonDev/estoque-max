import 'package:equatable/equatable.dart';

class EstoqueItem extends Equatable {
  final int id;
  final String produto;
  final String? marca;
  final String? codigoBarras;
  final double quantidade;
  final double quantidadeMinima;
  final bool estoqueAbaixoDoMinimo;
  final DateTime? dataValidade;
  final Map<String, dynamic> despensa;

  const EstoqueItem({
    required this.id,
    required this.produto,
    this.marca,
    this.codigoBarras,
    required this.quantidade,
    required this.quantidadeMinima,
    required this.estoqueAbaixoDoMinimo,
    this.dataValidade,
    required this.despensa,
  });

  factory EstoqueItem.fromJson(Map<String, dynamic> json) {
    return EstoqueItem(
      id: json['id'] as int? ?? 0,
      produto: json['produto'] as String? ?? 'Produto não informado',
      marca: json['marca'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      quantidadeMinima: (json['quantidadeMinima'] as num?)?.toDouble() ?? 1.0,
      estoqueAbaixoDoMinimo: json['estoqueAbaixoDoMinimo'] as bool? ?? false,
      dataValidade: json['dataValidade'] != null
          ? DateTime.tryParse(json['dataValidade'] as String)
          : null,
      despensa: json['despensa'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produto': produto,
      'marca': marca,
      'codigoBarras': codigoBarras,
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      'estoqueAbaixoDoMinimo': estoqueAbaixoDoMinimo,
      'dataValidade': dataValidade?.toIso8601String(),
      'despensa': despensa,
    };
  }

  EstoqueItem copyWith({
    int? id,
    String? produto,
    String? marca,
    String? codigoBarras,
    double? quantidade,
    double? quantidadeMinima,
    bool? estoqueAbaixoDoMinimo,
    DateTime? dataValidade,
    Map<String, dynamic>? despensa,
  }) {
    return EstoqueItem(
      id: id ?? this.id,
      produto: produto ?? this.produto,
      marca: marca ?? this.marca,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      quantidade: quantidade ?? this.quantidade,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      estoqueAbaixoDoMinimo:
          estoqueAbaixoDoMinimo ?? this.estoqueAbaixoDoMinimo,
      dataValidade: dataValidade ?? this.dataValidade,
      despensa: despensa ?? this.despensa,
    );
  }

  // Helpers para status
  bool get isVencido =>
      dataValidade != null && dataValidade!.isBefore(DateTime.now());
  bool get isVencendoEm7Dias =>
      dataValidade != null &&
      dataValidade!.isBefore(DateTime.now().add(const Duration(days: 7))) &&
      dataValidade!.isAfter(DateTime.now());
  bool get isQuantidadeBaixa => estoqueAbaixoDoMinimo;
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

  // Helper para nome da despensa
  String get despensaNome => despensa['nome'] as String? ?? 'Despensa';
  int get despensaId => despensa['id'] as int? ?? 0;

  @override
  List<Object?> get props => [
    id,
    produto,
    marca,
    codigoBarras,
    quantidade,
    quantidadeMinima,
    estoqueAbaixoDoMinimo,
    dataValidade,
    despensa,
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

  const ConsumirEstoqueDto({required this.quantidadeConsumida});

  Map<String, dynamic> toJson() {
    return {'quantidadeConsumida': quantidadeConsumida};
  }
}
