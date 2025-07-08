import 'package:equatable/equatable.dart';

/// DTO para criar uma nova despensa
class CriarDespensaDto extends Equatable {
  final String nome;

  const CriarDespensaDto({
    required this.nome,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }

  @override
  List<Object> get props => [nome];
}

/// DTO para convidar um membro para a despensa
class ConvidarMembroDto extends Equatable {
  final String emailDestinatario;
  final String? mensagem;

  const ConvidarMembroDto({
    required this.emailDestinatario,
    this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'emailDestinatario': emailDestinatario,
      if (mensagem != null && mensagem!.isNotEmpty) 'mensagem': mensagem,
    };
  }

  @override
  List<Object?> get props => [emailDestinatario, mensagem];
}

/// Resposta da API quando uma despensa é criada
class DespensaCriadaResponse extends Equatable {
  final int id;
  final String nome;
  final DateTime dataCriacao;
  final int totalItens;
  final String meuPapel;
  final int totalMembros;

  const DespensaCriadaResponse({
    required this.id,
    required this.nome,
    required this.dataCriacao,
    required this.totalItens,
    required this.meuPapel,
    required this.totalMembros,
  });

  factory DespensaCriadaResponse.fromJson(Map<String, dynamic> json) {
    return DespensaCriadaResponse(
      id: json['id'] as int,
      nome: json['nome'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      totalItens: json['totalItens'] as int,
      meuPapel: json['meuPapel'] as String,
      totalMembros: json['totalMembros'] as int,
    );
  }

  @override
  List<Object> get props => [id, nome, dataCriacao, totalItens, meuPapel, totalMembros];
}

/// Resposta da API quando um convite é enviado
class ConviteEnviadoResponse extends Equatable {
  final String message;
  final int conviteId;
  final DestinatarioInfo destinatario;

  const ConviteEnviadoResponse({
    required this.message,
    required this.conviteId,
    required this.destinatario,
  });

  factory ConviteEnviadoResponse.fromJson(Map<String, dynamic> json) {
    return ConviteEnviadoResponse(
      message: json['message'] as String,
      conviteId: json['conviteId'] as int,
      destinatario: DestinatarioInfo.fromJson(json['destinatario'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object> get props => [message, conviteId, destinatario];
}

class DestinatarioInfo extends Equatable {
  final String nome;
  final String email;

  const DestinatarioInfo({
    required this.nome,
    required this.email,
  });

  factory DestinatarioInfo.fromJson(Map<String, dynamic> json) {
    return DestinatarioInfo(
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }

  @override
  List<Object> get props => [nome, email];
}

/// Resposta de erro da API (para upgrade necessário)
class ApiErrorResponse extends Equatable {
  final String error;
  final String message;
  final bool? upgradeRequired;
  final String? currentPlan;
  final int? limit;
  final String? feature;

  const ApiErrorResponse({
    required this.error,
    required this.message,
    this.upgradeRequired,
    this.currentPlan,
    this.limit,
    this.feature,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      error: json['error'] as String,
      message: json['message'] as String,
      upgradeRequired: json['upgradeRequired'] as bool?,
      currentPlan: json['currentPlan'] as String?,
      limit: json['limit'] as int?,
      feature: json['feature'] as String?,
    );
  }

  @override
  List<Object?> get props => [error, message, upgradeRequired, currentPlan, limit, feature];
} 