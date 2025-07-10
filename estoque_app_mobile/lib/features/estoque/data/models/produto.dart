import 'package:equatable/equatable.dart';

enum TipoVisibilidadeProduto {
  publico,
  privado,
}

class Produto extends Equatable {
  final int id;
  final String nome;
  final String? marca;
  final String? categoria;
  final String? codigoBarras;
  final TipoVisibilidadeProduto visibilidade;
  final int? usuarioCriadorId;
  final DateTime dataCriacao;

  const Produto({
    required this.id,
    required this.nome,
    this.marca,
    this.categoria,
    this.codigoBarras,
    this.visibilidade = TipoVisibilidadeProduto.privado,
    this.usuarioCriadorId,
    required this.dataCriacao,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? 'Produto sem nome',
      marca: json['marca'] as String?,
      categoria: json['categoria'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      visibilidade: TipoVisibilidadeProduto.values.firstWhere(
        (e) => e.name == json['visibilidade'],
        orElse: () => TipoVisibilidadeProduto.privado,
      ),
      usuarioCriadorId: json['usuarioCriadorId'] as int?,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.tryParse(json['dataCriacao'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'marca': marca,
      'categoria': categoria,
      'codigoBarras': codigoBarras,
      'visibilidade': visibilidade.name,
      'usuarioCriadorId': usuarioCriadorId,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  Produto copyWith({
    int? id,
    String? nome,
    String? marca,
    String? categoria,
    String? codigoBarras,
    TipoVisibilidadeProduto? visibilidade,
    int? usuarioCriadorId,
    DateTime? dataCriacao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      marca: marca ?? this.marca,
      categoria: categoria ?? this.categoria,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      visibilidade: visibilidade ?? this.visibilidade,
      usuarioCriadorId: usuarioCriadorId ?? this.usuarioCriadorId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
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

  // Helper para verificar se é produto próprio do usuário
  bool isOwnedByUser(int? currentUserId) {
    return visibilidade == TipoVisibilidadeProduto.privado && 
           usuarioCriadorId == currentUserId;
  }

  // Helper para verificar se pode ser editado pelo usuário
  bool canBeEditedByUser(int? currentUserId) {
    return visibilidade == TipoVisibilidadeProduto.publico ||
           isOwnedByUser(currentUserId);
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    marca,
    categoria,
    codigoBarras,
    visibilidade,
    usuarioCriadorId,
    dataCriacao,
  ];
}

class CriarProdutoDto {
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;

  const CriarProdutoDto({
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'marca': marca,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
    };
  }
}

class AtualizarProdutoDto {
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;

  const AtualizarProdutoDto({
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'marca': marca,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
    };
  }
}
