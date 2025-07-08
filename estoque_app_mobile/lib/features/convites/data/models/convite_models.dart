import 'package:equatable/equatable.dart';

class Convite extends Equatable {
  final int id;
  final int despensaId;
  final String despensaNome;
  final String remetenteNome;
  final String remetenteEmail;
  final String destinatarioEmail;
  final String status;
  final DateTime dataEnvio;
  final DateTime? dataResposta;
  final String? mensagem;

  const Convite({
    required this.id,
    required this.despensaId,
    required this.despensaNome,
    required this.remetenteNome,
    required this.remetenteEmail,
    required this.destinatarioEmail,
    required this.status,
    required this.dataEnvio,
    this.dataResposta,
    this.mensagem,
  });

  factory Convite.fromJson(Map<String, dynamic> json) {
    return Convite(
      id: json['id'] ?? 0,
      despensaId: json['despensaId'] ?? 0,
      despensaNome: json['despensaNome'] ?? '',
      remetenteNome: json['remetenteNome'] ?? '',
      remetenteEmail: json['remetenteEmail'] ?? '',
      destinatarioEmail: json['destinatarioEmail'] ?? '',
      status: json['status'] ?? '',
      dataEnvio: DateTime.parse(json['dataEnvio']),
      dataResposta: json['dataResposta'] != null
          ? DateTime.parse(json['dataResposta'])
          : null,
      mensagem: json['mensagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'despensaId': despensaId,
      'despensaNome': despensaNome,
      'remetenteNome': remetenteNome,
      'remetenteEmail': remetenteEmail,
      'destinatarioEmail': destinatarioEmail,
      'status': status,
      'dataEnvio': dataEnvio.toIso8601String(),
      'dataResposta': dataResposta?.toIso8601String(),
      'mensagem': mensagem,
    };
  }

  @override
  List<Object?> get props => [
    id, despensaId, despensaNome, remetenteNome, remetenteEmail,
    destinatarioEmail, status, dataEnvio, dataResposta, mensagem,
  ];
}

class ConviteRequest extends Equatable {
  final String email;
  final String? mensagem;

  const ConviteRequest({
    required this.email,
    this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'mensagem': mensagem,
    };
  }

  @override
  List<Object?> get props => [email, mensagem];
}

class MembroDespensa extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String role;
  final DateTime dataJuntou;
  final bool isAdmin;

  const MembroDespensa({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    required this.dataJuntou,
    required this.isAdmin,
  });

  factory MembroDespensa.fromJson(Map<String, dynamic> json) {
    return MembroDespensa(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      dataJuntou: DateTime.parse(json['dataJuntou']),
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'role': role,
      'dataJuntou': dataJuntou.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  @override
  List<Object?> get props => [id, nome, email, role, dataJuntou, isAdmin];
}

// Extensions for helper methods
extension ConviteExtensions on Convite {
  bool get isPendente => status.toLowerCase() == 'pendente';
  bool get isAceito => status.toLowerCase() == 'aceito';
  bool get isRecusado => status.toLowerCase() == 'recusado';
  bool get isExpirado => status.toLowerCase() == 'expirado';
  
  int get diasDesdeEnvio => DateTime.now().difference(dataEnvio).inDays;
} 