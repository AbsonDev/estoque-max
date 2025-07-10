import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/estoque_item.dart';
import '../models/produto.dart';
import '../../../despensas/data/models/despensa.dart';

class EstoqueService {
  final ApiService _apiService;

  EstoqueService(this._apiService);

  // Obtém todos os itens de estoque de uma despensa
  // Busca todos os itens de estoque (de todas as despensas)
  Future<List<EstoqueItem>> getTodosEstoqueItens() async {
    try {
      final response = await _apiService.get('/estoque');

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
        throw Exception('Nenhum item encontrado');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Acesso negado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Busca itens de uma despensa específica
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
        '/produtos/buscar', // Endpoint correto
        queryParameters: query != null
            ? {'query': query}
            : null, // Parâmetro correto
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;

        // Se a resposta for null, retorna lista vazia
        if (data == null) {
          return [];
        }

        // A API retorna um objeto com a propriedade 'produtos'
        if (data is Map<String, dynamic>) {
          final List<dynamic>? produtos = data['produtos'] as List<dynamic>?;
          if (produtos == null) {
            return [];
          }
          return produtos.map((item) => Produto.fromJson(item)).toList();
        }

        // Se a resposta for uma lista direta (fallback)
        if (data is List) {
          return data.map((item) => Produto.fromJson(item)).toList();
        }

        // Se chegou aqui, formato não reconhecido
        return [];
      } else {
        throw Exception('Erro ao buscar produtos: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Não autorizado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Adiciona um item ao estoque
  Future<void> adicionarItem(AdicionarEstoqueDto request) async {
    try {
      final response = await _apiService.post(
        '/estoque',
        data: request.toJson(), // Usar o DTO correto
      );

      if (response.statusCode == 200) {
        // API retorna uma mensagem de sucesso e informações extras
        return;
      } else {
        throw Exception('Erro ao adicionar item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Dados inválidos';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Você não tem permissão para acessar esta despensa');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Despensa ou produto não encontrado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // Atualiza um item do estoque
  Future<void> atualizarItem(int itemId, AtualizarEstoqueDto request) async {
    try {
      final response = await _apiService.put(
        '/estoque/$itemId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // API retorna um objeto com message e dados extras
        return;
      } else {
        throw Exception('Erro ao atualizar item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Dados inválidos';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Você não tem permissão para acessar esta despensa');
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
  Future<void> consumirItem(int itemId, ConsumirEstoqueDto request) async {
    try {
      final response = await _apiService.post(
        '/estoque/$itemId/consumir',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // API retorna um objeto com message e dados extras
        return;
      } else {
        throw Exception('Erro ao consumir item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data?['message'] ?? 'Quantidade inválida';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Você não tem permissão para acessar esta despensa');
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

  // Obtém detalhes completos de um item específico (com estatísticas e histórico)
  Future<EstoqueItemDetalhes> getItemDetalhesCompletos(int itemId) async {
    try {
      final response = await _apiService.get('/estoque/$itemId');

      if (response.statusCode == 200) {
        return EstoqueItemDetalhes.fromJson(response.data);
      } else {
        throw Exception(
          'Erro ao carregar detalhes do item: ${response.statusMessage}',
        );
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

  // Busca despensas do usuário
  Future<List<Despensa>> buscarDespensas() async {
    try {
      final response = await _apiService.get('/despensas');

      if (response.statusCode == 200) {
        final dynamic data = response.data;

        // Se a resposta for null, retorna lista vazia
        if (data == null) {
          return [];
        }

        // Se a resposta for uma lista direta
        if (data is List) {
          return data.map((item) => Despensa.fromJson(item)).toList();
        }

        // Se a resposta for um objeto com propriedade (caso existir)
        if (data is Map<String, dynamic> && data.containsKey('despensas')) {
          final List<dynamic>? despensas = data['despensas'] as List<dynamic>?;
          if (despensas != null) {
            return despensas.map((item) => Despensa.fromJson(item)).toList();
          }
        }

        // Se chegou aqui, formato não reconhecido
        return [];
      } else {
        throw Exception('Erro ao buscar despensas: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Não autorizado');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

// Removemos as classes antigas de request pois agora usamos os DTOs dos modelos
