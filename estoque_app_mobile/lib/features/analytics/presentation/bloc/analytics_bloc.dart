import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/analytics_models.dart';
import '../../data/services/analytics_service.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends AnalyticsEvent {
  final int? despensaId;

  LoadDashboard({this.despensaId});

  @override
  List<Object?> get props => [despensaId];
}

class RefreshAnalytics extends AnalyticsEvent {}

class LoadConsumoCategoria extends AnalyticsEvent {}

class LoadTopProdutos extends AnalyticsEvent {}

class LoadGastosMensais extends AnalyticsEvent {}

class LoadTendenciaDesperdicio extends AnalyticsEvent {}

class LoadItensExpirados extends AnalyticsEvent {}

class LoadInsights extends AnalyticsEvent {}

class ExportarDados extends AnalyticsEvent {
  final DateTime dataInicio;
  final DateTime dataFim;
  final String formato;

  ExportarDados({
    required this.dataInicio,
    required this.dataFim,
    this.formato = 'csv',
  });

  @override
  List<Object?> get props => [dataInicio, dataFim, formato];
}

// States
abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsRefreshing extends AnalyticsState {
  final AnalyticsDashboard currentDashboard;

  AnalyticsRefreshing(this.currentDashboard);

  @override
  List<Object?> get props => [currentDashboard];
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsDashboard dashboard;

  AnalyticsLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalyticsExporting extends AnalyticsState {}

class AnalyticsExported extends AnalyticsState {
  final String downloadUrl;

  AnalyticsExported(this.downloadUrl);

  @override
  List<Object?> get props => [downloadUrl];
}

// BLoC
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsBloc(this._analyticsService) : super(AnalyticsInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<LoadConsumoCategoria>(_onLoadConsumoCategoria);
    on<LoadTopProdutos>(_onLoadTopProdutos);
    on<LoadGastosMensais>(_onLoadGastosMensais);
    on<LoadTendenciaDesperdicio>(_onLoadTendenciaDesperdicio);
    on<LoadItensExpirados>(_onLoadItensExpirados);
    on<LoadInsights>(_onLoadInsights);
    on<ExportarDados>(_onExportarDados);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      if (state is! AnalyticsLoaded) {
        emit(AnalyticsLoading());
      }
      
      final dashboard = await _analyticsService.getDashboard(
        despensaId: event.despensaId,
      );
      
      emit(AnalyticsLoaded(dashboard));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      if (state is AnalyticsLoaded) {
        emit(AnalyticsRefreshing((state as AnalyticsLoaded).dashboard));
      }
      
      await _analyticsService.refreshAnalytics();
      final dashboard = await _analyticsService.getDashboard();
      
      emit(AnalyticsLoaded(dashboard));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadConsumoCategoria(
    LoadConsumoCategoria event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final consumoCategoria = await _analyticsService.getConsumoCategoria();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: consumoCategoria,
          topProdutos: currentDashboard.topProdutos,
          gastosMensais: currentDashboard.gastosMensais,
          tendenciaDesperdicio: currentDashboard.tendenciaDesperdicio,
          itensExpirados: currentDashboard.itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: currentDashboard.insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadTopProdutos(
    LoadTopProdutos event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final topProdutos = await _analyticsService.getTopProdutos();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: currentDashboard.consumoPorCategoria,
          topProdutos: topProdutos,
          gastosMensais: currentDashboard.gastosMensais,
          tendenciaDesperdicio: currentDashboard.tendenciaDesperdicio,
          itensExpirados: currentDashboard.itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: currentDashboard.insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadGastosMensais(
    LoadGastosMensais event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final gastosMensais = await _analyticsService.getGastosMensais();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: currentDashboard.consumoPorCategoria,
          topProdutos: currentDashboard.topProdutos,
          gastosMensais: gastosMensais,
          tendenciaDesperdicio: currentDashboard.tendenciaDesperdicio,
          itensExpirados: currentDashboard.itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: currentDashboard.insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadTendenciaDesperdicio(
    LoadTendenciaDesperdicio event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final tendenciaDesperdicio = await _analyticsService.getTendenciaDesperdicio();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: currentDashboard.consumoPorCategoria,
          topProdutos: currentDashboard.topProdutos,
          gastosMensais: currentDashboard.gastosMensais,
          tendenciaDesperdicio: tendenciaDesperdicio,
          itensExpirados: currentDashboard.itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: currentDashboard.insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadItensExpirados(
    LoadItensExpirados event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final itensExpirados = await _analyticsService.getItensExpirados();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: currentDashboard.consumoPorCategoria,
          topProdutos: currentDashboard.topProdutos,
          gastosMensais: currentDashboard.gastosMensais,
          tendenciaDesperdicio: currentDashboard.tendenciaDesperdicio,
          itensExpirados: itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: currentDashboard.insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final insights = await _analyticsService.getInsights();
      
      if (state is AnalyticsLoaded) {
        final currentDashboard = (state as AnalyticsLoaded).dashboard;
        final updatedDashboard = AnalyticsDashboard(
          indicadores: currentDashboard.indicadores,
          consumoPorCategoria: currentDashboard.consumoPorCategoria,
          topProdutos: currentDashboard.topProdutos,
          gastosMensais: currentDashboard.gastosMensais,
          tendenciaDesperdicio: currentDashboard.tendenciaDesperdicio,
          itensExpirados: currentDashboard.itensExpirados,
          heatmapConsumo: currentDashboard.heatmapConsumo,
          insights: insights,
        );
        emit(AnalyticsLoaded(updatedDashboard));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onExportarDados(
    ExportarDados event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsExporting());
      
      final downloadUrl = await _analyticsService.exportarDados(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        formato: event.formato,
      );
      
      emit(AnalyticsExported(downloadUrl));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
} 