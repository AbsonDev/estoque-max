import 'package:equatable/equatable.dart';

class SubscriptionStatus extends Equatable {
  final String planId;
  final String planName;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final double price;
  final String currency;
  final String billingInterval;
  final List<String> features;
  final bool cancelAtPeriodEnd;
  final DateTime? cancelDate;
  final bool isTrialPeriod;
  final DateTime? trialEndDate;

  const SubscriptionStatus({
    required this.planId,
    required this.planName,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.status,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.features,
    required this.cancelAtPeriodEnd,
    this.cancelDate,
    required this.isTrialPeriod,
    this.trialEndDate,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      isActive: json['isActive'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      status: json['status'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'BRL',
      billingInterval: json['billingInterval'] ?? 'month',
      features: List<String>.from(json['features'] ?? []),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
      cancelDate: json['cancelDate'] != null
          ? DateTime.parse(json['cancelDate'])
          : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planName': planName,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'price': price,
      'currency': currency,
      'billingInterval': billingInterval,
      'features': features,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      'cancelDate': cancelDate?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
      'trialEndDate': trialEndDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    planId, planName, isActive, startDate, endDate, status, price, currency,
    billingInterval, features, cancelAtPeriodEnd, cancelDate, isTrialPeriod, trialEndDate,
  ];
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingInterval;
  final List<String> features;
  final bool isPopular;
  final bool isCurrentPlan;
  final String? stripeProductId;
  final int maxDespensas;
  final int maxItensEstoque;
  final int maxMembrosPorDespensa;
  final bool hasAnalytics;
  final bool hasAISuggestions;
  final bool hasExport;
  final bool hasSupport;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.features,
    required this.isPopular,
    required this.isCurrentPlan,
    this.stripeProductId,
    required this.maxDespensas,
    required this.maxItensEstoque,
    required this.maxMembrosPorDespensa,
    required this.hasAnalytics,
    required this.hasAISuggestions,
    required this.hasExport,
    required this.hasSupport,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'BRL',
      billingInterval: json['billingInterval'] ?? 'month',
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['isPopular'] ?? false,
      isCurrentPlan: json['isCurrentPlan'] ?? false,
      stripeProductId: json['stripeProductId'],
      maxDespensas: json['maxDespensas'] ?? 0,
      maxItensEstoque: json['maxItensEstoque'] ?? 0,
      maxMembrosPorDespensa: json['maxMembrosPorDespensa'] ?? 0,
      hasAnalytics: json['hasAnalytics'] ?? false,
      hasAISuggestions: json['hasAISuggestions'] ?? false,
      hasExport: json['hasExport'] ?? false,
      hasSupport: json['hasSupport'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'billingInterval': billingInterval,
      'features': features,
      'isPopular': isPopular,
      'isCurrentPlan': isCurrentPlan,
      'stripeProductId': stripeProductId,
      'maxDespensas': maxDespensas,
      'maxItensEstoque': maxItensEstoque,
      'maxMembrosPorDespensa': maxMembrosPorDespensa,
      'hasAnalytics': hasAnalytics,
      'hasAISuggestions': hasAISuggestions,
      'hasExport': hasExport,
      'hasSupport': hasSupport,
    };
  }

  @override
  List<Object?> get props => [
    id, name, description, price, currency, billingInterval, features, isPopular,
    isCurrentPlan, stripeProductId, maxDespensas, maxItensEstoque, maxMembrosPorDespensa,
    hasAnalytics, hasAISuggestions, hasExport, hasSupport,
  ];
}

class SubscriptionHistory extends Equatable {
  final String id;
  final String planName;
  final double amount;
  final String currency;
  final DateTime date;
  final String status;
  final String? invoiceUrl;
  final String? description;

  const SubscriptionHistory({
    required this.id,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    this.invoiceUrl,
    this.description,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'BRL',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? '',
      invoiceUrl: json['invoiceUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'status': status,
      'invoiceUrl': invoiceUrl,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, planName, amount, currency, date, status, invoiceUrl, description];
}

class SubscriptionAnalytics extends Equatable {
  final int totalDespensas;
  final int totalItensEstoque;
  final int totalMembros;
  final double totalGasto;
  final int limiteDespensas;
  final int limiteItensEstoque;
  final int limiteMembros;
  final DateTime? proximoVencimento;
  final List<String> featuresUsadas;
  final List<String> featuresDisponiveis;

  const SubscriptionAnalytics({
    required this.totalDespensas,
    required this.totalItensEstoque,
    required this.totalMembros,
    required this.totalGasto,
    required this.limiteDespensas,
    required this.limiteItensEstoque,
    required this.limiteMembros,
    this.proximoVencimento,
    required this.featuresUsadas,
    required this.featuresDisponiveis,
  });

  factory SubscriptionAnalytics.fromJson(Map<String, dynamic> json) {
    return SubscriptionAnalytics(
      totalDespensas: json['totalDespensas'] ?? 0,
      totalItensEstoque: json['totalItensEstoque'] ?? 0,
      totalMembros: json['totalMembros'] ?? 0,
      totalGasto: (json['totalGasto'] as num?)?.toDouble() ?? 0.0,
      limiteDespensas: json['limiteDespensas'] ?? 0,
      limiteItensEstoque: json['limiteItensEstoque'] ?? 0,
      limiteMembros: json['limiteMembros'] ?? 0,
      proximoVencimento: json['proximoVencimento'] != null
          ? DateTime.parse(json['proximoVencimento'])
          : null,
      featuresUsadas: List<String>.from(json['featuresUsadas'] ?? []),
      featuresDisponiveis: List<String>.from(json['featuresDisponiveis'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDespensas': totalDespensas,
      'totalItensEstoque': totalItensEstoque,
      'totalMembros': totalMembros,
      'totalGasto': totalGasto,
      'limiteDespensas': limiteDespensas,
      'limiteItensEstoque': limiteItensEstoque,
      'limiteMembros': limiteMembros,
      'proximoVencimento': proximoVencimento?.toIso8601String(),
      'featuresUsadas': featuresUsadas,
      'featuresDisponiveis': featuresDisponiveis,
    };
  }

  @override
  List<Object?> get props => [
    totalDespensas, totalItensEstoque, totalMembros, totalGasto, limiteDespensas,
    limiteItensEstoque, limiteMembros, proximoVencimento, featuresUsadas, featuresDisponiveis,
  ];
}

class FeatureComparison extends Equatable {
  final String feature;
  final String freeValue;
  final String premiumValue;
  final String description;

  const FeatureComparison({
    required this.feature,
    required this.freeValue,
    required this.premiumValue,
    required this.description,
  });

  factory FeatureComparison.fromJson(Map<String, dynamic> json) {
    return FeatureComparison(
      feature: json['feature'] ?? '',
      freeValue: json['freeValue'] ?? '',
      premiumValue: json['premiumValue'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'freeValue': freeValue,
      'premiumValue': premiumValue,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [feature, freeValue, premiumValue, description];
}

// Helper extensions
extension SubscriptionStatusExtensions on SubscriptionStatus {
  bool get isFree => planId == 'free';
  bool get isPremium => planId == 'premium';
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());
  bool get isTrialActive => isTrialPeriod && trialEndDate != null && trialEndDate!.isAfter(DateTime.now());
  
  int get daysUntilExpiry {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }
}

extension SubscriptionPlanExtensions on SubscriptionPlan {
  bool get isFree => id == 'free';
  bool get isPremium => id == 'premium';
  
  String get formattedPrice {
    if (price == 0) return 'Grátis';
    return 'R\$ ${price.toStringAsFixed(2)}${billingInterval == 'month' ? '/mês' : '/ano'}';
  }
} 