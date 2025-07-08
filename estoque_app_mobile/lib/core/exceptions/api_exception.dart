import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Tempo limite de conexão excedido',
          statusCode: 408,
        );
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Tempo limite de envio excedido',
          statusCode: 408,
        );
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Tempo limite de resposta excedido',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        final message = _getErrorMessage(dioError.response);
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: dioError.response?.data,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Requisição cancelada',
          statusCode: 499,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Erro de conexão. Verifique sua internet',
          statusCode: 503,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Erro de certificado SSL',
          statusCode: 495,
        );
      case DioExceptionType.unknown:
        return const ApiException(
          message: 'Erro inesperado. Tente novamente',
          statusCode: 500,
        );
    }
  }

  static String _getErrorMessage(Response? response) {
    if (response?.data != null) {
      // Tenta extrair mensagem do corpo da resposta
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 
               data['error'] ?? 
               data['title'] ?? 
               'Erro na requisição';
      }
    }

    // Mensagens padrão baseadas no status code
    switch (response?.statusCode) {
      case 400:
        return 'Dados inválidos';
      case 401:
        return 'Não autorizado. Faça login novamente';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 422:
        return 'Dados de entrada inválidos';
      case 429:
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 500:
        return 'Erro interno do servidor';
      case 502:
        return 'Servidor indisponível';
      case 503:
        return 'Serviço temporariamente indisponível';
      default:
        return 'Erro na requisição';
    }
  }

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
} 