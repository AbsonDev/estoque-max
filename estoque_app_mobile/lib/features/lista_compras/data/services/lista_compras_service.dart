import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/lista_compras_models.dart';

class ListaComprasService {
  final ApiService _apiService;

  ListaComprasService(this._apiService);

  Future<ListaComprasResponse> getListaCompras() async {
    try {
      final response = await _apiService.get('/lista-de-compras');
      return ListaComprasResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar lista de compras: ${e.toString()}');
    }
  }

  Future<void> aceitarSugestao(int estoqueItemId) async {
    try {
      await _apiService.post('/lista-de-compras/aceitar-sugestao/$estoqueItemId');
    } catch (e) {
      throw Exception('Erro ao aceitar sugestão: ${e.toString()}');
    }
  }

  Future<ListaComprasItem> adicionarItemManual(AddManualItemRequest request) async {
    try {
      final response = await _apiService.post(
        '/lista-de-compras/adicionar-manual',
        data: request.toJson(),
      );
      return ListaComprasItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao adicionar item manual: ${e.toString()}');
    }
  }

  Future<void> marcarComoComprado(int itemId) async {
    try {
      await _apiService.put('/lista-de-compras/$itemId/marcar-comprado');
    } catch (e) {
      throw Exception('Erro ao marcar como comprado: ${e.toString()}');
    }
  }

  Future<void> removerItem(int itemId) async {
    try {
      await _apiService.delete('/lista-de-compras/$itemId');
    } catch (e) {
      throw Exception('Erro ao remover item: ${e.toString()}');
    }
  }

  Future<List<HistoricoCompra>> getHistorico({
    DateTime? dataInicio,
    DateTime? dataFim,
    int? limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (dataInicio != null) 'dataInicio': dataInicio.toIso8601String(),
        if (dataFim != null) 'dataFim': dataFim.toIso8601String(),
        if (limit != null) 'limit': limit,
      };

      final response = await _apiService.get(
        '/lista-de-compras/historico',
        queryParameters: queryParams,
      );
      
      return (response.data as List)
          .map((item) => HistoricoCompra.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar histórico: ${e.toString()}');
    }
  }

  Future<void> atualizarItem(int itemId, {
    String? nome,
    String? categoria,
    int? quantidade,
    double? valor,
    String? observacoes,
  }) async {
    try {
      final data = <String, dynamic>{
        if (nome != null) 'nome': nome,
        if (categoria != null) 'categoria': categoria,
        if (quantidade != null) 'quantidade': quantidade,
        if (valor != null) 'valor': valor,
        if (observacoes != null) 'observacoes': observacoes,
      };

      await _apiService.put('/lista-de-compras/$itemId', data: data);
    } catch (e) {
      throw Exception('Erro ao atualizar item: ${e.toString()}');
    }
  }

  Future<List<String>> getCategorias() async {
    try {
      final response = await _apiService.get('/lista-de-compras/categorias');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar categorias: ${e.toString()}');
    }
  }

  Future<List<String>> getSugestoesProdutos(String query) async {
    try {
      final response = await _apiService.get(
        '/lista-de-compras/sugestoes-produtos',
        queryParameters: {'query': query},
      );
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar sugestões: ${e.toString()}');
    }
  }
} 