import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/despensas_service.dart';
import '../../data/models/despensa.dart';
import '../../../../core/exceptions/api_exception.dart';
import 'despensas_event.dart';
import 'despensas_state.dart';

class DespensasBloc extends Bloc<DespensasEvent, DespensasState> {
  final DespensasService _despensasService;

  DespensasBloc(this._despensasService) : super(const DespensasInitial()) {
    on<LoadDespensas>(_onLoadDespensas);
    on<RefreshDespensas>(_onRefreshDespensas);
    on<CreateDespensa>(_onCreateDespensa);
    on<UpdateDespensa>(_onUpdateDespensa);
    on<DeleteDespensa>(_onDeleteDespensa);
    on<LoadDespensaDetalhes>(_onLoadDespensaDetalhes);
    on<ConvidarMembro>(_onConvidarMembro);
    on<RemoverMembro>(_onRemoverMembro);
    on<ClearDespensaMessage>(_onClearDespensaMessage);
  }

  Future<void> _onLoadDespensas(
    LoadDespensas event,
    Emitter<DespensasState> emit,
  ) async {
    emit(const DespensasLoading());

    try {
      final despensas = await _despensasService.getDespensas();
      
      if (despensas.isEmpty) {
        emit(const DespensasEmpty());
      } else {
        emit(DespensasLoaded(despensas: despensas));
      }
    } on ApiException catch (e) {
      emit(DespensasError(message: e.message));
    } catch (e) {
      emit(DespensasError(message: 'Erro inesperado ao carregar despensas: $e'));
    }
  }

  Future<void> _onRefreshDespensas(
    RefreshDespensas event,
    Emitter<DespensasState> emit,
  ) async {
    final currentState = state;
    
    // Se já temos despensas, mostra estado de refresh
    if (currentState is DespensasLoaded) {
      emit(DespensasRefreshing(currentState.despensas));
    }

    try {
      final despensas = await _despensasService.getDespensas();
      
      if (despensas.isEmpty) {
        emit(const DespensasEmpty());
      } else {
        emit(DespensasLoaded(despensas: despensas));
      }
    } on ApiException catch (e) {
      // Mantém os dados existentes em caso de erro no refresh
      final existingDespensas = currentState is DespensasLoaded ? currentState.despensas : <Despensa>[];
      emit(DespensasError(
        message: e.message,
        despensas: existingDespensas,
      ));
    } catch (e) {
      final existingDespensas = currentState is DespensasLoaded ? currentState.despensas : <Despensa>[];
      emit(DespensasError(
        message: 'Erro inesperado ao atualizar despensas: $e',
        despensas: existingDespensas,
      ));
    }
  }

