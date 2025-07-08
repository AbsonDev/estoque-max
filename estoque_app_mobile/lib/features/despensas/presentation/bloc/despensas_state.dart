import 'package:equatable/equatable.dart';
import '../../data/models/despensa.dart';
import '../../data/services/despensas_service.dart';

abstract class DespensasState extends Equatable {
  const DespensasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DespensasInitial extends DespensasState {
  const DespensasInitial();
}

/// Estado de carregamento
class DespensasLoading extends DespensasState {
  const DespensasLoading();
}

/// Estado de carregamento com dados existentes (para refresh)
class DespensasRefreshing extends DespensasState {
  final List<Despensa> despensas;

  const DespensasRefreshing(this.despensas);

  @override
  List<Object> get props => [despensas];
}

/// Estado de sucesso com lista de despensas
class DespensasLoaded extends DespensasState {
  final List<Despensa> despensas;
  final Despensa? despensaSelecionada;
  final String? successMessage;

  const DespensasLoaded({
    required this.despensas,
    this.despensaSelecionada,
    this.successMessage,
  });

  DespensasLoaded copyWith({
    List<Despensa>? despensas,
    Despensa? despensaSelecionada,
    String? successMessage,
    bool clearDespensaSelecionada = false,
    bool clearSuccessMessage = false,
  }) {
    return DespensasLoaded(
      despensas: despensas ?? this.despensas,
      despensaSelecionada: clearDespensaSelecionada ? null : (despensaSelecionada ?? this.despensaSelecionada),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [despensas, despensaSelecionada, successMessage];
}

/// Estado de erro
class DespensasError extends DespensasState {
  final String message;
  final List<Despensa>? despensas; // Para manter dados existentes em caso de erro

  const DespensasError({
    required this.message,
    this.despensas,
  });

  @override
  List<Object?> get props => [message, despensas];
}

/// Estado específico para quando é necessário upgrade do plano
class DespensasUpgradeRequired extends DespensasState {
  final String message;
  final String upgradeMessage;
  final String? currentPlan;
  final int? limit;
  final String? feature;
  final List<Despensa> despensas;

  const DespensasUpgradeRequired({
    required this.message,
    required this.upgradeMessage,
    this.currentPlan,
    this.limit,
    this.feature,
    required this.despensas,
  });

  factory DespensasUpgradeRequired.fromException(
    UpgradeRequiredException exception,
    List<Despensa> despensas,
  ) {
    return DespensasUpgradeRequired(
      message: exception.message,
      upgradeMessage: exception.upgradeMessage,
      currentPlan: exception.currentPlan,
      limit: exception.limit,
      feature: exception.feature,
      despensas: despensas,
    );
  }

  @override
  List<Object?> get props => [message, upgradeMessage, currentPlan, limit, feature, despensas];
}

/// Estado para operações que afetam uma despensa específica
class DespensaOperationLoading extends DespensasState {
  final List<Despensa> despensas;
  final int? despensaId; // ID da despensa sendo afetada
  final String operation; // Tipo de operação (create, update, delete, etc.)

  const DespensaOperationLoading({
    required this.despensas,
    this.despensaId,
    required this.operation,
  });

  @override
  List<Object?> get props => [despensas, despensaId, operation];
}

/// Estado para detalhes de uma despensa específica
class DespensaDetalhesLoaded extends DespensasState {
  final Despensa despensa;
  final List<Despensa> todasDespensas; // Manter referência à lista completa

  const DespensaDetalhesLoaded({
    required this.despensa,
    required this.todasDespensas,
  });

  @override
  List<Object> get props => [despensa, todasDespensas];
}

/// Estado para quando nenhuma despensa foi encontrada
class DespensasEmpty extends DespensasState {
  const DespensasEmpty();
} 