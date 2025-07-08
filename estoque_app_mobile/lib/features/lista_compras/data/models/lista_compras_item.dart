import 'package:equatable/equatable.dart';

class ListaComprasItem extends Equatable {
  final int id;
  final String nomeProduto;
  final String? marca;
  final double quantidade;
  final String unidadeMedida;
  final String tipoItem; // 'automatico', 'manual', 'preditivo'
  final bool comprado;
  final String? observacoes;
  final double? precoEstimado;
  final String? categoria;
  final DateTime dataAdicao;
  final DateTime? dataCompra;
  final int? prioridade;
  final String? motivoAdicao;

  const ListaComprasItem({
    required this.id,
    required this.nomeProduto,
    this.marca,
    required this.quantidade,
    required this.unidadeMedida,
    required this.tipoItem,
    required this.comprado,
    this.observacoes,
    this.precoEstimado,
    this.categoria,
    required this.dataAdicao,
    this.dataCompra,
    this.prioridade,
    this.motivoAdicao,
  });

  factory ListaComprasItem.fromJson(Map<String, dynamic> json) {
    return ListaComprasItem(
      id: json['id'] as int,
      nomeProduto: json['nomeProduto'] as String,
      marca: json['marca'] as String?,
      quantidade: (json['quantidade'] as num).toDouble(),
      unidadeMedida: json['unidadeMedida'] as String,
      tipoItem: json['tipoItem'] as String,
      comprado: json['comprado'] as bool,
      observacoes: json['observacoes'] as String?,
      precoEstimado: json['precoEstimado'] != null
          ? (json['precoEstimado'] as num).toDouble()
          : null,
      categoria: json['categoria'] as String?,
      dataAdicao: DateTime.parse(json['dataAdicao'] as String),
      dataCompra: json['dataCompra'] != null
          ? DateTime.parse(json['dataCompra'] as String)
          : null,
      prioridade: json['prioridade'] as int?,
      motivoAdicao: json['motivoAdicao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeProduto': nomeProduto,
      'marca': marca,
      'quantidade': quantidade,
      'unidadeMedida': unidadeMedida,
      'tipoItem': tipoItem,
      'comprado': comprado,
      'observacoes': observacoes,
      'precoEstimado': precoEstimado,
      'categoria': categoria,
      'dataAdicao': dataAdicao.toIso8601String(),
      'dataCompra': dataCompra?.toIso8601String(),
      'prioridade': prioridade,
      'motivoAdicao': motivoAdicao,
    };
  }

  ListaComprasItem copyWith({
    int? id,
    String? nomeProduto,
    String? marca,
    double? quantidade,
    String? unidadeMedida,
    String? tipoItem,
    bool? comprado,
    String? observacoes,
    double? precoEstimado,
    String? categoria,
    DateTime? dataAdicao,
    DateTime? dataCompra,
    int? prioridade,
    String? motivoAdicao,
  }) {
    return ListaComprasItem(
      id: id ?? this.id,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      marca: marca ?? this.marca,
      quantidade: quantidade ?? this.quantidade,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      tipoItem: tipoItem ?? this.tipoItem,
      comprado: comprado ?? this.comprado,
      observacoes: observacoes ?? this.observacoes,
      precoEstimado: precoEstimado ?? this.precoEstimado,
      categoria: categoria ?? this.categoria,
      dataAdicao: dataAdicao ?? this.dataAdicao,
      dataCompra: dataCompra ?? this.dataCompra,
      prioridade: prioridade ?? this.prioridade,
      motivoAdicao: motivoAdicao ?? this.motivoAdicao,
    );
  }

  // Helper para nome completo
  String get nomeCompleto {
    if (marca != null && marca!.isNotEmpty) {
      return '$nomeProduto - $marca';
    }
    return nomeProduto;
  }

  // Helper para tipo do item formatado
  String get tipoFormatado {
    switch (tipoItem) {
      case 'automatico':
        return 'Automático';
      case 'manual':
        return 'Manual';
      case 'preditivo':
        return 'Sugestão IA';
      default:
        return 'Desconhecido';
    }
  }

  // Helper para ícone do tipo
  String get iconeTipo {
    switch (tipoItem) {
      case 'automatico':
        return '🔄';
      case 'manual':
        return '✋';
      case 'preditivo':
        return '🤖';
      default:
        return '📦';
    }
  }

  // Helper para cor do tipo
  int get corTipo {
    switch (tipoItem) {
      case 'automatico':
        return 0xFF3B82F6; // Azul
      case 'manual':
        return 0xFF10B981; // Verde
      case 'preditivo':
        return 0xFF8B5CF6; // Roxo
      default:
        return 0xFF6B7280; // Cinza
    }
  }

  // Helper para ícone da categoria
  String get iconeCategoria {
    switch (categoria?.toLowerCase()) {
      case 'alimentos':
        return '🍽️';
      case 'bebidas':
        return '🥤';
      case 'limpeza':
        return '🧽';
      case 'higiene':
        return '🧴';
      case 'medicamentos':
        return '💊';
      case 'beleza':
        return '💄';
      case 'cuidados_pessoais':
        return '🧴';
      case 'casa':
        return '🏠';
      case 'eletronicos':
        return '📱';
      case 'roupas':
        return '👕';
      case 'livros':
        return '📚';
      case 'brinquedos':
        return '🧸';
      case 'esportes':
        return '⚽';
      case 'jardim':
        return '🌱';
      case 'ferramentas':
        return '🔧';
      case 'automotivo':
        return '🚗';
      case 'pets':
        return '🐾';
      default:
        return '📦';
    }
  }

  // Helper para cor da prioridade
  int get corPrioridade {
    switch (prioridade) {
      case 1:
        return 0xFFEF4444; // Vermelho - Alta
      case 2:
        return 0xFFF59E0B; // Amarelo - Média
      case 3:
        return 0xFF10B981; // Verde - Baixa
      default:
        return 0xFF6B7280; // Cinza - Sem prioridade
    }
  }

  // Helper para texto da prioridade
  String get textoPrioridade {
    switch (prioridade) {
      case 1:
        return 'Alta';
      case 2:
        return 'Média';
      case 3:
        return 'Baixa';
      default:
        return '';
    }
  }

  // Helper para determinar se é um item automático
  bool get isAutomatico => tipoItem == 'automatico';

  // Helper para determinar se é um item manual
  bool get isManual => tipoItem == 'manual';

  // Helper para determinar se é uma sugestão preditiva
  bool get isPreditivo => tipoItem == 'preditivo';

  @override
  List<Object?> get props => [
        id,
        nomeProduto,
        marca,
        quantidade,
        unidadeMedida,
        tipoItem,
        comprado,
        observacoes,
        precoEstimado,
        categoria,
        dataAdicao,
        dataCompra,
        prioridade,
        motivoAdicao,
      ];
} 