  Future<void> _onCreateDespensa(
    CreateDespensa event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();

    emit(DespensaOperationLoading(
      despensas: currentDespensas,
      operation: 'create',
    ));

    try {
      final novaDespensaResponse = await _despensasService.criarDespensa(event.dto);
      
      // Recarrega a lista completa para obter todos os dados
      final despensasAtualizadas = await _despensasService.getDespensas();
      
      emit(DespensasLoaded(
        despensas: despensasAtualizadas,
        successMessage: 'Despensa "${novaDespensaResponse.nome}" criada com sucesso!',
      ));
    } on UpgradeRequiredException catch (e) {
      emit(DespensasUpgradeRequired.fromException(e, currentDespensas));
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao criar despensa: $e',
        despensas: currentDespensas,
      ));
    }
  }

  Future<void> _onUpdateDespensa(
    UpdateDespensa event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();

    emit(DespensaOperationLoading(
      despensas: currentDespensas,
      despensaId: event.id,
      operation: 'update',
    ));

    try {
      await _despensasService.atualizarDespensa(event.id, event.dto);
      
      // Recarrega a lista completa
      final despensasAtualizadas = await _despensasService.getDespensas();
      
      emit(DespensasLoaded(
        despensas: despensasAtualizadas,
        successMessage: 'Despensa atualizada com sucesso!',
      ));
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao atualizar despensa: $e',
        despensas: currentDespensas,
      ));
    }
  }

  Future<void> _onDeleteDespensa(
    DeleteDespensa event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();
    final despensaParaDeletar = currentDespensas.firstWhere(
      (d) => d.id == event.id,
      orElse: () => throw Exception('Despensa não encontrada'),
    );

    emit(DespensaOperationLoading(
      despensas: currentDespensas,
      despensaId: event.id,
      operation: 'delete',
    ));

    try {
      await _despensasService.deletarDespensa(event.id);
      
      // Remove a despensa da lista local
      final despensasAtualizadas = currentDespensas.where((d) => d.id != event.id).toList();
      
      if (despensasAtualizadas.isEmpty) {
        emit(const DespensasEmpty());
      } else {
        emit(DespensasLoaded(
          despensas: despensasAtualizadas,
          successMessage: 'Despensa "${despensaParaDeletar.nome}" deletada com sucesso!',
        ));
      }
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao deletar despensa: $e',
        despensas: currentDespensas,
      ));
    }
  }

  Future<void> _onLoadDespensaDetalhes(
    LoadDespensaDetalhes event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();

    try {
      final despensa = await _despensasService.getDespensa(event.id);
      emit(DespensaDetalhesLoaded(
        despensa: despensa,
        todasDespensas: currentDespensas,
      ));
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao carregar detalhes da despensa: $e',
        despensas: currentDespensas,
      ));
    }
  }

  Future<void> _onConvidarMembro(
    ConvidarMembro event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();

    emit(DespensaOperationLoading(
      despensas: currentDespensas,
      despensaId: event.despensaId,
      operation: 'invite',
    ));

    try {
      final response = await _despensasService.convidarMembro(event.despensaId, event.dto);
      
      emit(DespensasLoaded(
        despensas: currentDespensas,
        successMessage: 'Convite enviado para ${response.destinatario.email} com sucesso!',
      ));
    } on UpgradeRequiredException catch (e) {
      emit(DespensasUpgradeRequired.fromException(e, currentDespensas));
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao enviar convite: $e',
        despensas: currentDespensas,
      ));
    }
  }

  Future<void> _onRemoverMembro(
    RemoverMembro event,
    Emitter<DespensasState> emit,
  ) async {
    final currentDespensas = _getCurrentDespensas();

    emit(DespensaOperationLoading(
      despensas: currentDespensas,
      despensaId: event.despensaId,
      operation: 'remove_member',
    ));

    try {
      await _despensasService.removerMembro(event.despensaId, event.membroId);
      
      // Recarrega os detalhes da despensa para atualizar a lista de membros
      final despensaAtualizada = await _despensasService.getDespensa(event.despensaId);
      
      emit(DespensaDetalhesLoaded(
        despensa: despensaAtualizada,
        todasDespensas: currentDespensas,
      ));
    } on ApiException catch (e) {
      emit(DespensasError(
        message: e.message,
        despensas: currentDespensas,
      ));
    } catch (e) {
      emit(DespensasError(
        message: 'Erro inesperado ao remover membro: $e',
        despensas: currentDespensas,
      ));
    }
  }

  void _onClearDespensaMessage(
    ClearDespensaMessage event,
    Emitter<DespensasState> emit,
  ) {
    final currentState = state;
    if (currentState is DespensasLoaded) {
      emit(currentState.copyWith(clearSuccessMessage: true));
    }
  }

  /// Método auxiliar para obter a lista atual de despensas
  List<Despensa> _getCurrentDespensas() {
    final currentState = state;
    if (currentState is DespensasLoaded) {
      return currentState.despensas;
    } else if (currentState is DespensasRefreshing) {
      return currentState.despensas;
    } else if (currentState is DespensasError && currentState.despensas != null) {
      return currentState.despensas!;
    } else if (currentState is DespensasUpgradeRequired) {
      return currentState.despensas;
    } else if (currentState is DespensaOperationLoading) {
      return currentState.despensas;
    } else if (currentState is DespensaDetalhesLoaded) {
      return currentState.todasDespensas;
    }
    return <Despensa>[];
  }
} 