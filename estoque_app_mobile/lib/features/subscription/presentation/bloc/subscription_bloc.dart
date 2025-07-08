import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_models.dart';
import '../../data/services/subscription_service.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSubscriptionStatus extends SubscriptionEvent {}

class LoadAvailablePlans extends SubscriptionEvent {}

class LoadFeatureComparison extends SubscriptionEvent {}

class LoadSubscriptionAnalytics extends SubscriptionEvent {}

class LoadSubscriptionHistory extends SubscriptionEvent {}

class CreateCheckoutSession extends SubscriptionEvent {
  final String planId;

  CreateCheckoutSession({required this.planId});

  @override
  List<Object?> get props => [planId];
}

class CreateCustomerPortalSession extends SubscriptionEvent {}

class CancelSubscription extends SubscriptionEvent {}

class UpgradeSubscription extends SubscriptionEvent {
  final String planId;

  UpgradeSubscription({required this.planId});

  @override
  List<Object?> get props => [planId];
}

class CheckFeatureAccess extends SubscriptionEvent {
  final String feature;

  CheckFeatureAccess({required this.feature});

  @override
  List<Object?> get props => [feature];
}

class RefreshSubscriptionData extends SubscriptionEvent {}

// States
abstract class SubscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionStatusLoaded extends SubscriptionState {
  final SubscriptionStatus status;

  SubscriptionStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;

  SubscriptionPlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionAnalyticsLoaded extends SubscriptionState {
  final SubscriptionAnalytics analytics;

  SubscriptionAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class SubscriptionHistoryLoaded extends SubscriptionState {
  final List<SubscriptionHistory> history;

  SubscriptionHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class FeatureComparisonLoaded extends SubscriptionState {
  final List<FeatureComparison> features;

  FeatureComparisonLoaded(this.features);

  @override
  List<Object?> get props => [features];
}

class CheckoutSessionCreated extends SubscriptionState {
  final String url;

  CheckoutSessionCreated(this.url);

  @override
  List<Object?> get props => [url];
}

class CustomerPortalSessionCreated extends SubscriptionState {
  final String url;

  CustomerPortalSessionCreated(this.url);

  @override
  List<Object?> get props => [url];
}

class SubscriptionCancelled extends SubscriptionState {}

class SubscriptionUpgraded extends SubscriptionState {}

class FeatureAccessChecked extends SubscriptionState {
  final String feature;
  final bool hasAccess;

  FeatureAccessChecked(this.feature, this.hasAccess);

  @override
  List<Object?> get props => [feature, hasAccess];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionProcessing extends SubscriptionState {}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionBloc(this._subscriptionService) : super(SubscriptionInitial()) {
    on<LoadSubscriptionStatus>(_onLoadSubscriptionStatus);
    on<LoadAvailablePlans>(_onLoadAvailablePlans);
    on<LoadFeatureComparison>(_onLoadFeatureComparison);
    on<LoadSubscriptionAnalytics>(_onLoadSubscriptionAnalytics);
    on<LoadSubscriptionHistory>(_onLoadSubscriptionHistory);
    on<CreateCheckoutSession>(_onCreateCheckoutSession);
    on<CreateCustomerPortalSession>(_onCreateCustomerPortalSession);
    on<CancelSubscription>(_onCancelSubscription);
    on<UpgradeSubscription>(_onUpgradeSubscription);
    on<CheckFeatureAccess>(_onCheckFeatureAccess);
    on<RefreshSubscriptionData>(_onRefreshSubscriptionData);
  }

  Future<void> _onLoadSubscriptionStatus(
    LoadSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final status = await _subscriptionService.getSubscriptionStatus();
      emit(SubscriptionStatusLoaded(status));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadAvailablePlans(
    LoadAvailablePlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final plans = await _subscriptionService.getAvailablePlans();
      emit(SubscriptionPlansLoaded(plans));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadFeatureComparison(
    LoadFeatureComparison event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final features = await _subscriptionService.getFeatureComparison();
      emit(FeatureComparisonLoaded(features));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionAnalytics(
    LoadSubscriptionAnalytics event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final analytics = await _subscriptionService.getSubscriptionAnalytics();
      emit(SubscriptionAnalyticsLoaded(analytics));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionHistory(
    LoadSubscriptionHistory event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final history = await _subscriptionService.getSubscriptionHistory();
      emit(SubscriptionHistoryLoaded(history));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCreateCheckoutSession(
    CreateCheckoutSession event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());
      final url = await _subscriptionService.createCheckoutSession(event.planId);
      emit(CheckoutSessionCreated(url));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCreateCustomerPortalSession(
    CreateCustomerPortalSession event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());
      final url = await _subscriptionService.createCustomerPortalSession();
      emit(CustomerPortalSessionCreated(url));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());
      await _subscriptionService.cancelSubscription();
      emit(SubscriptionCancelled());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onUpgradeSubscription(
    UpgradeSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());
      await _subscriptionService.upgradeSubscription(event.planId);
      emit(SubscriptionUpgraded());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCheckFeatureAccess(
    CheckFeatureAccess event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final hasAccess = await _subscriptionService.checkFeatureAccess(event.feature);
      emit(FeatureAccessChecked(event.feature, hasAccess));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onRefreshSubscriptionData(
    RefreshSubscriptionData event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());
      final status = await _subscriptionService.getSubscriptionStatus();
      emit(SubscriptionStatusLoaded(status));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
} 