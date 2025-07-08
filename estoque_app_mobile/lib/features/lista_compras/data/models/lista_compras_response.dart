import 'package:equatable/equatable.dart';
import 'lista_compras_item.dart';

class ListaComprasResponse extends Equatable {
  final List<ListaComprasItem> itensParaComprar;
  final List<SugestaoPreditiva> sugestoesPreditivas;
  final ListaComprasResumo resumo;

  const ListaComprasResponse({
    required this.itensParaComprar,
    required this.sugestoesPreditivas,
    required this.resumo,
  });

  factory ListaComprasResponse.fromJson(Map<String, dynamic> json) {
    return ListaComprasResponse(
      itensParaComprar: (json['itensParaComprar'] as List<dynamic>? ?? [])
          .map((item) => ListaComprasItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      sugestoesPreditivas: (json['sugestoesPreditivas'] as List<dynamic>? ?? [])
          .map((item) => SugestaoPreditiva.fromJson(item as Map<String, dynamic>))
          .toList(),
      resumo: ListaComprasResumo.fromJson(json['resumo'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itensParaComprar': itensParaComprar.map((item) => item.toJson()).toList(),
      'sugestoesPreditivas': sugestoesPreditivas.map((item) => item.toJson()).toList(),
      'resumo': resumo.toJson(),
    };
  }

  @override
  List<Object?> get props => [itensParaComprar, sugestoesPreditivas, resumo];
}

class SugestaoPreditiva extends Equatable {
  final int estoqueItemId;
  final String nomeProduto;
  final String? marca;
  final double quantidadeSugerida;
  final String unidadeMedida;
  final String motivoSugestao;
  final double confianca;
  final String? categoria;
  final double? precoEstimado;
  final DateTime? dataPrevisaoConsumo;

  const SugestaoPreditiva({
    required this.estoqueItemId,
    required this.nomeProduto,
    this.marca,
    required this.quantidadeSugerida,
    required this.unidadeMedida,
    required this.motivoSugestao,
    required this.confianca,
    this.categoria,
    this.precoEstimado,
    this.dataPrevisaoConsumo,
  });

  factory SugestaoPreditiva.fromJson(Map<String, dynamic> json) {
    return SugestaoPreditiva(
      estoqueItemId: json['estoqueItemId'] as int,
      nomeProduto: json['nomeProduto'] as String,
      marca: json['marca'] as String?,
      quantidadeSugerida: (json['quantidadeSugerida'] as num).toDouble(),
      unidadeMedida: json['unidadeMedida'] as String,
      motivoSugestao: json['motivoSugestao'] as String,
      confianca: (json['confianca'] as num).toDouble(),
      categoria: json['categoria'] as String?,
      precoEstimado: json['precoEstimado'] != null 
          ? (json['precoEstimado'] as num).toDouble()
          : null,
      dataPrevisaoConsumo: json['dataPrevisaoConsumo'] != null
          ? DateTime.parse(json['dataPrevisaoConsumo'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estoqueItemId': estoqueItemId,
      'nomeProduto': nomeProduto,
      'marca': marca,
      'quantidadeSugerida': quantidadeSugerida,
      'unidadeMedida': unidadeMedida,
      'motivoSugestao': motivoSugestao,
      'confianca': confianca,
      'categoria': categoria,
      'precoEstimado': precoEstimado,
      'dataPrevisaoConsumo': dataPrevisaoConsumo?.toIso8601String(),
    };
  }

  // Helper para nome completo
  String get nomeCompleto {
    if (marca != null && marca!.isNotEmpty) {
      return '$nomeProduto - $marca';
    }
    return nomeProduto;
  }

  // Helper para nível de confiança
  String get nivelConfianca {
    if (confianca >= 0.8) return 'Alta';
    if (confianca >= 0.6) return 'Média';
    return 'Baixa';
  }

  // Helper para cor do nível de confiança
  int get corConfianca {
    if (confianca >= 0.8) return 0xFF10B981; // Verde
    if (confianca >= 0.6) return 0xFFF59E0B; // Amarelo
    return 0xFFEF4444; // Vermelho
  }

  @override
  List<Object?> get props => [
        estoqueItemId,
        nomeProduto,
        marca,
        quantidadeSugerida,
        unidadeMedida,
        motivoSugestao,
        confianca,
        categoria,
        precoEstimado,
        dataPrevisaoConsumo,
      ];
}

class ListaComprasResumo extends Equatable {
  final int totalItens;
  final int itensAutomaticos;
  final int itensManuais;
  final int itensPreditivos;
  final double valorEstimado;

  const ListaComprasResumo({
    required this.totalItens,
    required this.itensAutomaticos,
    required this.itensManuais,
    required this.itensPreditivos,
    required this.valorEstimado,
  });

  factory ListaComprasResumo.fromJson(Map<String, dynamic> json) {
    return ListaComprasResumo(
      totalItens: json['totalItens'] as int,
      itensAutomaticos: json['itensAutomaticos'] as int,
      itensManuais: json['itensManuais'] as int,
      itensPreditivos: json['itensPreditivos'] as int,
      valorEstimado: (json['valorEstimado'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItens': totalItens,
      'itensAutomaticos': itensAutomaticos,
      'itensManuais': itensManuais,
      'itensPreditivos': itensPreditivos,
      'valorEstimado': valorEstimado,
    };
  }

  @override
  List<Object?> get props => [
        totalItens,
        itensAutomaticos,
        itensManuais,
        itensPreditivos,
        valorEstimado,
      ];
} 