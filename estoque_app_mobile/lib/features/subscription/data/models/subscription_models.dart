import 'package:equatable/equatable.dart';

class SubscriptionTier extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String period;
  final List<String> features;
  final bool isActive;
  final int maxDespensas;
  final int maxMembros;
  final int maxItens;
  final bool hasAnalytics;
  final bool hasAIPredictions;
  final bool hasExport;
  final bool hasScanner;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.period,
    required this.features,
    required this.isActive,
    required this.maxDespensas,
    required this.maxMembros,
    required this.maxItens,
    required this.hasAnalytics,
    required this.hasAIPredictions,
    required this.hasExport,
    required this.hasScanner,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      period: json['period'] ?? 'monthly',
      features: List<String>.from(json['features'] ?? []),
      isActive: json['isActive'] ?? false,
      maxDespensas: json['maxDespensas'] ?? 0,
      maxMembros: json['maxMembros'] ?? 0,
      maxItens: json['maxItens'] ?? 0,
      hasAnalytics: json['hasAnalytics'] ?? false,
      hasAIPredictions: json['hasAIPredictions'] ?? false,
      hasExport: json['hasExport'] ?? false,
      hasScanner: json['hasScanner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'period': period,
      'features': features,
      'isActive': isActive,
      'maxDespensas': maxDespensas,
      'maxMembros': maxMembros,
      'maxItens': maxItens,
      'hasAnalytics': hasAnalytics,
      'hasAIPredictions': hasAIPredictions,
      'hasExport': hasExport,
      'hasScanner': hasScanner,
    };
  }

  @override
  List<Object?> get props => [
    id, name, description, price, currency, period, features, isActive,
    maxDespensas, maxMembros, maxItens, hasAnalytics, hasAIPredictions,
    hasExport, hasScanner,
  ];
}

