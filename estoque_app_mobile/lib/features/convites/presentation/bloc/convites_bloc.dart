import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/convite_models.dart';
import '../../data/services/convites_service.dart';

// Events
abstract class ConvitesEvent extends Equatable {
  const ConvitesEvent();

  @override
  List<Object> get props => [];
}

class LoadConvitesRecebidos extends ConvitesEvent {}

class LoadConvitesEnviados extends ConvitesEvent {}

class EnviarConvite extends ConvitesEvent {
  final int despensaId;
  final ConviteRequest request;

  const EnviarConvite({required this.despensaId, required this.request});

  @override
  List<Object> get props => [despensaId, request];
}

class AceitarConvite extends ConvitesEvent {
  final int conviteId;

  const AceitarConvite({required this.conviteId});

  @override
  List<Object> get props => [conviteId];
}

class RecusarConvite extends ConvitesEvent {
  final int conviteId;

  const RecusarConvite({required this.conviteId});

  @override
  List<Object> get props => [conviteId];
}

class DeletarConvite extends ConvitesEvent {
  final int conviteId;

  const DeletarConvite({required this.conviteId});

  @override
  List<Object> get props => [conviteId];
}

class LoadMembros extends ConvitesEvent {
  final int despensaId;

  const LoadMembros({required this.despensaId});

  @override
  List<Object> get props => [despensaId];
}

class RemoverMembro extends ConvitesEvent {
  final int despensaId;
  final int membroId;

  const RemoverMembro({required this.despensaId, required this.membroId});

  @override
  List<Object> get props => [despensaId, membroId];
}

class AlterarRoleMembro extends ConvitesEvent {
  final int despensaId;
  final int membroId;
  final String novoRole;

  const AlterarRoleMembro({
    required this.despensaId,
    required this.membroId,
    required this.novoRole,
  });

  @override
  List<Object> get props => [despensaId, membroId, novoRole];
}

// States
abstract class ConvitesState extends Equatable {
  const ConvitesState();

  @override
  List<Object> get props => [];
}

class ConvitesInitial extends ConvitesState {}

class ConvitesLoading extends ConvitesState {}

class ConvitesLoaded extends ConvitesState {
  final List<Convite> convitesRecebidos;
  final List<Convite> convitesEnviados;

  const ConvitesLoaded({
    required this.convitesRecebidos,
    required this.convitesEnviados,
  });

  @override
  List<Object> get props => [convitesRecebidos, convitesEnviados];
}

class MembrosLoaded extends ConvitesState {
  final List<MembroDespensa> membros;

  const MembrosLoaded({required this.membros});

  @override
  List<Object> get props => [membros];
}

class ConvitesError extends ConvitesState {
  final String message;

  const ConvitesError({required this.message});

  @override
  List<Object> get props => [message];
}

class ConvitesSuccess extends ConvitesState {
  final String message;

  const ConvitesSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ConvitesBloc extends Bloc<ConvitesEvent, ConvitesState> {
  final ConvitesService _convitesService;

  ConvitesBloc(this._convitesService) : super(ConvitesInitial()) {
    on<LoadConvitesRecebidos>(_onLoadConvitesRecebidos);
    on<LoadConvitesEnviados>(_onLoadConvitesEnviados);
    on<EnviarConvite>(_onEnviarConvite);
    on<AceitarConvite>(_onAceitarConvite);
    on<RecusarConvite>(_onRecusarConvite);
    on<DeletarConvite>(_onDeletarConvite);
    on<LoadMembros>(_onLoadMembros);
    on<RemoverMembro>(_onRemoverMembro);
    on<AlterarRoleMembro>(_onAlterarRoleMembro);
  }

  Future<void> _onLoadConvitesRecebidos(
    LoadConvitesRecebidos event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      final convitesRecebidos = await _convitesService.getConvitesRecebidos();
      emit(ConvitesLoaded(
        convitesRecebidos: convitesRecebidos,
        convitesEnviados: [],
      ));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onLoadConvitesEnviados(
    LoadConvitesEnviados event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      final convitesEnviados = await _convitesService.getConvitesEnviados();
      emit(ConvitesLoaded(
        convitesRecebidos: [],
        convitesEnviados: convitesEnviados,
      ));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onEnviarConvite(
    EnviarConvite event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.enviarConvite(event.despensaId, event.request);
      emit(const ConvitesSuccess(message: 'Convite enviado com sucesso!'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onAceitarConvite(
    AceitarConvite event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.aceitarConvite(event.conviteId);
      emit(const ConvitesSuccess(message: 'Convite aceito com sucesso!'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onRecusarConvite(
    RecusarConvite event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.recusarConvite(event.conviteId);
      emit(const ConvitesSuccess(message: 'Convite recusado.'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onDeletarConvite(
    DeletarConvite event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.deletarConvite(event.conviteId);
      emit(const ConvitesSuccess(message: 'Convite deletado com sucesso!'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onLoadMembros(
    LoadMembros event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      final membros = await _convitesService.getMembros(event.despensaId);
      emit(MembrosLoaded(membros: membros));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onRemoverMembro(
    RemoverMembro event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.removerMembro(event.despensaId, event.membroId);
      emit(const ConvitesSuccess(message: 'Membro removido com sucesso!'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }

  Future<void> _onAlterarRoleMembro(
    AlterarRoleMembro event,
    Emitter<ConvitesState> emit,
  ) async {
    emit(ConvitesLoading());
    try {
      await _convitesService.alterarRoleMembro(
        event.despensaId,
        event.membroId,
        event.novoRole,
      );
      emit(const ConvitesSuccess(message: 'Role alterado com sucesso!'));
    } catch (e) {
      emit(ConvitesError(message: e.toString()));
    }
  }
} 