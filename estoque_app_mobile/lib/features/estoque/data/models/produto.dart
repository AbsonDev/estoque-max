import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final int id;
  final String nome;
  final String? marca;
  final String? categoria;
  final String? codigoBarras;
  final String unidadeMedida;
  final double? precoMedio;
  final String? descricao;
  final String? imagemUrl;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime ultimaAtualizacao;

  const Produto({
    required this.id,
    required this.nome,
    this.marca,
    this.categoria,
    this.codigoBarras,
    required this.unidadeMedida,
    this.precoMedio,
    this.descricao,
    this.imagemUrl,
    required this.ativo,
    required this.dataCriacao,
    required this.ultimaAtualizacao,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      marca: json['marca'] as String?,
      categoria: json['categoria'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      unidadeMedida: json['unidadeMedida'] as String,
      precoMedio: json['precoMedio'] != null 
          ? (json['precoMedio'] as num).toDouble()
          : null,
      descricao: json['descricao'] as String?,
      imagemUrl: json['imagemUrl'] as String?,
      ativo: json['ativo'] as bool,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      ultimaAtualizacao: DateTime.parse(json['ultimaAtualizacao'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'marca': marca,
      'categoria': categoria,
      'codigoBarras': codigoBarras,
      'unidadeMedida': unidadeMedida,
      'precoMedio': precoMedio,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'ativo': ativo,
      'dataCriacao': dataCriacao.toIso8601String(),
      'ultimaAtualizacao': ultimaAtualizacao.toIso8601String(),
    };
  }

  Produto copyWith({
    int? id,
    String? nome,
    String? marca,
    String? categoria,
    String? codigoBarras,
    String? unidadeMedida,
    double? precoMedio,
    String? descricao,
    String? imagemUrl,
    bool? ativo,
    DateTime? dataCriacao,
    DateTime? ultimaAtualizacao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      marca: marca ?? this.marca,
      categoria: categoria ?? this.categoria,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      precoMedio: precoMedio ?? this.precoMedio,
      descricao: descricao ?? this.descricao,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  // Helper para nome completo
  String get nomeCompleto {
    if (marca != null && marca!.isNotEmpty) {
      return '$nome - $marca';
    }
    return nome;
  }

  // Helper para categoria formatada
  String get categoriaFormatada {
    return categoria?.replaceAll('_', ' ').toLowerCase() ?? 'Não categorizado';
  }

  // Helper para ícone baseado na categoria
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

  @override
  List<Object?> get props => [
        id,
        nome,
        marca,
        categoria,
        codigoBarras,
        unidadeMedida,
        precoMedio,
        descricao,
        imagemUrl,
        ativo,
        dataCriacao,
        ultimaAtualizacao,
      ];
}

class CriarProdutoDto {
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;
  final String? descricao;

  const CriarProdutoDto({
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
    this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'marca': marca,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
      'descricao': descricao,
    };
  }
}

class AtualizarProdutoDto {
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;
  final String? descricao;

  const AtualizarProdutoDto({
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
    this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'marca': marca,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
      'descricao': descricao,
    };
  }
} 