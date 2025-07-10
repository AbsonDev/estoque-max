import 'package:equatable/equatable.dart';

class EstoqueItem extends Equatable {
  final int id;
  final String produto;
  final String? marca;
  final String? codigoBarras;
  final int quantidade;
  final int quantidadeMinima;
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
      quantidade: json['quantidade'] as int? ?? 0,
      quantidadeMinima: json['quantidadeMinima'] as int? ?? 1,
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
    int? quantidade,
    int? quantidadeMinima,
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
  final int? produtoId; // Agora opcional
  final String? nomeProduto; // Novo campo para nome do produto
  final int quantidade;
  final int quantidadeMinima;
  final DateTime? dataValidade;

  const AdicionarEstoqueDto({
    required this.despensaId,
    this.produtoId,
    this.nomeProduto,
    required this.quantidade,
    this.quantidadeMinima = 1,
    this.dataValidade,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'despensaId': despensaId,
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
    };

    if (produtoId != null) {
      data['produtoId'] = produtoId;
    }
    if (nomeProduto != null && nomeProduto!.isNotEmpty) {
      data['nomeProduto'] = nomeProduto;
    }
    if (dataValidade != null) {
      data['dataValidade'] = dataValidade!.toIso8601String();
    }

    return data;
  }

  // Validação
  bool get isValid {
    return (produtoId != null ||
            (nomeProduto != null && nomeProduto!.isNotEmpty)) &&
        quantidade > 0 &&
        quantidadeMinima >= 0;
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

// Modelo para detalhes completos de um item de estoque
class EstoqueItemDetalhes extends Equatable {
  final int id;
  final ProdutoDetalhes produto;
  final DespensaDetalhes despensa;
  final int quantidade;
  final int quantidadeMinima;
  final bool estoqueAbaixoDoMinimo;
  final DateTime? dataValidade;
  final DateTime dataAdicao;
  final int? diasParaVencer;
  final String statusVencimento;
  final double? preco;
  final EstatisticasConsumo estatisticas;
  final List<HistoricoConsumo> historicoConsumo;
  final List<AlertaDetalhado> alertas;
  final List<RecomendacaoDetalhada> recomendacoes;
  final DateTime dataConsulta;

  const EstoqueItemDetalhes({
    required this.id,
    required this.produto,
    required this.despensa,
    required this.quantidade,
    required this.quantidadeMinima,
    required this.estoqueAbaixoDoMinimo,
    this.dataValidade,
    required this.dataAdicao,
    this.diasParaVencer,
    required this.statusVencimento,
    this.preco,
    required this.estatisticas,
    required this.historicoConsumo,
    required this.alertas,
    required this.recomendacoes,
    required this.dataConsulta,
  });

  factory EstoqueItemDetalhes.fromJson(Map<String, dynamic> json) {
    return EstoqueItemDetalhes(
      id: json['id'] as int,
      produto: ProdutoDetalhes.fromJson(
        json['produto'] as Map<String, dynamic>,
      ),
      despensa: DespensaDetalhes.fromJson(
        json['despensa'] as Map<String, dynamic>,
      ),
      quantidade: json['quantidade'] as int,
      quantidadeMinima: json['quantidadeMinima'] as int,
      estoqueAbaixoDoMinimo: json['estoqueAbaixoDoMinimo'] as bool,
      dataValidade: json['dataValidade'] != null
          ? DateTime.parse(json['dataValidade'] as String)
          : null,
      dataAdicao: DateTime.parse(json['dataAdicao'] as String),
      diasParaVencer: json['diasParaVencer'] as int?,
      statusVencimento: json['statusVencimento'] as String,
      preco: (json['preco'] as num?)?.toDouble(),
      estatisticas: EstatisticasConsumo.fromJson(
        json['estatisticas'] as Map<String, dynamic>,
      ),
      historicoConsumo: (json['historicoConsumo'] as List<dynamic>)
          .map(
            (item) => HistoricoConsumo.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      alertas: (json['alertas'] as List<dynamic>)
          .map((item) => AlertaDetalhado.fromJson(item as Map<String, dynamic>))
          .toList(),
      recomendacoes: (json['recomendacoes'] as List<dynamic>)
          .map(
            (item) =>
                RecomendacaoDetalhada.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      dataConsulta: DateTime.parse(json['dataConsulta'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    produto,
    despensa,
    quantidade,
    quantidadeMinima,
    estoqueAbaixoDoMinimo,
    dataValidade,
    dataAdicao,
    diasParaVencer,
    statusVencimento,
    preco,
    estatisticas,
    historicoConsumo,
    alertas,
    recomendacoes,
    dataConsulta,
  ];
}

class ProdutoDetalhes extends Equatable {
  final int id;
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;
  final String visibilidade;

  const ProdutoDetalhes({
    required this.id,
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
    required this.visibilidade,
  });

  factory ProdutoDetalhes.fromJson(Map<String, dynamic> json) {
    return ProdutoDetalhes(
      id: json['id'] as int,
      nome: json['nome'] as String,
      marca: json['marca'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      categoria: json['categoria'] as String?,
      visibilidade: json['visibilidade'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    marca,
    codigoBarras,
    categoria,
    visibilidade,
  ];
}

class DespensaDetalhes extends Equatable {
  final int id;
  final String nome;
  final int totalMembros;

  const DespensaDetalhes({
    required this.id,
    required this.nome,
    required this.totalMembros,
  });

  factory DespensaDetalhes.fromJson(Map<String, dynamic> json) {
    return DespensaDetalhes(
      id: json['id'] as int,
      nome: json['nome'] as String,
      totalMembros: json['totalMembros'] as int,
    );
  }

  @override
  List<Object?> get props => [id, nome, totalMembros];
}

class EstatisticasConsumo extends Equatable {
  final int totalConsumoUltimos30Dias;
  final double consumoMedioDiario;
  final int totalRegistrosHistorico;
  final DateTime? ultimoConsumo;

  const EstatisticasConsumo({
    required this.totalConsumoUltimos30Dias,
    required this.consumoMedioDiario,
    required this.totalRegistrosHistorico,
    this.ultimoConsumo,
  });

  factory EstatisticasConsumo.fromJson(Map<String, dynamic> json) {
    return EstatisticasConsumo(
      totalConsumoUltimos30Dias: json['totalConsumoUltimos30Dias'] as int,
      consumoMedioDiario: (json['consumoMedioDiario'] as num).toDouble(),
      totalRegistrosHistorico: json['totalRegistrosHistorico'] as int,
      ultimoConsumo: json['ultimoConsumo'] != null
          ? DateTime.parse(json['ultimoConsumo'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    totalConsumoUltimos30Dias,
    consumoMedioDiario,
    totalRegistrosHistorico,
    ultimoConsumo,
  ];
}

class HistoricoConsumo extends Equatable {
  final int id;
  final int quantidadeConsumida;
  final DateTime dataConsumo;
  final int quantidadeRestante;

  const HistoricoConsumo({
    required this.id,
    required this.quantidadeConsumida,
    required this.dataConsumo,
    required this.quantidadeRestante,
  });

  factory HistoricoConsumo.fromJson(Map<String, dynamic> json) {
    return HistoricoConsumo(
      id: json['id'] as int,
      quantidadeConsumida: json['quantidadeConsumida'] as int,
      dataConsumo: DateTime.parse(json['dataConsumo'] as String),
      quantidadeRestante: json['quantidadeRestante'] as int,
    );
  }

  @override
  List<Object?> get props => [
    id,
    quantidadeConsumida,
    dataConsumo,
    quantidadeRestante,
  ];
}

class AlertaDetalhado extends Equatable {
  final String tipo;
  final String nivel;
  final String icone;
  final String titulo;
  final String mensagem;
  final String acao;

  const AlertaDetalhado({
    required this.tipo,
    required this.nivel,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    required this.acao,
  });

  factory AlertaDetalhado.fromJson(Map<String, dynamic> json) {
    return AlertaDetalhado(
      tipo: json['tipo'] as String,
      nivel: json['nivel'] as String,
      icone: json['icone'] as String,
      titulo: json['titulo'] as String,
      mensagem: json['mensagem'] as String,
      acao: json['acao'] as String,
    );
  }

  @override
  List<Object?> get props => [tipo, nivel, icone, titulo, mensagem, acao];
}

class RecomendacaoDetalhada extends Equatable {
  final String tipo;
  final String icone;
  final String titulo;
  final String descricao;
  final String prioridade;

  const RecomendacaoDetalhada({
    required this.tipo,
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
  });

  factory RecomendacaoDetalhada.fromJson(Map<String, dynamic> json) {
    return RecomendacaoDetalhada(
      tipo: json['tipo'] as String,
      icone: json['icone'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      prioridade: json['prioridade'] as String,
    );
  }

  @override
  List<Object?> get props => [tipo, icone, titulo, descricao, prioridade];
}
