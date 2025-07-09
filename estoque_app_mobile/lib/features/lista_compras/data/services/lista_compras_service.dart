import '../../../../core/services/api_service.dart';
import '../models/lista_compras_models.dart';

class ListaComprasService {
  final ApiService _apiService;

  ListaComprasService(this._apiService);

  Future<Map<String, dynamic>> getListaDeCompras() async {
    try {
      final response = await _apiService.get('/listadecompras');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar lista de compras: $e');
    }
  }

  Future<Map<String, dynamic>> aceitarSugestaoPreditiva(
    int estoqueItemId,
    int quantidadeDesejada,
  ) async {
    try {
      final response = await _apiService.post(
        '/listadecompras/aceitar-sugestao/$estoqueItemId',
        data: {'quantidadeDesejada': quantidadeDesejada},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao aceitar sugestão: $e');
    }
  }

  Future<Map<String, dynamic>> adicionarItemManual(
    String descricaoManual,
    int quantidadeDesejada,
  ) async {
    try {
      final response = await _apiService.post(
        '/listadecompras/manual',
        data: {
          'descricaoManual': descricaoManual,
          'quantidadeDesejada': quantidadeDesejada,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar item manual: $e');
    }
  }

  Future<bool> marcarComoComprado(int itemId) async {
    try {
      final response = await _apiService.put(
        '/listadecompras/$itemId/marcar-comprado',
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao marcar como comprado: $e');
    }
  }

  Future<bool> removerItem(int itemId) async {
    try {
      final response = await _apiService.delete('/listadecompras/$itemId');

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao remover item: $e');
    }
  }

  Future<Map<String, dynamic>> getHistorico() async {
    try {
      final response = await _apiService.get('/listadecompras/historico');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro no servidor: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar histórico: $e');
    }
  }

  // COMENTADO: Endpoint não existe no backend
  // Future<Map<String, dynamic>> editarItem(
  //   int itemId, {
  //   int? quantidadeDesejada,
  //   String? descricaoManual,
  //   int? despensaId,
  // }) async {
  //   try {
  //     final data = <String, dynamic>{};
  //
  //     if (quantidadeDesejada != null) {
  //       data['quantidadeDesejada'] = quantidadeDesejada;
  //     }
  //
  //     if (descricaoManual != null) {
  //       data['descricaoManual'] = descricaoManual;
  //     }
  //
  //     if (despensaId != null) {
  //       data['despensaId'] = despensaId;
  //     }
  //
  //     final response = await _apiService.put(
  //       '/listadecompras/$itemId',
  //       data: data,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       throw Exception('Erro no servidor: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erro ao editar item: $e');
  //   }
  // }

  // COMENTADO: Endpoint não existe no backend
  // Future<Map<String, dynamic>> getCategorias() async {
  //   try {
  //     final response = await _apiService.get('/listadecompras/categorias');
  //
  //     if (response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       throw Exception('Erro no servidor: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erro ao carregar categorias: $e');
  //   }
  // }

  // COMENTADO: Endpoint não existe no backend
  // Future<Map<String, dynamic>> getSugestoesProdutos() async {
  //   try {
  //     final response = await _apiService.post(
  //       '/listadecompras/sugestoes-produtos',
  //       data: {},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       throw Exception('Erro no servidor: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erro ao carregar sugestões: $e');
  //   }
  // }
}
