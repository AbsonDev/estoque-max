import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService(this._apiService);

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final response = await _apiService.get('/subscription/status');
      return SubscriptionStatus.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar status da assinatura: ${e.toString()}');
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await _apiService.get('/subscription/plans');
      return (response.data as List)
          .map((plan) => SubscriptionPlan.fromJson(plan))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar planos: ${e.toString()}');
    }
  }

  Future<List<FeatureComparison>> getFeatureComparison() async {
    try {
      final response = await _apiService.get('/subscription/features');
      return (response.data as List)
          .map((feature) => FeatureComparison.fromJson(feature))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar comparação de recursos: ${e.toString()}');
    }
  }

  Future<SubscriptionAnalytics> getSubscriptionAnalytics() async {
    try {
      final response = await _apiService.get('/subscription/analytics');
      return SubscriptionAnalytics.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao carregar analytics da assinatura: ${e.toString()}');
    }
  }

  Future<List<SubscriptionHistory>> getSubscriptionHistory() async {
    try {
      final response = await _apiService.get('/subscription/history');
      return (response.data as List)
          .map((history) => SubscriptionHistory.fromJson(history))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar histórico da assinatura: ${e.toString()}');
    }
  }

  Future<String> createCheckoutSession(String planId) async {
    try {
      final response = await _apiService.post(
        '/payments/create-checkout-session',
        data: {'planId': planId},
      );
      return response.data['url'] ?? '';
    } catch (e) {
      throw Exception('Erro ao criar sessão de pagamento: ${e.toString()}');
    }
  }

  Future<String> createCustomerPortalSession() async {
    try {
      final response = await _apiService.post('/payments/create-customer-portal-session');
      return response.data['url'] ?? '';
    } catch (e) {
      throw Exception('Erro ao criar sessão do portal: ${e.toString()}');
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await _apiService.post('/subscription/cancel');
    } catch (e) {
      throw Exception('Erro ao cancelar assinatura: ${e.toString()}');
    }
  }

  Future<void> upgradeSubscription(String planId) async {
    try {
      await _apiService.post('/subscription/upgrade', data: {'planId': planId});
    } catch (e) {
      throw Exception('Erro ao fazer upgrade da assinatura: ${e.toString()}');
    }
  }

  Future<bool> checkFeatureAccess(String feature) async {
    try {
      final response = await _apiService.get('/subscription/check-feature/$feature');
      return response.data['hasAccess'] ?? false;
    } catch (e) {
      throw Exception('Erro ao verificar acesso ao recurso: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUsageLimits() async {
    try {
      final response = await _apiService.get('/subscription/usage-limits');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao carregar limites de uso: ${e.toString()}');
    }
  }
} 