class LoginRequest {
  final String email;
  final String senha;

  const LoginRequest({required this.email, required this.senha});

  Map<String, dynamic> toJson() {
    return {'email': email, 'senha': senha};
  }
}

class RegisterRequest {
  final String nome;
  final String email;
  final String senha;

  const RegisterRequest({
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'email': email, 'senha': senha};
  }
}

class GoogleLoginRequest {
  final String idToken;

  const GoogleLoginRequest({required this.idToken});

  Map<String, dynamic> toJson() {
    return {'idToken': idToken};
  }
}