class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String tierName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final bool isActive;
  final bool isTrial;
  final bool willRenew;
  final String? revenueId;
  final String? productId;
  final SubscriptionTier tier;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.tierName,
    required this.status,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    required this.isActive,
    required this.isTrial,
    required this.willRenew,
    this.revenueId,
    this.productId,
    required this.tier,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      tierName: json['tierName'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      isActive: json['isActive'] ?? false,
      isTrial: json['isTrial'] ?? false,
      willRenew: json['willRenew'] ?? false,
      revenueId: json['revenueId'],
      productId: json['productId'],
      tier: SubscriptionTier.fromJson(json['tier'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tierName': tierName,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'isActive': isActive,
      'isTrial': isTrial,
      'willRenew': willRenew,
      'revenueId': revenueId,
      'productId': productId,
      'tier': tier.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id, userId, tierName, status, startDate, endDate, trialEndDate,
    isActive, isTrial, willRenew, revenueId, productId, tier,
  ];
}

class UsageLimits extends Equatable {
  final int usedDespensas;
  final int usedMembros;
  final int usedItens;
  final int maxDespensas;
  final int maxMembros;
  final int maxItens;

  const UsageLimits({
    required this.usedDespensas,
    required this.usedMembros,
    required this.usedItens,
    required this.maxDespensas,
    required this.maxMembros,
    required this.maxItens,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      usedDespensas: json['usedDespensas'] ?? 0,
      usedMembros: json['usedMembros'] ?? 0,
      usedItens: json['usedItens'] ?? 0,
      maxDespensas: json['maxDespensas'] ?? 0,
      maxMembros: json['maxMembros'] ?? 0,
      maxItens: json['maxItens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usedDespensas': usedDespensas,
      'usedMembros': usedMembros,
      'usedItens': usedItens,
      'maxDespensas': maxDespensas,
      'maxMembros': maxMembros,
      'maxItens': maxItens,
    };
  }

  bool get canAddDespensa => usedDespensas < maxDespensas;
  bool get canAddMembro => usedMembros < maxMembros;
  bool get canAddItem => usedItens < maxItens;

  double get despensaUsagePercentage => maxDespensas > 0 ? (usedDespensas / maxDespensas) : 0;
  double get membroUsagePercentage => maxMembros > 0 ? (usedMembros / maxMembros) : 0;
  double get itemUsagePercentage => maxItens > 0 ? (usedItens / maxItens) : 0;

  @override
  List<Object?> get props => [
    usedDespensas, usedMembros, usedItens,
    maxDespensas, maxMembros, maxItens,
  ];
}

class FeatureAccess extends Equatable {
  final bool hasAnalytics;
  final bool hasAIPredictions;
  final bool hasExport;
  final bool hasScanner;
  final bool hasAdvancedFilters;
  final bool hasCustomCategories;
  final bool hasPrioritySupport;

  const FeatureAccess({
    required this.hasAnalytics,
    required this.hasAIPredictions,
    required this.hasExport,
    required this.hasScanner,
    required this.hasAdvancedFilters,
    required this.hasCustomCategories,
    required this.hasPrioritySupport,
  });

  factory FeatureAccess.fromJson(Map<String, dynamic> json) {
    return FeatureAccess(
      hasAnalytics: json['hasAnalytics'] ?? false,
      hasAIPredictions: json['hasAIPredictions'] ?? false,
      hasExport: json['hasExport'] ?? false,
      hasScanner: json['hasScanner'] ?? false,
      hasAdvancedFilters: json['hasAdvancedFilters'] ?? false,
      hasCustomCategories: json['hasCustomCategories'] ?? false,
      hasPrioritySupport: json['hasPrioritySupport'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasAnalytics': hasAnalytics,
      'hasAIPredictions': hasAIPredictions,
      'hasExport': hasExport,
      'hasScanner': hasScanner,
      'hasAdvancedFilters': hasAdvancedFilters,
      'hasCustomCategories': hasCustomCategories,
      'hasPrioritySupport': hasPrioritySupport,
    };
  }

  @override
  List<Object?> get props => [
    hasAnalytics, hasAIPredictions, hasExport, hasScanner,
    hasAdvancedFilters, hasCustomCategories, hasPrioritySupport,
  ];
}

class PaywallInfo extends Equatable {
  final String feature;
  final String title;
  final String description;
  final String requiredTier;
  final String buttonText;
  final String icon;

  const PaywallInfo({
    required this.feature,
    required this.title,
    required this.description,
    required this.requiredTier,
    required this.buttonText,
    required this.icon,
  });

  factory PaywallInfo.fromJson(Map<String, dynamic> json) {
    return PaywallInfo(
      feature: json['feature'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredTier: json['requiredTier'] ?? '',
      buttonText: json['buttonText'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'title': title,
      'description': description,
      'requiredTier': requiredTier,
      'buttonText': buttonText,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [
    feature, title, description, requiredTier, buttonText, icon,
  ];
}

// Predefined tiers
class SubscriptionTiers {
  static const SubscriptionTier free = SubscriptionTier(
    id: 'free',
    name: 'Gratuito',
    description: 'Perfeito para começar',
    price: 0.0,
    currency: 'EUR',
    period: 'forever',
    features: [
      '2 despensas',
      '5 membros por despensa',
      '100 itens',
      'Funcionalidades básicas',
    ],
    isActive: true,
    maxDespensas: 2,
    maxMembros: 5,
    maxItens: 100,
    hasAnalytics: false,
    hasAIPredictions: false,
    hasExport: false,
    hasScanner: false,
  );

  static const SubscriptionTier premium = SubscriptionTier(
    id: 'premium',
    name: 'Premium',
    description: 'Para famílias e uso avançado',
    price: 4.99,
    currency: 'EUR',
    period: 'monthly',
    features: [
      'Despensas ilimitadas',
      'Membros ilimitados',
      'Itens ilimitados',
      'Analytics completos',
      'Previsões de IA',
      'Exportação de dados',
      'Scanner de código de barras',
      'Suporte prioritário',
    ],
    isActive: true,
    maxDespensas: -1, // unlimited
    maxMembros: -1,
    maxItens: -1,
    hasAnalytics: true,
    hasAIPredictions: true,
    hasExport: true,
    hasScanner: true,
  );
} 