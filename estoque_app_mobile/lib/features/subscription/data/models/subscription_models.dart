class UserSubscription {
  final String id;
  final String status;
  final String tierId;
  final DateTime? expiresAt;
  final bool isActive;
  final bool isTrial;

  UserSubscription({
    required this.id,
    required this.status,
    required this.tierId,
    this.expiresAt,
    required this.isActive,
    required this.isTrial,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      status: json['status'] as String,
      tierId: json['tierId'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool,
      isTrial: json['isTrial'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'tierId': tierId,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'isTrial': isTrial,
    };
  }
}

class SubscriptionTier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String interval;
  final List<String> features;
  final Map<String, int> limits;

  SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.interval,
    required this.features,
    required this.limits,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      interval: json['interval'] as String,
      features: List<String>.from(json['features'] ?? []),
      limits: Map<String, int>.from(json['limits'] ?? {}),
    );
  }
}

class UsageLimits {
  final int maxDespensas;
  final int maxMembros;
  final int maxItens;
  final int currentDespensas;
  final int currentMembros;
  final int currentItens;
  final bool canAddDespensa;
  final bool canAddMembro;
  final bool canAddItem;

  UsageLimits({
    required this.maxDespensas,
    required this.maxMembros,
    required this.maxItens,
    required this.currentDespensas,
    required this.currentMembros,
    required this.currentItens,
    required this.canAddDespensa,
    required this.canAddMembro,
    required this.canAddItem,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      maxDespensas: json['maxDespensas'] as int,
      maxMembros: json['maxMembros'] as int,
      maxItens: json['maxItens'] as int,
      currentDespensas: json['currentDespensas'] as int,
      currentMembros: json['currentMembros'] as int,
      currentItens: json['currentItens'] as int,
      canAddDespensa: json['canAddDespensa'] as bool,
      canAddMembro: json['canAddMembro'] as bool,
      canAddItem: json['canAddItem'] as bool,
    );
  }
}

class FeatureAccess {
  final bool hasAnalytics;
  final bool hasAIPredictions;
  final bool hasExport;
  final bool hasScanner;
  final bool hasReports;
  final bool hasAdvancedFilters;

  FeatureAccess({
    required this.hasAnalytics,
    required this.hasAIPredictions,
    required this.hasExport,
    required this.hasScanner,
    required this.hasReports,
    required this.hasAdvancedFilters,
  });

  factory FeatureAccess.fromJson(Map<String, dynamic> json) {
    return FeatureAccess(
      hasAnalytics: json['hasAnalytics'] as bool,
      hasAIPredictions: json['hasAIPredictions'] as bool,
      hasExport: json['hasExport'] as bool,
      hasScanner: json['hasScanner'] as bool,
      hasReports: json['hasReports'] as bool,
      hasAdvancedFilters: json['hasAdvancedFilters'] as bool,
    );
  }
}

class PaywallInfo {
  final String feature;
  final String title;
  final String description;
  final String requiredTier;
  final bool canStartTrial;

  PaywallInfo({
    required this.feature,
    required this.title,
    required this.description,
    required this.requiredTier,
    required this.canStartTrial,
  });

  factory PaywallInfo.fromJson(Map<String, dynamic> json) {
    return PaywallInfo(
      feature: json['feature'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredTier: json['requiredTier'] as String,
      canStartTrial: json['canStartTrial'] as bool,
    );
  }
}

class SubscriptionStatus {
  final String status;
  final DateTime? renewsAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String tierName;

  SubscriptionStatus({
    required this.status,
    this.renewsAt,
    this.expiresAt,
    required this.isActive,
    required this.tierName,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      status: json['status'] as String,
      renewsAt: json['renewsAt'] != null
          ? DateTime.parse(json['renewsAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool,
      tierName: json['tierName'] as String,
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

class SubscriptionAnalytics {
  final int totalUsers;
  final int activeSubscribers;
  final double monthlyRevenue;
  final Map<String, int> subscriptionsByTier;

  SubscriptionAnalytics({
    required this.totalUsers,
    required this.activeSubscribers,
    required this.monthlyRevenue,
    required this.subscriptionsByTier,
  });

  factory SubscriptionAnalytics.fromJson(Map<String, dynamic> json) {
    return SubscriptionAnalytics(
      totalUsers: json['totalUsers'] as int,
      activeSubscribers: json['activeSubscribers'] as int,
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      subscriptionsByTier: Map<String, int>.from(
        json['subscriptionsByTier'] ?? {},
      ),
    );
  }
}

class SubscriptionHistory {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String status;

  SubscriptionHistory({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
