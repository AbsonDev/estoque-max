import 'package:equatable/equatable.dart';

class AnalyticsDashboard extends Equatable {
  final List<IndicadorChave> indicadores;
  final List<ConsumoCategoria> consumoPorCategoria;
  final List<TopProduto> topProdutos;
  final List<GastoMensal> gastosMensais;
  final List<TendenciaDesperdicio> tendenciaDesperdicio;
  final List<ItemExpirado> itensExpirados;
  final List<HeatmapData> heatmapConsumo;
  final List<InsightAI> insights;

  const AnalyticsDashboard({
    required this.indicadores,
    required this.consumoPorCategoria,
    required this.topProdutos,
    required this.gastosMensais,
    required this.tendenciaDesperdicio,
    required this.itensExpirados,
    required this.heatmapConsumo,
    required this.insights,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      indicadores: (json['indicadores'] as List<dynamic>?)
          ?.map((item) => IndicadorChave.fromJson(item))
          .toList() ?? [],
      consumoPorCategoria: (json['consumoPorCategoria'] as List<dynamic>?)
          ?.map((item) => ConsumoCategoria.fromJson(item))
          .toList() ?? [],
      topProdutos: (json['topProdutos'] as List<dynamic>?)
          ?.map((item) => TopProduto.fromJson(item))
          .toList() ?? [],
      gastosMensais: (json['gastosMensais'] as List<dynamic>?)
          ?.map((item) => GastoMensal.fromJson(item))
          .toList() ?? [],
      tendenciaDesperdicio: (json['tendenciaDesperdicio'] as List<dynamic>?)
          ?.map((item) => TendenciaDesperdicio.fromJson(item))
          .toList() ?? [],
      itensExpirados: (json['itensExpirados'] as List<dynamic>?)
          ?.map((item) => ItemExpirado.fromJson(item))
          .toList() ?? [],
      heatmapConsumo: (json['heatmapConsumo'] as List<dynamic>?)
          ?.map((item) => HeatmapData.fromJson(item))
          .toList() ?? [],
      insights: (json['insights'] as List<dynamic>?)
          ?.map((item) => InsightAI.fromJson(item))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
    indicadores,
    consumoPorCategoria,
    topProdutos,
    gastosMensais,
    tendenciaDesperdicio,
    itensExpirados,
    heatmapConsumo,
    insights,
  ];
}

class IndicadorChave extends Equatable {
  final String nome;
  final double valor;
  final String unidade;
  final String? descricao;
  final TipoIndicador tipo;
  final double? variacao;
  final String? cor;

  const IndicadorChave({
    required this.nome,
    required this.valor,
    required this.unidade,
    this.descricao,
    required this.tipo,
    this.variacao,
    this.cor,
  });

  factory IndicadorChave.fromJson(Map<String, dynamic> json) {
    return IndicadorChave(
      nome: json['nome'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      unidade: json['unidade'] ?? '',
      descricao: json['descricao'],
      tipo: TipoIndicador.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoIndicador.economia,
      ),
      variacao: (json['variacao'] as num?)?.toDouble(),
      cor: json['cor'],
    );
  }

  @override
  List<Object?> get props => [nome, valor, unidade, descricao, tipo, variacao, cor];
}

class ConsumoCategoria extends Equatable {
  final String categoria;
  final double valor;
  final int quantidade;
  final String cor;

  const ConsumoCategoria({
    required this.categoria,
    required this.valor,
    required this.quantidade,
    required this.cor,
  });

  factory ConsumoCategoria.fromJson(Map<String, dynamic> json) {
    return ConsumoCategoria(
      categoria: json['categoria'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      quantidade: json['quantidade'] ?? 0,
      cor: json['cor'] ?? '#3498db',
    );
  }

  @override
  List<Object?> get props => [categoria, valor, quantidade, cor];
}

class TopProduto extends Equatable {
  final String nome;
  final double consumo;
  final double gasto;
  final String categoria;
  final String? imagem;

  const TopProduto({
    required this.nome,
    required this.consumo,
    required this.gasto,
    required this.categoria,
    this.imagem,
  });

  factory TopProduto.fromJson(Map<String, dynamic> json) {
    return TopProduto(
      nome: json['nome'] ?? '',
      consumo: (json['consumo'] as num?)?.toDouble() ?? 0.0,
      gasto: (json['gasto'] as num?)?.toDouble() ?? 0.0,
      categoria: json['categoria'] ?? '',
      imagem: json['imagem'],
    );
  }

  @override
  List<Object?> get props => [nome, consumo, gasto, categoria, imagem];
}

class GastoMensal extends Equatable {
  final DateTime mes;
  final double valor;
  final int itens;

  const GastoMensal({
    required this.mes,
    required this.valor,
    required this.itens,
  });

  factory GastoMensal.fromJson(Map<String, dynamic> json) {
    return GastoMensal(
      mes: DateTime.parse(json['mes']),
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      itens: json['itens'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [mes, valor, itens];
}

class TendenciaDesperdicio extends Equatable {
  final DateTime data;
  final double valor;
  final int itens;

  const TendenciaDesperdicio({
    required this.data,
    required this.valor,
    required this.itens,
  });

  factory TendenciaDesperdicio.fromJson(Map<String, dynamic> json) {
    return TendenciaDesperdicio(
      data: DateTime.parse(json['data']),
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      itens: json['itens'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [data, valor, itens];
}

class ItemExpirado extends Equatable {
  final String nome;
  final DateTime dataExpiracao;
  final double valor;
  final String categoria;

  const ItemExpirado({
    required this.nome,
    required this.dataExpiracao,
    required this.valor,
    required this.categoria,
  });

  factory ItemExpirado.fromJson(Map<String, dynamic> json) {
    return ItemExpirado(
      nome: json['nome'] ?? '',
      dataExpiracao: DateTime.parse(json['dataExpiracao']),
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      categoria: json['categoria'] ?? '',
    );
  }

  @override
  List<Object?> get props => [nome, dataExpiracao, valor, categoria];
}

class HeatmapData extends Equatable {
  final DateTime data;
  final int hora;
  final double intensidade;

  const HeatmapData({
    required this.data,
    required this.hora,
    required this.intensidade,
  });

  factory HeatmapData.fromJson(Map<String, dynamic> json) {
    return HeatmapData(
      data: DateTime.parse(json['data']),
      hora: json['hora'] ?? 0,
      intensidade: (json['intensidade'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [data, hora, intensidade];
}

class InsightAI extends Equatable {
  final String titulo;
  final String descricao;
  final TipoInsight tipo;
  final double confianca;
  final String? acao;
  final DateTime dataGeracao;

  const InsightAI({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.confianca,
    this.acao,
    required this.dataGeracao,
  });

  factory InsightAI.fromJson(Map<String, dynamic> json) {
    return InsightAI(
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      tipo: TipoInsight.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoInsight.geral,
      ),
      confianca: (json['confianca'] as num?)?.toDouble() ?? 0.0,
      acao: json['acao'],
      dataGeracao: DateTime.parse(json['dataGeracao']),
    );
  }

  @override
  List<Object?> get props => [titulo, descricao, tipo, confianca, acao, dataGeracao];
}

enum TipoIndicador { economia, desperdicio, eficiencia, consumo }

enum TipoInsight { geral, economia, desperdicio, tendencia, alerta } 