import 'package:equatable/equatable.dart';

class Despensa extends Equatable {
  final int id;
  final String nome;
  final DateTime dataCriacao;
  final int totalItens;
  final String meuPapel;
  final int totalMembros;
  final List<MembroDespensa> membros;
  final List<ItemEstoque>? itens;

  const Despensa({
    required this.id,
    required this.nome,
    required this.dataCriacao,
    required this.totalItens,
    required this.meuPapel,
    required this.totalMembros,
    required this.membros,
    this.itens,
  });

  factory Despensa.fromJson(Map<String, dynamic> json) {
    return Despensa(
      id: (json['id'] as int?) ?? 0,
      nome: (json['nome'] as String?) ?? '',
      dataCriacao: json['dataCriacao'] != null 
          ? DateTime.tryParse(json['dataCriacao'] as String) ?? DateTime.now()
          : DateTime.now(),
      totalItens: (json['totalItens'] as int?) ?? 0,
      meuPapel: (json['meuPapel'] as String?) ?? 'Membro',
      totalMembros: (json['totalMembros'] as int?) ?? 0,
      membros: (json['membros'] as List<dynamic>?)
          ?.map((membro) => MembroDespensa.fromJson(membro as Map<String, dynamic>))
          .toList() ?? [],
      itens: (json['itens'] as List<dynamic>?)
          ?.map((item) => ItemEstoque.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dataCriacao': dataCriacao.toIso8601String(),
      'totalItens': totalItens,
      'meuPapel': meuPapel,
      'totalMembros': totalMembros,
      'membros': membros.map((membro) => membro.toJson()).toList(),
      if (itens != null) 'itens': itens!.map((item) => item.toJson()).toList(),
    };
  }

  bool get sounDono => meuPapel.toLowerCase() == 'dono';
  bool get possoConvidar => sounDono;
  bool get possoEditar => sounDono;
  bool get possoDeletar => sounDono;

  @override
  List<Object?> get props => [
    id,
    nome,
    dataCriacao,
    totalItens,
    meuPapel,
    totalMembros,
    membros,
    itens,
  ];
}

class MembroDespensa extends Equatable {
  final int usuarioId;
  final String nome;
  final String email;
  final String papel;
  final DateTime? dataAcesso;

  const MembroDespensa({
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.papel,
    this.dataAcesso,
  });

  factory MembroDespensa.fromJson(Map<String, dynamic> json) {
    return MembroDespensa(
      usuarioId: (json['usuarioId'] as int?) ?? 0,
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      papel: (json['papel'] as String?) ?? 'Membro',
      dataAcesso: json['dataAcesso'] != null 
          ? DateTime.tryParse(json['dataAcesso'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nome': nome,
      'email': email,
      'papel': papel,
      if (dataAcesso != null) 'dataAcesso': dataAcesso!.toIso8601String(),
    };
  }

  bool get isDono => papel.toLowerCase() == 'dono';
  bool get isMembro => papel.toLowerCase() == 'membro';

  @override
  List<Object?> get props => [usuarioId, nome, email, papel, dataAcesso];
}

class ItemEstoque extends Equatable {
  final int id;
  final String produto;
  final String? marca;
  final int quantidade;
  final int quantidadeMinima;
  final DateTime? dataValidade;

  const ItemEstoque({
    required this.id,
    required this.produto,
    this.marca,
    required this.quantidade,
    required this.quantidadeMinima,
    this.dataValidade,
  });

  factory ItemEstoque.fromJson(Map<String, dynamic> json) {
    return ItemEstoque(
      id: (json['id'] as int?) ?? 0,
      produto: (json['produto'] as String?) ?? '',
      marca: json['marca'] as String?,
      quantidade: (json['quantidade'] as int?) ?? 0,
      quantidadeMinima: (json['quantidadeMinima'] as int?) ?? 0,
      dataValidade: json['dataValidade'] != null 
          ? DateTime.tryParse(json['dataValidade'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produto': produto,
      if (marca != null) 'marca': marca,
      'quantidade': quantidade,
      'quantidadeMinima': quantidadeMinima,
      if (dataValidade != null) 'dataValidade': dataValidade!.toIso8601String(),
    };
  }

  bool get precisaRepor => quantidade <= quantidadeMinima;
  bool get estaVencido => dataValidade != null && dataValidade!.isBefore(DateTime.now());
  bool get venceEm7Dias => dataValidade != null && 
      dataValidade!.isBefore(DateTime.now().add(const Duration(days: 7)));

  @override
  List<Object?> get props => [id, produto, marca, quantidade, quantidadeMinima, dataValidade];
} 