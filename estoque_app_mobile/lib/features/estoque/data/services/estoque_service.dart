import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/estoque_item.dart';
import '../models/produto.dart';

class EstoqueService {
  final ApiService _apiService;

  EstoqueService(this._apiService);

  // Obtém todos os itens de estoque de uma despensa
  Future<List<EstoqueItem>> getEstoqueDespensa(int despensaId) async {
    try {
      final response = await _apiService.get(
        '/estoque',
        queryParameters: {'despensaId': despensaId},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        // Se a resposta for null, retorna lista vazia
        if (responseData == null) {
          return [];
        }

        // Se a resposta for uma lista direta
        if (responseData is List) {
          return responseData
              .map((item) => EstoqueItem.fromJson(item))
              .toList();
        }

        // Se a resposta for um objeto com propriedade 'estoque'
        if (responseData is Map<String, dynamic>) {
          final List<dynamic>? data = responseData['estoque'] as List<dynamic>?;
          if (data == null) {
            return [];
          }
          return data.map((item) => EstoqueItem.fromJson(item)).toList();
        }

        // Se chegou aqui, formato não reconhecido
        return [];
      } else {
        throw Exception('Erro ao carregar estoque: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Despensa não encontrada');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Busca produtos disponíveis
  Future<List<Produto>> buscarProdutos({String? query}) async {
    try {
      final response = await _apiService.get(
        '/produtos',
        queryParameters: query != null ? {'search': query} : null,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;

        // Se a resposta for null, retorna lista vazia
        if (data == null) {
          return [];
        }

        // Se a resposta for uma lista
        if (data is List) {
          return data.map((item) => Produto.fromJson(item)).toList();
        }

        // Se chegou aqui, formato não reconhecido
        return [];
      } else {
        throw Exception('Erro ao buscar produtos: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Adiciona um item ao estoque
  Future<void> adicionarItem(
    int despensaId,
    AdicionarItemRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/estoque',
        data: {
          'despensaId': despensaId,
          'produtoId': request.produtoId,
          'quantidade': request.quantidade,
          'quantidadeMinima': 1, // Default value
          'observacoes': request.observacoes,
          'dataValidade': request.dataValidade?.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        // API retorna apenas uma mensagem de sucesso, não o item criado
        return;
      } else {
        throw Exception('Erro ao adicionar item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Despensa não encontrada');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Atualiza um item do estoque
  Future<void> atualizarItem(int itemId, AtualizarItemRequest request) async {
    try {
      final response = await _apiService.put(
        '/estoque/$itemId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // API retorna um objeto com message e dados extras, não um EstoqueItem
        return;
      } else {
        throw Exception('Erro ao atualizar item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Item não encontrado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Consome um item do estoque
  Future<void> consumirItem(int itemId, ConsumirItemRequest request) async {
    try {
      final response = await _apiService.post(
        '/estoque/$itemId/consumir',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // API retorna um objeto com message e dados extras, não um EstoqueItem
        return;
      } else {
        throw Exception('Erro ao consumir item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Quantidade inválida');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Item não encontrado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Remove um item do estoque
  Future<void> removerItem(int itemId) async {
    try {
      final response = await _apiService.delete('/estoque/$itemId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao remover item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Item não encontrado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Obtém detalhes de um item específico
  Future<EstoqueItem> getItemDetalhes(int itemId) async {
    try {
      final response = await _apiService.get('/estoque/$itemId');

      if (response.statusCode == 200) {
        return EstoqueItem.fromJson(response.data);
      } else {
        throw Exception('Erro ao carregar item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Item não encontrado');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

// Models para requests
class AdicionarItemRequest {
  final int produtoId;
  final double quantidade;
  final String? observacoes;
  final DateTime? dataValidade;

  AdicionarItemRequest({
    required this.produtoId,
    required this.quantidade,
    this.observacoes,
    this.dataValidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'produtoId': produtoId,
      'quantidade': quantidade,
      'observacoes': observacoes,
      'dataValidade': dataValidade?.toIso8601String(),
    };
  }
}

class AtualizarItemRequest {
  final double? quantidade;
  final String? observacoes;
  final DateTime? dataValidade;

  AtualizarItemRequest({this.quantidade, this.observacoes, this.dataValidade});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (quantidade != null) data['quantidade'] = quantidade;
    if (observacoes != null) data['observacoes'] = observacoes;
    if (dataValidade != null)
      data['dataValidade'] = dataValidade!.toIso8601String();
    return data;
  }
}

class ConsumirItemRequest {
  final double quantidadeConsumida;
  final String? observacoes;

  ConsumirItemRequest({required this.quantidadeConsumida, this.observacoes});

  Map<String, dynamic> toJson() {
    return {
      'quantidadeConsumida': quantidadeConsumida,
      'observacoes': observacoes,
    };
  }
}
