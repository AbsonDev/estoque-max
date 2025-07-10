import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/auth_requests.dart';

class AuthResponse {
  final String token;
  final User? user;

  const AuthResponse({required this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://estoquemaxapi-acfwdye6g0bbdwb5.brazilsouth-01.azurewebsites.net/api';
  static const String tokenKey = 'auth_token';

  late final Dio _dio;
  static const _storage = FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Configurações para Flutter Web
        extra: {'withCredentials': false},
      ),
    );

    // Interceptor para adicionar token nas requisições
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Se o token expirou, remove do storage
          if (error.response?.statusCode == 401) {
            removeToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  // Métodos para gerenciar token
  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: tokenKey);
  }

  // Método para verificar se usuário está logado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Login tradicional
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await saveToken(token);

        // Backend não retorna user no login, então retornamos apenas o token
        return AuthResponse(token: token);
      } else {
        throw Exception('Erro no login: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou senha incorretos');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Registro - ENDPOINT CORRIGIDO
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/registrar', // CORRIGIDO: era /auth/register
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // CORRIGIDO: backend retorna 200, não 201
        // Backend retorna apenas message no registro, não token
        // Apenas confirma que o registro foi bem-sucedido

        // Após registro bem-sucedido, fazemos login automaticamente
        final loginRequest = LoginRequest(
          email: request.email,
          senha: request.senha,
        );

        return await login(loginRequest);
      } else {
        throw Exception('Erro no registro: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data is Map
            ? e.response?.data['message'] ?? 'Usuário já existe.'
            : 'Usuário já existe.';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 409) {
        throw Exception('Email já está em uso');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Login com Google
  Future<AuthResponse> googleLogin(GoogleLoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/google-login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await saveToken(token);

        // Backend retorna user no login Google
        User? user;
        if (response.data['user'] != null) {
          user = User.fromJson(response.data['user'] as Map<String, dynamic>);
        }

        return AuthResponse(token: token, user: user);
      } else {
        throw Exception('Erro no login com Google: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token do Google inválido');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
  }

  // REMOVIDO: Endpoint /auth/profile não existe no backend
  // Se precisar de dados do usuário, pode implementar um endpoint no backend
  // ou armazenar os dados do usuário localmente após o login

  // REMOVIDO: Endpoint /auth/validate-token não existe no backend
  // Validação do token agora é feita apenas verificando se existe no storage
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      await removeToken();
      return false;
    }
  }

  // Métodos HTTP genéricos para outras funcionalidades
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
