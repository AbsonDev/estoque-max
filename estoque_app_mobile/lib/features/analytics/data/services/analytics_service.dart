import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/analytics_models.dart';

class AnalyticsService {
  final ApiService _apiService;

  AnalyticsService(this._apiService);

  Future<AnalyticsDashboard> getDashboard({int? despensaId}) async {
    try {
      final response = await _apiService.get(
        despensaId != null 
          ? '/analytics/dashboard-despensa/$despensaId'
          : '/analytics/dashboard',
      );
      
      return AnalyticsDashboard.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar dashboard: ${e.toString()}');
    }
  }

  Future<List<ConsumoCategoria>> getConsumoCategoria() async {
    try {
      final response = await _apiService.get('/analytics/consumo-por-categoria');
      return (response.data as List)
          .map((item) => ConsumoCategoria.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar consumo por categoria: ${e.toString()}');
    }
  }

  Future<List<TopProduto>> getTopProdutos() async {
    try {
      final response = await _apiService.get('/analytics/top-produtos');
      return (response.data as List)
          .map((item) => TopProduto.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar top produtos: ${e.toString()}');
    }
  }

  Future<List<GastoMensal>> getGastosMensais() async {
    try {
      final response = await _apiService.get('/analytics/gastos-mensais');
      return (response.data as List)
          .map((item) => GastoMensal.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar gastos mensais: ${e.toString()}');
    }
  }

  Future<List<GastoMensal>> getGastosCategoria() async {
    try {
      final response = await _apiService.get('/analytics/gastos-por-categoria');
      return (response.data as List)
          .map((item) => GastoMensal.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar gastos por categoria: ${e.toString()}');
    }
  }

  Future<List<TendenciaDesperdicio>> getTendenciaDesperdicio() async {
    try {
      final response = await _apiService.get('/analytics/tendencia-desperdicio');
      return (response.data as List)
          .map((item) => TendenciaDesperdicio.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar tendência de desperdício: ${e.toString()}');
    }
  }

  Future<List<ItemExpirado>> getItensExpirados() async {
    try {
      final response = await _apiService.get('/analytics/itens-expirados-no-mes');
      return (response.data as List)
          .map((item) => ItemExpirado.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar itens expirados: ${e.toString()}');
    }
  }

  Future<List<HeatmapData>> getHeatmapConsumo() async {
    try {
      final response = await _apiService.get('/analytics/heatmap-consumo');
      return (response.data as List)
          .map((item) => HeatmapData.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar heatmap de consumo: ${e.toString()}');
    }
  }

  Future<List<IndicadorChave>> getIndicadoresChave() async {
    try {
      final response = await _apiService.get('/analytics/indicadores-chave');
      return (response.data as List)
          .map((item) => IndicadorChave.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar indicadores: ${e.toString()}');
    }
  }

  Future<List<InsightAI>> getInsights() async {
    try {
      final response = await _apiService.get('/analytics/insights');
      return (response.data as List)
          .map((item) => InsightAI.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar insights: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getComparacaoConsumo({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final response = await _apiService.get(
        '/analytics/comparacao-consumo-periodica',
        queryParameters: {
          'dataInicio': dataInicio.toIso8601String(),
          'dataFim': dataFim.toIso8601String(),
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao carregar comparação de consumo: ${e.toString()}');
    }
  }

  Future<void> refreshAnalytics() async {
    try {
      await _apiService.post('/analytics/refresh');
    } catch (e) {
      throw Exception('Erro ao atualizar analytics: ${e.toString()}');
    }
  }

  Future<String> exportarDados({
    required DateTime dataInicio,
    required DateTime dataFim,
    String formato = 'csv',
  }) async {
    try {
      final response = await _apiService.get(
        '/analytics/exportar-dados',
        queryParameters: {
          'dataInicio': dataInicio.toIso8601String(),
          'dataFim': dataFim.toIso8601String(),
          'formato': formato,
        },
      );
      return response.data['url'] ?? '';
    } catch (e) {
      throw Exception('Erro ao exportar dados: ${e.toString()}');
    }
  }
} 