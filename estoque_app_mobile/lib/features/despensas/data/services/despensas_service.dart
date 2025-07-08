import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/exceptions/api_exception.dart';
import '../models/despensa.dart';
import '../models/despensa_dto.dart';

class DespensasService {
  final ApiService _apiService;

  DespensasService(this._apiService);

  /// Busca todas as despensas do usuário
  Future<List<Despensa>> getDespensas() async {
    try {
      final response = await _apiService.get('/despensas');
      
      if (response.data is List) {
        return (response.data as List)
            .map((despensa) => Despensa.fromJson(despensa as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Erro inesperado ao buscar despensas: $e',
        statusCode: 500,
      );
    }
  }

  /// Busca uma despensa específica por ID
  Future<Despensa> getDespensa(int id) async {
    try {
      final response = await _apiService.get('/despensas/$id');
      return Despensa.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Despensa não encontrada',
          statusCode: 404,
        );
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
          message: 'Você não tem permissão para acessar esta despensa',
          statusCode: 403,
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Erro inesperado ao buscar despensa: $e',
        statusCode: 500,
      );
    }
  }

  /// Cria uma nova despensa
  Future<DespensaCriadaResponse> criarDespensa(CriarDespensaDto dto) async {
    try {
      final response = await _apiService.post(
        '/despensas',
        data: dto.toJson(),
      );
      
      return DespensaCriadaResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        // Payment Required - Limite de plano atingido
        final errorData = e.response?.data as Map<String, dynamic>?;
        if (errorData != null) {
          throw UpgradeRequiredException.fromJson(errorData);
        }
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is UpgradeRequiredException) rethrow;
      throw ApiException(
        message: 'Erro inesperado ao criar despensa: $e',
        statusCode: 500,
      );
    }
  }

  /// Atualiza uma despensa existente
  Future<Despensa> atualizarDespensa(int id, CriarDespensaDto dto) async {
    try {
      final response = await _apiService.put(
        '/despensas/$id',
        data: dto.toJson(),
      );
      
      return Despensa.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException(
          message: 'Apenas o dono pode alterar o nome da despensa',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Despensa não encontrada',
          statusCode: 404,
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Erro inesperado ao atualizar despensa: $e',
        statusCode: 500,
      );
    }
  }

  /// Deleta uma despensa
  Future<void> deletarDespensa(int id) async {
    try {
      await _apiService.delete('/despensas/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException(
          message: 'Apenas o dono pode deletar a despensa',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Despensa não encontrada',
          statusCode: 404,
        );
      } else if (e.response?.statusCode == 400) {
        throw ApiException(
          message: 'Não é possível deletar uma despensa que contém itens',
          statusCode: 400,
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Erro inesperado ao deletar despensa: $e',
        statusCode: 500,
      );
    }
  }

  /// Convida um membro para a despensa
  Future<ConviteEnviadoResponse> convidarMembro(int despensaId, ConvidarMembroDto dto) async {
    try {
      final response = await _apiService.post(
        '/despensas/$despensaId/convidar',
        data: dto.toJson(),
      );
      
      return ConviteEnviadoResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        // Payment Required - Funcionalidade Premium necessária
        final errorData = e.response?.data as Map<String, dynamic>?;
        if (errorData != null) {
          throw UpgradeRequiredException.fromJson(errorData);
        }
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
          message: 'Apenas o dono pode convidar novos membros',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Usuário com este email não encontrado',
          statusCode: 404,
        );
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] as String? ?? 'Erro na requisição';
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is UpgradeRequiredException) rethrow;
      throw ApiException(
        message: 'Erro inesperado ao enviar convite: $e',
        statusCode: 500,
      );
    }
  }

  /// Remove um membro da despensa
  Future<void> removerMembro(int despensaId, int membroId) async {
    try {
      await _apiService.delete('/despensas/$despensaId/membros/$membroId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException(
          message: 'Você não tem permissão para remover este membro',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'Membro não encontrado nesta despensa',
          statusCode: 404,
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Erro inesperado ao remover membro: $e',
        statusCode: 500,
      );
    }
  }
}

/// Exceção específica para quando é necessário upgrade do plano
class UpgradeRequiredException extends ApiException {
  final bool upgradeRequired;
  final String? currentPlan;
  final int? limit;
  final String? feature;

  UpgradeRequiredException({
    required String message,
    required this.upgradeRequired,
    this.currentPlan,
    this.limit,
    this.feature,
    int statusCode = 402,
  }) : super(message: message, statusCode: statusCode);

  factory UpgradeRequiredException.fromJson(Map<String, dynamic> json) {
    return UpgradeRequiredException(
      message: json['message'] as String,
      upgradeRequired: json['upgradeRequired'] as bool? ?? true,
      currentPlan: json['currentPlan'] as String?,
      limit: json['limit'] as int?,
      feature: json['feature'] as String?,
    );
  }

  String get upgradeMessage {
    if (feature != null) {
      return 'A funcionalidade "$feature" requer um plano Premium.';
    } else if (limit != null) {
      return 'Você atingiu o limite de $limit despensas do plano gratuito.';
    }
    return 'Upgrade necessário para continuar.';
  }
} 