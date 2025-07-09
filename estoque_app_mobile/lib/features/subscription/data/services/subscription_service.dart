import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService(this._apiService);

  // Configuração do RevenueCat
  Future<void> configureRevenueCat() async {
    try {
      // Configurar RevenueCat com sua chave
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration('google_play_api_key');
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration('app_store_api_key');
      } else {
        return;
      }

      await Purchases.configure(configuration);
    } catch (e) {
      debugPrint('Error configuring RevenueCat: $e');
      throw Exception('Erro ao configurar sistema de assinaturas');
    }
  }

  // Obtém a assinatura atual do usuário
  Future<UserSubscription> getCurrentSubscription() async {
    try {
      final response = await _apiService.get('/subscription/current');
      return UserSubscription.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting current subscription: $e');
      throw Exception('Erro ao obter assinatura atual');
    }
  }

  // Obtém todos os planos disponíveis
  Future<List<SubscriptionTier>> getAvailableTiers() async {
    try {
      final response = await _apiService.get('/subscription/tiers');
      return (response.data as List)
          .map((tier) => SubscriptionTier.fromJson(tier))
          .toList();
    } catch (e) {
      debugPrint('Error getting available tiers: $e');
      throw Exception('Erro ao obter planos disponíveis');
    }
  }

  // Obtém os limites de uso atuais
  Future<UsageLimits> getUsageLimits() async {
    try {
      final response = await _apiService.get('/subscription/usage');
      return UsageLimits.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting usage limits: $e');
      throw Exception('Erro ao obter limites de uso');
    }
  }

  // Obtém o acesso a funcionalidades
  Future<FeatureAccess> getFeatureAccess() async {
    try {
      final response = await _apiService.get('/subscription/features');
      return FeatureAccess.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting feature access: $e');
      throw Exception('Erro ao obter acesso a funcionalidades');
    }
  }

  // Verifica se uma funcionalidade está disponível
  Future<bool> hasFeatureAccess(String feature) async {
    try {
      final response = await _apiService.get('/subscription/features/$feature');
      return response.data['hasAccess'] ?? false;
    } catch (e) {
      debugPrint('Error checking feature access: $e');
      return false;
    }
  }

  // Obtém informações do paywall para uma funcionalidade
  Future<PaywallInfo> getPaywallInfo(String feature) async {
    try {
      final response = await _apiService.get('/subscription/paywall/$feature');
      return PaywallInfo.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting paywall info: $e');
      throw Exception('Erro ao obter informações do paywall');
    }
  }

  // Obtém ofertas do RevenueCat
  Future<Offerings> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      throw Exception('Erro ao obter ofertas');
    }
  }

  // Realiza compra
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);

      // Notifica o backend sobre a compra
      await _syncPurchaseWithBackend(purchaserInfo);

      return purchaserInfo;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      throw Exception('Erro ao processar compra');
    }
  }

  // Restaura compras
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      // Sincroniza com o backend
      await _syncPurchaseWithBackend(customerInfo);

      return customerInfo;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      throw Exception('Erro ao restaurar compras');
    }
  }

  // Sincroniza compra com o backend
  Future<void> _syncPurchaseWithBackend(CustomerInfo customerInfo) async {
    try {
      await _apiService.post(
        '/subscription/sync',
        data: {
          'customerInfo': customerInfo.toJson(),
          'activeSubscriptions': customerInfo.activeSubscriptions,
          'entitlements': customerInfo.entitlements.active,
        },
      );
    } catch (e) {
      debugPrint('Error syncing purchase with backend: $e');
      // Não lança erro para não interromper o fluxo de compra
    }
  }

  // Obtém informações do cliente
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      throw Exception('Erro ao obter informações do cliente');
    }
  }

  // Identifica o usuário no RevenueCat
  Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('Error identifying user: $e');
      throw Exception('Erro ao identificar usuário');
    }
  }

  // Faz logout do usuário
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Error logging out user: $e');
      throw Exception('Erro ao fazer logout');
    }
  }

  // Cancela assinatura
  Future<void> cancelSubscription() async {
    try {
      await _apiService.post('/subscription/cancel');
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
      throw Exception('Erro ao cancelar assinatura');
    }
  }

  // Reativa assinatura
  Future<void> reactivateSubscription() async {
    try {
      await _apiService.post('/subscription/reactivate');
    } catch (e) {
      debugPrint('Error reactivating subscription: $e');
      throw Exception('Erro ao reativar assinatura');
    }
  }

  // Obtém histórico de faturas
  Future<List<Map<String, dynamic>>> getBillingHistory() async {
    try {
      final response = await _apiService.get('/subscription/billing-history');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      debugPrint('Error getting billing history: $e');
      throw Exception('Erro ao obter histórico de faturas');
    }
  }

  // Helpers para verificar limites
  Future<bool> canAddDespensa() async {
    final limits = await getUsageLimits();
    return limits.canAddDespensa;
  }

  Future<bool> canAddMembro() async {
    final limits = await getUsageLimits();
    return limits.canAddMembro;
  }

  Future<bool> canAddItem() async {
    final limits = await getUsageLimits();
    return limits.canAddItem;
  }

  // Helpers para verificar funcionalidades
  Future<bool> hasAnalytics() async {
    return await hasFeatureAccess('analytics');
  }

  Future<bool> hasAIPredictions() async {
    return await hasFeatureAccess('ai_predictions');
  }

  Future<bool> hasExport() async {
    return await hasFeatureAccess('export');
  }

  Future<bool> hasScanner() async {
    return await hasFeatureAccess('scanner');
  }

  // Inicia trial gratuito
  Future<void> startFreeTrial() async {
    try {
      await _apiService.post('/subscription/trial/start');
    } catch (e) {
      debugPrint('Error starting free trial: $e');
      throw Exception('Erro ao iniciar trial gratuito');
    }
  }

  // Verifica se pode iniciar trial
  Future<bool> canStartFreeTrial() async {
    try {
      final response = await _apiService.get('/subscription/trial/available');
      return response.data['canStart'] ?? false;
    } catch (e) {
      debugPrint('Error checking trial availability: $e');
      return false;
    }
  }
}
