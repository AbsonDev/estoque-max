import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/auth_requests.dart';

class AuthResponse {
  final String token;
  final User user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ApiService {
  static const String baseUrl =
      'http://localhost:5265/api'; // Corrigido para HTTP
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
        final authResponse = AuthResponse.fromJson(response.data);
        await saveToken(authResponse.token);
        return authResponse;
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

  // Registro
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        await saveToken(authResponse.token);
        return authResponse;
      } else {
        throw Exception('Erro no registro: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Dados inválidos';
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
        final authResponse = AuthResponse.fromJson(response.data);
        await saveToken(authResponse.token);
        return authResponse;
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

  // Obter perfil do usuário
  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Erro ao obter perfil: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await removeToken();
        throw Exception('Sessão expirada');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Verificar se o token ainda é válido
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _dio.get('/auth/validate-token');
      return response.statusCode == 200;
    } catch (e) {
      await removeToken();
      return false;
    }
  }
}
