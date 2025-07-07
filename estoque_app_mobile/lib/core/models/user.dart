import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String? provider;

  const User({
    required this.id,
    required this.nome,
    required this.email,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      provider: json['provider'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'email': email, 'provider': provider};
  }

  @override
  List<Object?> get props => [id, nome, email, provider];
}
