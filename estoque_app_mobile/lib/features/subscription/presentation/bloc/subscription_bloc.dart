import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/models/subscription_models.dart';
import '../../data/services/subscription_service.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionData extends SubscriptionEvent {}

class LoadAvailableTiers extends SubscriptionEvent {}

class LoadUsageLimits extends SubscriptionEvent {}

class LoadFeatureAccess extends SubscriptionEvent {}

class PurchaseSubscription extends SubscriptionEvent {
  final Package package;

  const PurchaseSubscription({required this.package});

  @override
  List<Object> get props => [package];
}

class RestorePurchases extends SubscriptionEvent {}

class CancelSubscription extends SubscriptionEvent {}

class ReactivateSubscription extends SubscriptionEvent {}

class CheckFeatureAccess extends SubscriptionEvent {
  final String feature;

  const CheckFeatureAccess({required this.feature});

  @override
  List<Object> get props => [feature];
}

class StartFreeTrial extends SubscriptionEvent {}

class LoadPaywallInfo extends SubscriptionEvent {
  final String feature;

  const LoadPaywallInfo({required this.feature});

  @override
  List<Object> get props => [feature];
}

class LoadBillingHistory extends SubscriptionEvent {}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final UserSubscription subscription;
  final List<SubscriptionTier> availableTiers;
  final UsageLimits usageLimits;
  final FeatureAccess featureAccess;

  const SubscriptionLoaded({
    required this.subscription,
    required this.availableTiers,
    required this.usageLimits,
    required this.featureAccess,
  });

  @override
  List<Object> get props => [subscription, availableTiers, usageLimits, featureAccess];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object> get props => [message];
}

class SubscriptionPurchasing extends SubscriptionState {}

class SubscriptionPurchased extends SubscriptionState {
  final CustomerInfo customerInfo;

  const SubscriptionPurchased({required this.customerInfo});

  @override
  List<Object> get props => [customerInfo];
}

class SubscriptionRestored extends SubscriptionState {
  final CustomerInfo customerInfo;

  const SubscriptionRestored({required this.customerInfo});

  @override
  List<Object> get props => [customerInfo];
}

class SubscriptionCanceled extends SubscriptionState {}

class SubscriptionReactivated extends SubscriptionState {}

class FeatureAccessChecked extends SubscriptionState {
  final String feature;
  final bool hasAccess;

  const FeatureAccessChecked({
    required this.feature,
    required this.hasAccess,
  });

  @override
  List<Object> get props => [feature, hasAccess];
}

class PaywallInfoLoaded extends SubscriptionState {
  final PaywallInfo paywallInfo;

  const PaywallInfoLoaded({required this.paywallInfo});

  @override
  List<Object> get props => [paywallInfo];
}

class FreeTrialStarted extends SubscriptionState {}

class BillingHistoryLoaded extends SubscriptionState {
  final List<Map<String, dynamic>> billingHistory;

  const BillingHistoryLoaded({required this.billingHistory});

  @override
  List<Object> get props => [billingHistory];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionBloc(this._subscriptionService) : super(SubscriptionInitial()) {
    on<LoadSubscriptionData>(_onLoadSubscriptionData);
    on<LoadAvailableTiers>(_onLoadAvailableTiers);
    on<LoadUsageLimits>(_onLoadUsageLimits);
    on<LoadFeatureAccess>(_onLoadFeatureAccess);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<RestorePurchases>(_onRestorePurchases);
    on<CancelSubscription>(_onCancelSubscription);
    on<ReactivateSubscription>(_onReactivateSubscription);
    on<CheckFeatureAccess>(_onCheckFeatureAccess);
    on<StartFreeTrial>(_onStartFreeTrial);
    on<LoadPaywallInfo>(_onLoadPaywallInfo);
    on<LoadBillingHistory>(_onLoadBillingHistory);
  }

  Future<void> _onLoadSubscriptionData(
    LoadSubscriptionData event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _subscriptionService.getCurrentSubscription();
      final availableTiers = await _subscriptionService.getAvailableTiers();
      final usageLimits = await _subscriptionService.getUsageLimits();
      final featureAccess = await _subscriptionService.getFeatureAccess();

      emit(SubscriptionLoaded(
        subscription: subscription,
        availableTiers: availableTiers,
        usageLimits: usageLimits,
        featureAccess: featureAccess,
      ));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadAvailableTiers(
    LoadAvailableTiers event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final availableTiers = await _subscriptionService.getAvailableTiers();
      // Preserva outros dados se existirem
      if (state is SubscriptionLoaded) {
        final current = state as SubscriptionLoaded;
        emit(SubscriptionLoaded(
          subscription: current.subscription,
          availableTiers: availableTiers,
          usageLimits: current.usageLimits,
          featureAccess: current.featureAccess,
        ));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadUsageLimits(
    LoadUsageLimits event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final usageLimits = await _subscriptionService.getUsageLimits();
      // Preserva outros dados se existirem
      if (state is SubscriptionLoaded) {
        final current = state as SubscriptionLoaded;
        emit(SubscriptionLoaded(
          subscription: current.subscription,
          availableTiers: current.availableTiers,
          usageLimits: usageLimits,
          featureAccess: current.featureAccess,
        ));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadFeatureAccess(
    LoadFeatureAccess event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final featureAccess = await _subscriptionService.getFeatureAccess();
      // Preserva outros dados se existirem
      if (state is SubscriptionLoaded) {
        final current = state as SubscriptionLoaded;
        emit(SubscriptionLoaded(
          subscription: current.subscription,
          availableTiers: current.availableTiers,
          usageLimits: current.usageLimits,
          featureAccess: featureAccess,
        ));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionPurchasing());
    try {
      final customerInfo = await _subscriptionService.purchasePackage(event.package);
      emit(SubscriptionPurchased(customerInfo: customerInfo));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await _subscriptionService.restorePurchases();
      emit(SubscriptionRestored(customerInfo: customerInfo));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      await _subscriptionService.cancelSubscription();
      emit(SubscriptionCanceled());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onReactivateSubscription(
    ReactivateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      await _subscriptionService.reactivateSubscription();
      emit(SubscriptionReactivated());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCheckFeatureAccess(
    CheckFeatureAccess event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final hasAccess = await _subscriptionService.hasFeatureAccess(event.feature);
      emit(FeatureAccessChecked(
        feature: event.feature,
        hasAccess: hasAccess,
      ));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onStartFreeTrial(
    StartFreeTrial event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      await _subscriptionService.startFreeTrial();
      emit(FreeTrialStarted());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadPaywallInfo(
    LoadPaywallInfo event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final paywallInfo = await _subscriptionService.getPaywallInfo(event.feature);
      emit(PaywallInfoLoaded(paywallInfo: paywallInfo));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadBillingHistory(
    LoadBillingHistory event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final billingHistory = await _subscriptionService.getBillingHistory();
      emit(BillingHistoryLoaded(billingHistory: billingHistory));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }
} 