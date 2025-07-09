import 'package:equatable/equatable.dart';

class ListaComprasResponse extends Equatable {
  final List<ListaComprasItem> itens;
  final List<SugestaoPreditiva> sugestoesPreditivas;
  final DateTime? ultimaAtualizacao;

  const ListaComprasResponse({
    required this.itens,
    required this.sugestoesPreditivas,
    this.ultimaAtualizacao,
  });

  factory ListaComprasResponse.fromJson(Map<String, dynamic> json) {
    return ListaComprasResponse(
      itens:
          (json['listaDeCompras'] as List<dynamic>?)
              ?.map((item) => ListaComprasItem.fromJson(item))
              .toList() ??
          [],
      sugestoesPreditivas:
          (json['sugestoesPreditivas'] != null &&
              json['sugestoesPreditivas']['itens'] != null)
          ? (json['sugestoesPreditivas']['itens'] as List<dynamic>)
                .map((item) => SugestaoPreditiva.fromJson(item))
                .toList()
          : [],
      ultimaAtualizacao: json['dataUltimaAtualizacao'] != null
          ? DateTime.parse(json['dataUltimaAtualizacao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itens': itens.map((item) => item.toJson()).toList(),
      'sugestoesPreditivas': sugestoesPreditivas
          .map((item) => item.toJson())
          .toList(),
      'ultimaAtualizacao': ultimaAtualizacao?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [itens, sugestoesPreditivas, ultimaAtualizacao];
}

class ListaComprasItem extends Equatable {
  final int id;
  final String nome;
  final String categoria;
  final int quantidade;
  final double valor;
  final bool comprado;
  final DateTime? dataCompra;
  final String? observacoes;
  final TipoItem tipo;
  final int? estoqueItemId;
  final DateTime dataCriacao;

  const ListaComprasItem({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.valor,
    required this.comprado,
    this.dataCompra,
    this.observacoes,
    required this.tipo,
    this.estoqueItemId,
    required this.dataCriacao,
  });

  factory ListaComprasItem.fromJson(Map<String, dynamic> json) {
    return ListaComprasItem(
      id: json['id'] ?? 0,
      nome: json['produto'] != null
          ? json['produto']['nome']
          : json['descricaoManual'] ?? '',
      categoria: json['produto'] != null
          ? json['produto']['categoria'] ?? ''
          : '',
      quantidade: json['quantidadeDesejada'] ?? 1,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      comprado: json['comprado'] ?? false,
      dataCompra: json['dataCompra'] != null
          ? DateTime.parse(json['dataCompra'])
          : null,
      observacoes: json['observacoes'],
      tipo: json['tipo'] == 'tradicional' ? TipoItem.manual : TipoItem.sugestao,
      estoqueItemId: json['estoqueItemId'],
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'valor': valor,
      'comprado': comprado,
      'dataCompra': dataCompra?.toIso8601String(),
      'observacoes': observacoes,
      'tipo': tipo.name,
      'estoqueItemId': estoqueItemId,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  ListaComprasItem copyWith({
    int? id,
    String? nome,
    String? categoria,
    int? quantidade,
    double? valor,
    bool? comprado,
    DateTime? dataCompra,
    String? observacoes,
    TipoItem? tipo,
    int? estoqueItemId,
    DateTime? dataCriacao,
  }) {
    return ListaComprasItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      valor: valor ?? this.valor,
      comprado: comprado ?? this.comprado,
      dataCompra: dataCompra ?? this.dataCompra,
      observacoes: observacoes ?? this.observacoes,
      tipo: tipo ?? this.tipo,
      estoqueItemId: estoqueItemId ?? this.estoqueItemId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    categoria,
    quantidade,
    valor,
    comprado,
    dataCompra,
    observacoes,
    tipo,
    estoqueItemId,
    dataCriacao,
  ];
}

class SugestaoPreditiva extends Equatable {
  final int estoqueItemId;
  final String nome;
  final String categoria;
  final int quantidade;
  final double valor;
  final double confianca;
  final String motivo;
  final DateTime? previsaoConsumo;
  final String? imagemUrl;

  const SugestaoPreditiva({
    required this.estoqueItemId,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.valor,
    required this.confianca,
    required this.motivo,
    this.previsaoConsumo,
    this.imagemUrl,
  });

  factory SugestaoPreditiva.fromJson(Map<String, dynamic> json) {
    return SugestaoPreditiva(
      estoqueItemId: json['EstoqueItemId'] ?? 0,
      nome: json['Produto'] != null ? json['Produto']['Nome'] : '',
      categoria: json['Produto'] != null
          ? json['Produto']['Categoria'] ?? ''
          : '',
      quantidade: json['QuantidadeSugerida'] ?? 1,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      confianca: (json['Confianca'] as num?)?.toDouble() ?? 0.0,
      motivo: json['MotivoSugestao'] ?? '',
      previsaoConsumo: json['DataPrevisao'] != null
          ? DateTime.parse(json['DataPrevisao'])
          : null,
      imagemUrl: json['imagemUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estoqueItemId': estoqueItemId,
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'valor': valor,
      'confianca': confianca,
      'motivo': motivo,
      'previsaoConsumo': previsaoConsumo?.toIso8601String(),
      'imagemUrl': imagemUrl,
    };
  }

  @override
  List<Object?> get props => [
    estoqueItemId,
    nome,
    categoria,
    quantidade,
    valor,
    confianca,
    motivo,
    previsaoConsumo,
    imagemUrl,
  ];
}

class HistoricoCompra extends Equatable {
  final int id;
  final String nome;
  final String categoria;
  final int quantidade;
  final double valor;
  final DateTime dataCompra;
  final String? local;
  final String? observacoes;

  const HistoricoCompra({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.valor,
    required this.dataCompra,
    this.local,
    this.observacoes,
  });

  factory HistoricoCompra.fromJson(Map<String, dynamic> json) {
    return HistoricoCompra(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? json['descricao'] ?? '',
      categoria: json['categoria'] ?? '',
      quantidade: json['quantidade'] ?? json['quantidadeDesejada'] ?? 1,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      dataCompra: json['dataCompra'] != null
          ? DateTime.parse(json['dataCompra'])
          : DateTime.now(),
      local: json['local'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'valor': valor,
      'dataCompra': dataCompra.toIso8601String(),
      'local': local,
      'observacoes': observacoes,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    categoria,
    quantidade,
    valor,
    dataCompra,
    local,
    observacoes,
  ];
}

class AddManualItemRequest extends Equatable {
  final String nome;
  final String categoria;
  final int quantidade;
  final double valor;
  final String? observacoes;

  const AddManualItemRequest({
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.valor,
    this.observacoes,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'valor': valor,
      'observacoes': observacoes,
    };
  }

  @override
  List<Object?> get props => [nome, categoria, quantidade, valor, observacoes];
}

enum TipoItem { manual, sugestao }

// Helper extensions
extension ListaComprasItemExtensions on ListaComprasItem {
  bool get isManual => tipo == TipoItem.manual;
  bool get isSuggestion => tipo == TipoItem.sugestao;
  bool get isPending => !comprado;
  bool get isCompleted => comprado;

  double get totalValue => valor * quantidade;
}

extension SugestaoPreditivaExtensions on SugestaoPreditiva {
  bool get isHighConfidence => confianca >= 0.8;
  bool get isMediumConfidence => confianca >= 0.5 && confianca < 0.8;
  bool get isLowConfidence => confianca < 0.5;

  double get totalValue => valor * quantidade;
}
