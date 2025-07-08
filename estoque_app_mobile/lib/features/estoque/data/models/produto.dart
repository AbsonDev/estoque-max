import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final int id;
  final String nome;
  final String? marca;
  final String? codigoBarras;
  final String? categoria;
  final String? descricao;
  final DateTime dataCriacao;

  const Produto({
    required this.id,
    required this.nome,
    this.marca,
    this.codigoBarras,
    this.categoria,
    this.descricao,
    required this.dataCriacao,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: (json['id'] as int?) ?? 0,
      nome: (json['nome'] as String?) ?? '',
      marca: json['marca'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      categoria: json['categoria'] as String?,
      descricao: json['descricao'] as String?,
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
      'codigoBarras': codigoBarras,
      'categoria': categoria,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  Produto copyWith({
    int? id,
    String? nome,
    String? marca,
    String? codigoBarras,
    String? categoria,
    String? descricao,
    DateTime? dataCriacao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      marca: marca ?? this.marca,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    marca,
    codigoBarras,
    categoria,
    descricao,
    dataCriacao,
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