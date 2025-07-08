import 'package:dio/dio.dart';
import '../../../../core/exceptions/api_exception.dart';
import '../../../../core/services/api_service.dart';
import '../models/estoque_item.dart';
import '../models/produto.dart';

class EstoqueService {
  final ApiService _apiService;

  EstoqueService(this._apiService);

  // Buscar estoque
  Future<List<EstoqueItem>> getEstoque({int? despensaId}) async {
    try {
      final params = <String, dynamic>{};
      if (despensaId != null) {
        params['despensaId'] = despensaId;
      }

      final response = await _apiService.get('/estoque', queryParameters: params);
      
      if (response.data['estoque'] != null) {
        return (response.data['estoque'] as List)
            .map((item) => EstoqueItem.fromJson(item))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao buscar estoque: ${e.toString()}');
    }
  }

  // Adicionar item ao estoque
  Future<void> adicionarAoEstoque(AdicionarEstoqueDto dto) async {
    try {
      await _apiService.post('/estoque', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao adicionar item: ${e.toString()}');
    }
  }

  // Atualizar item do estoque
  Future<void> atualizarEstoque(int id, AtualizarEstoqueDto dto) async {
    try {
      await _apiService.put('/estoque/$id', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao atualizar item: ${e.toString()}');
    }
  }

  // Consumir item do estoque
  Future<void> consumirEstoque(int id, ConsumirEstoqueDto dto) async {
    try {
      await _apiService.post('/estoque/$id/consumir', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao consumir item: ${e.toString()}');
    }
  }

  // Remover item do estoque
  Future<void> removerDoEstoque(int id) async {
    try {
      await _apiService.delete('/estoque/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao remover item: ${e.toString()}');
    }
  }

  // Buscar produtos
  Future<List<Produto>> getProdutos({String? busca}) async {
    try {
      final params = <String, dynamic>{};
      if (busca != null && busca.isNotEmpty) {
        params['busca'] = busca;
      }

      final response = await _apiService.get('/produtos', queryParameters: params);
      
      if (response.data != null) {
        return (response.data as List)
            .map((produto) => Produto.fromJson(produto))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao buscar produtos: ${e.toString()}');
    }
  }

  // Criar produto
  Future<Produto> criarProduto(CriarProdutoDto dto) async {
    try {
      final response = await _apiService.post('/produtos', data: dto.toJson());
      return Produto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao criar produto: ${e.toString()}');
    }
  }

  // Atualizar produto
  Future<Produto> atualizarProduto(int id, AtualizarProdutoDto dto) async {
    try {
      final response = await _apiService.put('/produtos/$id', data: dto.toJson());
      return Produto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao atualizar produto: ${e.toString()}');
    }
  }

  // Deletar produto
  Future<void> deletarProduto(int id) async {
    try {
      await _apiService.delete('/produtos/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar produto: ${e.toString()}');
    }
  }

  // Buscar produto por código de barras
  Future<Produto?> buscarProdutoPorCodigoBarras(String codigoBarras) async {
    try {
      final response = await _apiService.get('/produtos/codigo-barras/$codigoBarras');
      return Produto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException('Erro inesperado ao buscar produto: ${e.toString()}');
    }
  }
} 